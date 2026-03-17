package persistencia;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoPostgreSQL {
    
    /**
    * Atributos de Conexão Declarados como variáveis de Ambiente
    * Variáveis de Ambiente são valores definidos fora do código, no sistema operacional
    * cuja aplicação ocorre em tempo de execução 
    
    private static final String HOST = System.getenv("localhost");
    private static final String PORT = System.getenv("5432");
    private static final String DB_NAME = System.getenv("sistema_requerimento");
    private static final String USER = System.getenv("DB_USER");
    private static final String PASSWORD = System.getenv("DB_PASSWORD");


    set DB_HOST=localhost
    set DB_PORT=5432
    set DB_NAME=sistema_requerimento
    set DB_USER=postgres
    set DB_PASSWORD=12345
    

    // 🖥️ Como definir variáveis de ambiente (Windows)
     
    🔹 Permanente

        Pesquise: "Variáveis de Ambiente"
        Clique em "Editar variáveis do sistema"
        Adicione:
        Nome	    |   Valor
        DB_HOST	    |   localhost
        DB_PORT	    |   5432
        DB_NAME	    |   sistema_requerimento
        DB_USER	    |   postgres
        DB_PASSWORD	|   12345

        Testando no Java
        System.out.println(System.getenv("DB_HOST"));
    */

    // Constantes de configuração (melhor prática)
    private static final String HOST = "localhost";
    private static final String PORT = "5432";
    private static final String DB_NAME = "sistema_requerimento";
    private static final String USER = "postgres";
    private static final String PASSWORD = "12345";

    public Connection getConexao() throws SQLException{

        // URL de conexão JDBC
        String url = "jdbc:postgresql://" + HOST + ":" + PORT + "/" + DB_NAME;

        try {
            // Tentando Estabelecer a Conexão com o banco
            return DriverManager.getConnection(url, USER, PASSWORD);
        } catch (SQLException e) {
            // EM caso de Erro, Lançamos uma exceção mais genérica
            throw new RuntimeException("Erro ao Conectar ao Banco", e);
        }
    }
}
