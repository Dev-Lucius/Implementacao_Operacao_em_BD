package persistencia;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoPostgreSQL {
    private final String host = "localhost";
    private final String port = "5432";
    private final String username = "postgres";
    private final String password = "12345";
    private final String dbname = "sistema_requerimento_completo";

    // Método de Conexão
    public Connection getConexao() throws  SQLException{
        String url = "jdbc:postgresql://" + host + ":" + port + "/" + dbname;

        try {
            return DriverManager.getConnection(url, username, password);
        } catch (SQLException e) {
            throw new RuntimeException("Ero ao Conectar ao Banco", e);
        }
    }
}
