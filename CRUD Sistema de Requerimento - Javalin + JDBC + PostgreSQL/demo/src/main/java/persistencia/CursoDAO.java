package persistencia;

// Importações Necessárias para Trabalhar com o Banco de Dados JDBC
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

// Estruturas de Dados
import java.util.ArrayList;
import java.util.List;

import negocio.Curso;

public class CursoDAO {
    /**
     * Método resonsável por inserir um novo curso ao banco de dados
     * @param curso --> Objeto contendo os dados que serão inseridos
     * 
     */
    public void inserirCurso(Curso curso){
        // Comando SQL com parâmetros (?)
        //  - Evita SQL Injection
        //  - Melhora a Performance do código
        String sql = "INSERT INTO curso (nome, site, turno, duracao) VALUES (?, ?, ?, ?)";

        try(
            // Abrindo o banco de daos
            Connection connection = new ConexaoPostgreSQL().getConexao();
            // Preparando o comando SQL para execução
            PreparedStatement stmt = connection.prepareStatement(sql);
        ){
            stmt.setString(1, curso.getNomeCurso());
            stmt.setString(2, curso.getSiteCurso());
            stmt.setString(3, curso.getTurnoCurso());
            stmt.setString(4, curso.getDuracaoCurso());

            // Executando o Comando Insert no Banco
            stmt.executeUpdate();
        } catch(SQLException e){
            /**
             * EM CASO DE ERROS
             * Encapsulamos a exceção em RunTimeException
             * A fim de tratar o erro a partir de outras camadas
             */
            throw new RuntimeException("Erro ao Inserir curso", e);
        }
    }

    /**
     * Método Responsável por buscar todos os cursos do banco
     * @return --> Ao final retorna a lista de Objetos
     */
    public List<Curso> listarCursos(){

        List<Curso> vetCurso = new ArrayList<>();
        String sql = "SELECT * FROM curso ORDER BY ASC";

        try (
            Connection connection = new ConexaoPostgreSQL().getConexao();
            PreparedStatement stmt = connection.prepareStatement(sql);

            // Executa a Consulta e Obtêm o resultado
            ResultSet rs = stmt.executeQuery();
        ){
            while(rs.next()){
                vetCurso.add(mapearCurso(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao Listar Cursos", e);
        }
        return vetCurso;
    }

    private Curso mapearCurso(ResultSet rs) throws SQLException{
        Curso curso = new Curso();
        curso.setIdCurso(rs.getInt("id"));
        curso.setNomeCurso(rs.getString("nome"));
        curso.setSiteCurso(rs.getString("site"));
        curso.setDuracaoCurso(rs.getString("duracao"));
        curso.setTurnoCurso(rs.getString("turno"));

        return curso;
    }
}
