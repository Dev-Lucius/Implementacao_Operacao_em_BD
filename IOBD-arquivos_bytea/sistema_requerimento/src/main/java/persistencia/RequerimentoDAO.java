package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import negocio.Aluno;
import negocio.Requerimento;
import negocio.TipoRequerimento;

public class RequerimentoDAO {

    public List<Requerimento> listar() throws SQLException {
        List<Requerimento> vetRequerimento = new ArrayList<Requerimento>();
        String sql = "SELECT requerimento.id, data_hora_abertura, data_hora_encerramento, anexo, observacao, esquema_requerimento.requerimento.id, aluno_matricula, esquema_requerimento.requerimento.tipo_requerimento_id, esquema_requerimento.tipo_requerimento.descricao FROM esquema_requerimento.requerimento JOIN esquema_requerimento.tipo_requerimento  oN (esquema_requerimento.tipo_requerimento.id = esquema_requerimento.requerimento.tipo_requerimento_id) JOIN  aluno on (requerimento.aluno_matricula = aluno.matricula) ORDER BY id desc";
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        ResultSet rs =  conexao.prepareStatement(sql).executeQuery();
        while (rs.next()) {
            Requerimento requerimento = new Requerimento();
            requerimento.setId(rs.getInt("id"));
            requerimento.setAluno(new Aluno(rs.getString("aluno_matricula")));
            requerimento.setAnexo(rs.getBytes("anexo"));
            requerimento.setObservacao(rs.getString("observacao"));
            requerimento.setDataHoraAbertura(rs.getTimestamp("data_hora_abertura").toLocalDateTime());
            requerimento.setDataHoraEncerramento((rs.getTimestamp("data_hora_encerramento") != null) ? rs.getTimestamp("data_hora_encerramento").toLocalDateTime() : null);
            TipoRequerimento tipo_requerimento = new TipoRequerimento();
            tipo_requerimento.setDescricao(rs.getString("descricao"));
            tipo_requerimento.setId(rs.getInt("tipo_requerimento_id"));
            requerimento.setTipoRequerimento(tipo_requerimento);

            vetRequerimento.add(requerimento);
        }
        conexao.close();
        return vetRequerimento;
    }

    public boolean adicionar(Requerimento requerimento) throws SQLException {
        String sql = "INSERT INTO esquema_requerimento.requerimento (aluno_matricula, observacao,  tipo_requerimento_id, anexo) valueS (?, ?, ?, ?) RETURNING id;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setString(1, requerimento.getAluno().getMatricula());
        preparedStatement.setString(2, requerimento.getObservacao());
        // preparedStatement.setString(3, requerimento.getStatus().name());
        preparedStatement.setInt(3, requerimento.getTipoRequerimento().getId());
        preparedStatement.setBytes(4, ((requerimento.getAnexo() != null) ? requerimento.getAnexo(): null));
        ResultSet rs = preparedStatement.executeQuery();
        boolean result = false;
        if (rs.next()){
            requerimento.setId(rs.getInt("id"));
            result = true;
        }
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return result;
    }

    public Requerimento obter(int id) throws SQLException {
        String sql = "SELECT requerimento.id, data_hora_abertura, data_hora_encerramento, anexo, observacao, esquema_requerimento.requerimento.id, aluno_matricula, esquema_requerimento.requerimento.tipo_requerimento_id, esquema_requerimento.tipo_requerimento.descricao FROM esquema_requerimento.requerimento JOIN esquema_requerimento.tipo_requerimento  oN (esquema_requerimento.tipo_requerimento.id = esquema_requerimento.requerimento.tipo_requerimento_id) JOIN  aluno on (requerimento.aluno_matricula = aluno.matricula) where esquema_requerimento.requerimento.id = ?";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        ResultSet rs = preparedStatement.executeQuery();
        Requerimento requerimento = new Requerimento();
        if(rs.next()) {
            requerimento.setId(rs.getInt("id"));
            requerimento.setAluno(new Aluno(rs.getString("aluno_matricula")));
            requerimento.setAnexo(rs.getBytes("anexo"));
            requerimento.setObservacao(rs.getString("observacao"));
            requerimento.setDataHoraAbertura(rs.getTimestamp("data_hora_abertura").toLocalDateTime());
            requerimento.setDataHoraEncerramento((rs.getTimestamp("data_hora_encerramento") != null) ? rs.getTimestamp("data_hora_encerramento").toLocalDateTime() : null);
            TipoRequerimento tipo_requerimento = new TipoRequerimento();
            tipo_requerimento.setDescricao(rs.getString("descricao"));
            tipo_requerimento.setId(rs.getInt("tipo_requerimento_id"));
            requerimento.setTipoRequerimento(tipo_requerimento);
        }
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return requerimento;
    }

    public boolean excluir(int id) throws SQLException {
        String sql = "DELETE FROM esquema_requerimento.requerimento WHERE esquema_requerimento.requerimento.id = ?";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        int resultado = preparedStatement.executeUpdate();
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return resultado == 1;
    }

    public boolean alterar(Requerimento requerimento) throws SQLException {
        String sql = "UPDATE esquema_requerimento.requerimento SET aluno_matricula = ?, observacao = ?,  tipo_requerimento_id = ?, anexo = ? WHERE esquema_requerimento.requerimento.id = ?;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        // System.out.println(requerimento);
        preparedStatement.setString(1, requerimento.getAluno().getMatricula());
        preparedStatement.setString(2, requerimento.getObservacao());
        preparedStatement.setInt(3, requerimento.getTipoRequerimento().getId());
        preparedStatement.setBytes(4, ((requerimento.getAnexo() != null) ? requerimento.getAnexo(): null));
        preparedStatement.setInt(5, requerimento.getId());
        int resultado = preparedStatement.executeUpdate();
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return resultado == 1;
    }

}
