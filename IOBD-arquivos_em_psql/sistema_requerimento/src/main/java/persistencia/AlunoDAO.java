package persistencia;

import java.sql.*;
import java.util.ArrayList;


import negocio.Aluno;
import negocio.Usuario;
import negocio.Aluno;

public class AlunoDAO {

    public ArrayList<Aluno> listar() throws SQLException{
     String sql = "SELECT matricula, usuario_id FROM aluno;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        ArrayList<Aluno> vetAluno = new ArrayList<>();
        ResultSet rs = preparedStatement.executeQuery();
        while (rs.next()) {
            Aluno aluno = new Aluno();
            aluno.setMatricula(rs.getString("matricula"));
            Usuario usuario = new Usuario();
            usuario.setId(rs.getInt("usuario_id"));
            aluno.setUsuario(usuario);
            // aluno.setStatusAluno(rs.getString());
            vetAluno.add(aluno);            
        }
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return vetAluno;
    }

    public Aluno obter(String matricula) throws SQLException {
         String sql = "SELECT matricula, usuario_id FROM aluno where matricula = ?;";
        Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
        preparedStatement.setString(1, matricula);
        ResultSet rs = preparedStatement.executeQuery();
        Aluno aluno = new Aluno();

        if (rs.next()) {
            aluno.setMatricula(rs.getString("matricula"));
            Usuario usuario = new Usuario();
            usuario.setId(rs.getInt("usuario_id"));
            aluno.setUsuario(usuario);
            // aluno.setStatusAluno(rs.getString());
        }
        preparedStatement.close();
        conexaoPostgreSQL.close();
        return aluno;
    }

}
