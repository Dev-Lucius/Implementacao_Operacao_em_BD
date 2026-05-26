package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList; // Importado para a lista
import java.util.List;      // Importado para a lista

import negocio.Aluno;
import negocio.Requerimento;
import negocio.TipoRequerimento;

public class RequerimentoDAO {

    public boolean adicionar(Requerimento requerimento) throws SQLException {
        String sql = "INSERT INTO esquema_requerimento.requerimento (aluno_matricula, observacao, tipo_requerimento_id, anexo) VALUES (?, ?, ?, ?) RETURNING id;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setString(1, requerimento.getAluno().getMatricula());
        preparedStatement.setString(2, requerimento.getObservacao());
        preparedStatement.setInt(3, requerimento.getTipoRequerimento().getId());
        preparedStatement.setBytes(4, requerimento.getAnexo());
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
        String sql = "SELECT data_hora_abertura, data_hora_encerramento, esquema_requerimento.requerimento.anexo, observacao, esquema_requerimento.requerimento.id, aluno_matricula, esquema_requerimento.requerimento.tipo_requerimento_id, esquema_requerimento.tipo_requerimento.descricao FROM esquema_requerimento.requerimento JOIN esquema_requerimento.tipo_requerimento ON (esquema_requerimento.tipo_requerimento.id = esquema_requerimento.requerimento.tipo_requerimento_id) JOIN aluno ON (requerimento.aluno_matricula = aluno.matricula) ORDER BY data_hora_abertura DESC";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        ResultSet rs = preparedStatement.executeQuery();
        Requerimento requerimento = new Requerimento();
        if(rs.next()) {
            requerimento.setId(rs.getInt("id")); // CORREÇÃO: Setando o ID que faltava
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

    // NOVO MÉTODO: Listar todos os requerimentos do banco
    public List<Requerimento> listar() throws SQLException {
        List<Requerimento> lista = new ArrayList<>();
        // O mesmo SQL do obter, mas sem a cláusula WHERE id = ?
        String sql = "SELECT data_hora_abertura, data_hora_encerramento, anexo, observacao, esquema_requerimento.requerimento.id, aluno_matricula, esquema_requerimento.requerimento.tipo_requerimento_id, esquema_requerimento.tipo_requerimento.descricao FROM esquema_requerimento.requerimento JOIN esquema_requerimento.tipo_requerimento ON (esquema_requerimento.tipo_requerimento.id = esquema_requerimento.requerimento.tipo_requerimento_id) JOIN aluno ON (requerimento.aluno_matricula = aluno.matricula) ORDER BY data_hora_abertura DESC";
        
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        ResultSet rs = preparedStatement.executeQuery();
        
        while(rs.next()) {
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
            
            lista.add(requerimento);
        }
        
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return lista;
    }
}