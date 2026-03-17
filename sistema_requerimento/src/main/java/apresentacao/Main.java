// Pacote
package apresentacao;

// Import do Frameword Javalin
// Usado para criar o Servidor Web
import io.javalin.Javalin;

// Import das Estruturas de Dados
// Usadas para enviar informações do back-end para o HTML
import java.util.HashMap;
import java.util.Map;

// Importando a classe reponsável por acessar os dados no banco
import persistencia.CursoDAO;

/**
 * Classe principal responsável por iniciar a aplicação web.
 * 
 * Utiliza o framework Javalin para criar um servidor HTTP simples
 * e definir rotas para renderização de páginas.
 */
public class Main {

    // Método Principal --> Ponto de entrada de qualquer aplicação Java
    public static void main(String[] args) {

        // Criação da aplicação Javalin
        // Isto é, cria-se uma instância do server web através do Javalin
        Javalin app = Javalin.create();

        // Inicialização das rotas
        // Aqui separamos as configurações das rotas em outro método --> Melhor Organização
        configurarRotas(app);

        // Inicialização do servidor na porta 7070
        app.start(7070);

        // Após inicializado, enviamos uma mensagem ao console indicando que a aplicação inicou com sucesso
        System.out.println("🚀 Servidor rodando em http://localhost:7070");
    }

    /**
     * Método responsável por definir todas as rotas da aplicação.
     * 
     * @param app instância do Javalin
     */
    private static void configurarRotas(Javalin app) {

        // Instância do DAO (acesso ao banco)
        CursoDAO cursoDAO = new CursoDAO();

        // Rota principal (home)
        // Aqui Definimos uma rota HTTP GET para o caminho "/"
        // ctx - context - representa a requisição e a resposta
        app.get("/", ctx -> {

            try {
                // Mapa de dados enviado para o template HTML
                Map<String, Object> model = new HashMap<>();

                // Adicionamos ao mapa a Lista de cursos vindo do banco
                // "vetCurso" será o nome usado no template HTML
                model.put("vetCurso", cursoDAO.listar());

                // Renderiza a página HTML e envia os dados para a mesma
                ctx.render("/templates/index.html", model);

            } catch (Exception e) {
                // Tratamento de erro para não quebrar a aplicação
                ctx.status(500).result("Erro ao carregar cursos.");

                // Exibimos o erro no Console para Debugar
                e.printStackTrace();
            }
        });
    }
}