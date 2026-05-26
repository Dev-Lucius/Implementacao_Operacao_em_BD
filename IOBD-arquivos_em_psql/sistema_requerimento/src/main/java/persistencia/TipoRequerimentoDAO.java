package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import negocio.TipoRequerimento;

public class TipoRequerimentoDAO {

    public ArrayList<TipoRequerimento> listar() throws SQLException{
        String sql = "SELECT * FROM esquema_requerimento.tipo_requerimento;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        ArrayList<TipoRequerimento> vetTipoRequerimento = new ArrayList<>();
        ResultSet rs = preparedStatement.executeQuery();
        while (rs.next()) {
            TipoRequerimento tipoRequerimento = new TipoRequerimento();
            tipoRequerimento.setId(rs.getInt("id"));
            tipoRequerimento.setDescricao(rs.getString("descricao"));
            vetTipoRequerimento.add(tipoRequerimento);            
        }
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return vetTipoRequerimento;
    }

    public TipoRequerimento obter(int id) throws SQLException {
        TipoRequerimento tipoRequerimento = new TipoRequerimento();
        String sql = "SELECT * FROM esquema_requerimento.tipo_requerimento WHERE id = ?;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setInt(1, id);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {
            tipoRequerimento.setId(rs.getInt("id"));
            tipoRequerimento.setDescricao(rs.getString("descricao"));
        }
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return tipoRequerimento;
    }

}
