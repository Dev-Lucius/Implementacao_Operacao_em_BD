package persistencia;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import negocio.Usuario;

/**
 * 
 * DAO da Tabela Usuario
 * 
 * CREATE TABLE usuario(
 *     id SERIAL PRIMARY KEY,
 *     nome VARCHAR(200) NOT NULL,
 *     email VARCHAR(200) UNIQUE,
 *     cpf CHAR(11) UNIQUE,
 *     data_nascimento DATE,
 *     cep CHAR(8),
 *     complemento TEXT,
 *     numero VARCHAR(10)
 * );
 */

public class UsuarioDAO {
    
    // Método para Inserir um Usuário
    public int inserirUsuario(Usuario usuario) throws SQLException{
        String sql = "INSERT INTO usuario(nome, email, cpf, data_nascimento, cep, complemente, numero) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try(
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement stmt = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ResultSet rs = stmt.getGeneratedKeys();
        ){
            if(rs.next()){
                return rs.getInt(1);
            } 
            stmt.setString(1, usuario.getNome());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getCpf());
            stmt.setDate(4, Date.valueOf(usuario.getDataNascimento()));
            stmt.setString(5, usuario.getCep());
            stmt.setString(6, usuario.getComplemento());
            stmt.setString(7, usuario.getNumero());

            stmt.executeQuery();

        } catch(SQLException e){
            throw new RuntimeException("Erro ao Inserir Novo Usuário: " + e.getMessage(), e);
        }
        return 0;
    }

    // Método para Buscar um Usuário Por ID
    public Usuario buscarPorId(int id){
        String sql = "SELECT * FROM usuario WHERE id = ?";
        
        try(
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement stmt = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ResultSet rs = stmt.getGeneratedKeys();
        ){
            stmt.setInt(1, id);
            if(rs.next()){
                return mapearResultSet(rs);
            }
        } catch(SQLException e){

        }
        return null;
    }

    // Método para Atualizar um Usuário
    public void AtualizarUsuario(Usuario usuario){
        String sql = "UPDATE usuario set nome = ?, email = ?, cpf = ?, data_nascimento = ?, cep = ?, complemento = ?, numero = ? WHERE id = ?";

        try(
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement stmt = connection.prepareStatement(sql);
        ) {
            stmt.setString(1, usuario.getNome());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getCpf());
            stmt.setDate(4, Date.valueOf(usuario.getDataNascimento()));
            stmt.setString(5, usuario.getCep());
            stmt.setString(6, usuario.getComplemento());
            stmt.setString(7, usuario.getNumero());

            stmt.executeQuery();
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao Atualizar um Usuário Por Id: " + e.getMessage(), e);
        }
    }

    // Método para Deletar um Usuário
    public void DeletarUsuario(int id){
        String sql = "DELETE FROM usuario WHERE id = ?";

        try(
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement stmt = connection.prepareStatement(sql);
        ) {
            stmt.setInt(1, id);
            stmt.executeQuery();

        } catch (Exception e) {
            throw new RuntimeException("Erro ao Deletar um Usuário Por Id: " + e.getMessage(), e);
        }
    }

    // Método de Mapeamento
    public Usuario mapearResultSet(ResultSet rs) throws SQLException{
        Usuario u = new Usuario(
            rs.getString("nome"), 
            rs.getString("email"), 
            rs.getString("cpf"), 
            rs.getDate("data_nascimento").toLocalDate(), 
            rs.getString("endereco"), 
            rs.getString("cep"), 
            rs.getString("complemento"), 
            rs.getString("numero")
        );

        u.setId(rs.getInt("id"));
        return u;
    }
}
