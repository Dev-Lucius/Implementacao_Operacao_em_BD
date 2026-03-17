package persistencia;

// Importações Necessárias para Trabalhar com o Banco de Dados JDBC
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

// Estruturas de Dados
import java.util.ArrayList;
import java.util.List;

// Classe de Negócio - Modelo / Entidade
import negocio.Curso;

/**
 * Classe Responsável por acessar o banco de dados
 * e Realizar operações relacionadas à entidade curso
 * 
 * Tal padrão é conhecido como DAO - Data Acess Object
 */
public class CursoDAO {
    /**
     * Método Responsável por inserir um novo curso ao banco de dados
     * @param curso Objeto contendo os dados que serão inseridos
     */
    public void inserir(Curso curso) {
        // Comando SQL com parâmetros (?)
        // -> Evita SQL Injection
        // -> Melhor Performance 
        String sql = "INSERT INTO curso (nome, site, turno, duracao) VALUES (?, ?, ?, ?);";

        try (
            // Abrindo o banco de dados
            Connection connection = new ConexaoPostgreSQL().getConexao();

            // Prepara o comando SQL para execução
            PreparedStatement stmt = connection.prepareStatement(sql)
        ) {

            // Aqui substituímos os parâmetros (?) pelos valores do objeto Curso
            stmt.setString(1, curso.getNome());  // 1° ?
            stmt.setString(2, curso.getSite());  // 2° ?
            stmt.setString(3, curso.getTurno()); // 3° ?
            stmt.setInt(4, curso.getDuracao());  // 4° ?

            // executando o ocmando Insert no banco
            stmt.executeUpdate();

        } catch (SQLException e) {
            /**
             * Em caso de Erros ...
             * Encapsulamos a exceção em RunTimeException
             * Isso permite que outras camadas tratem o erro
             */
            throw new RuntimeException("Erro ao inserir curso", e);
        }
    }
    /**
     * Método Responsável por buscar todos os cursos do banco
     * @return Lista de Objetos do curso
     */
    public List<Curso> listar() {

        // Lista que armazenará os cursos retornados do banco
        // Listas em Java ...
        List<Curso> vetCurso = new ArrayList<>();

        // Comando SQL para retornar todas as linhas da tabela curso em ordem crescente
        String sql = "SELECT * FROM curso ORDER BY nome ASC";

        try (
            // Abrindo a Conexão com o banco
            Connection connection = new ConexaoPostgreSQL().getConexao();

            // Prepara o SQL
            PreparedStatement stmt = connection.prepareStatement(sql);

            // Executa a Consulta e obtém o resultado
            ResultSet rs = stmt.executeQuery()
        ) {
            // Percorre cada linha do resultado
            while (rs.next()) {
                // Adicionamos o Objetos na Lista
                // e Converte cada linha do banco do banco em um Objeto do Curso
                vetCurso.add(mapearCurso(rs));
            }

        } catch (SQLException e) {
            // Trata erro de consulta
            throw new RuntimeException("Erro ao listar cursos", e);
        }

        // Retorna a Lista de Cursos
        return vetCurso;
    }
    /**
     * Converte uma linha do ResultSet em um objeto Curso.
     * --> Este método é responsável por mapear os dados retornados do banco
     * (colunas da tabela) para um objeto da classe curso
     *  
     * @param rs -> Posicionado na linha atual da consulta
     * @return -> Retorna o objeto curso preenchido com os dados da linha atual
     * @throws SQLException -> caso ocorra erro ao acessar os dados do ResultSet
     */
    private Curso mapearCurso(ResultSet rs) throws SQLException {
        Curso curso = new Curso();
        curso.setId(rs.getInt("id"));
        curso.setNome(rs.getString("nome"));
        curso.setSite(rs.getString("site"));
        curso.setDuracao(rs.getInt("duracao"));
        curso.setTurno(rs.getString("turno"));
        return curso;
    }
}