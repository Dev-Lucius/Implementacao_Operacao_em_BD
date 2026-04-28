package apresentacao;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import io.javalin.Javalin;
import io.javalin.rendering.template.JavalinMustache;
import negocio.Curso;
import negocio.Usuario;
import persistencia.CursoDAO;
import persistencia.UsuarioDAO;

public class Main{
    public static void main(String[] args){
        // Testando a Conexão
        // try {
        //     new ConexaoPostgreSQL().getConexao();
        //     System.out.println("✅ Conexao Realizada com Sucesso");
        // } catch (SQLException e) {
        //     System.out.println("❌ Falha na Conexão ao Banco de Dados");
        // }

        Javalin.create(config -> {
            // Definindo qual vai ser a Engine dos Templates
            config.fileRenderer(new JavalinMustache());

            // Definindo as Rotas
            // No caso, a única rota que temos é Index
            config.routes.get("/", ctx -> {
                // Criamos um map <chave, valor> para que seja usada dentro do HTML
                Map<String, Object> map = new HashMap<>();

                // Em Seguida, vamos definir um apelido para a coleção de objetos de curso vindos do nosso banco
                map.put("vetCurso", new CursoDAO().listarCursos());
                map.put("teste", "testando um paragrafo");

                // Renderizamos a página HTML encaminhando tbm o Map
                ctx.render("/templates/index.html", map);
            });

            config.routes.get("/usuario", ctx -> {
                Map<String, Object> map = new HashMap<>();
                map.put("vetUsuario", new UsuarioDAO().listarUsuarios());

                ctx.render("/templates/usuario/index.html", map);
            });

            config.routes.get("/curso/excluir/{id}", ctx -> {
                new CursoDAO().deletarCurso(Integer.parseInt(ctx.pathParam("id")));
                ctx.redirect("/");
            });

            config.routes.get("/usuario/excluir/{id}", ctx -> {
                new UsuarioDAO().DeletarUsuario(Integer.parseInt(ctx.pathParam("id")));
                ctx.redirect("/usuarios");
            });

            config.routes.get("/usuario/tela_alterar/{id}", ctx -> {
                Usuario usuario = new UsuarioDAO().buscarPorId(Integer.parseInt(ctx.pathParam("id")));
                Map<String, Object> map = new HashMap<>();

                map.put("usuario", usuario);
                ctx.render("/templates/usuario/tela_alterar.html", map);
            });

            config.routes.get("/curso/tela_alterar/{id}", ctx -> {
                Curso curso = new CursoDAO().buscarPorId(Integer.parseInt(ctx.pathParam("id")));
                Map<String, Object> map = new HashMap<>();

                map.put("curso", curso);
                ctx.render("/templates/curso/tela_alterar.html", map);
            });

            config.routes.get("/curso/tela_adicionar", ctx -> {
                ctx.render("/templates/curso/tela_adicionar.html");
            });

            config.routes.post("/curso/adicionar", ctx -> {
                String nome = ctx.formParam("nome");
                String site = ctx.formParam("site");
                String turno = ctx.formParam("turno");
                int duracao = Integer.parseInt(ctx.pathParam("id"));

                Curso curso = new Curso(nome, site, null, duracao);
                curso.validarTexto(nome, "nome");
                curso.validarTexto(site, "nome");
                curso.validarTexto(turno, "nome");

                Map<String, Object> map = new HashMap<>();

                if(new CursoDAO().inserirCurso(curso)){
                    ctx.redirect("/");
                } else {
                    map.put("curso", curso);
                    ctx.render("/templates/curso/tela_alterar.html", map);
                }
            });

            config.routes.post("/curso/alterar", ctx -> {
                String nome = ctx.formParam("nome");
                String site = ctx.formParam("site");
                String turno = ctx.formParam("turno");
                int duracao = Integer.parseInt(ctx.pathParam("id"));

                Curso curso = new Curso(nome, site, null, duracao);
                curso.validarTexto(nome, "nome");
                curso.validarTexto(site, "nome");
                curso.validarTexto(turno, "nome");

                Map<String, Object> map = new HashMap<>();

                if(new CursoDAO().atualizarCurso(curso)){
                    ctx.redirect("/");
                } else {
                    map.put("curso", curso);
                    ctx.render("/templates/curso/tela_alterar.html", map);
                }
            });

            config.routes.post("/usuario/alterar", ctx -> {
                int id = Integer.parseInt(ctx.pathParam("id"));
                String nome = ctx.formParam("nome");
                String email = ctx.formParam("email");
                String cpf = ctx.formParam("cpf");
                String cep = ctx.formParam("cep");
                String complemento = ctx.formParam("complemento");
                String numero = ctx.formParam("numero");

                String dataNascimento = ctx.formParam("data_nascimento");
                LocalDate date = LocalDate.parse(dataNascimento);

                Usuario usuario = new Usuario(nome, email, cpf, date, dataNascimento, cep, complemento, numero);
                usuario.validarObrigatorio(nome, "nome");
                usuario.validarEmail("email");
                usuario.validarCpf("cpf");
                usuario.validarCep("cep");
                usuario.validarDataNascimento(date);
                usuario.validarCep("cep");
                usuario.setComplemento("complemento");
                usuario.setNumero(numero);

                Map<String, Object> map = new HashMap<>();

                if(new UsuarioDAO().AtualizarUsuario(usuario)){
                    ctx.redirect("/");
                } else {
                    map.put("usuario", usuario);
                    ctx.render("/templates/usuario/tela_alterar.html");
                }
            });

        }).start(7000);
    }
}
