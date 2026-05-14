package apresentacao;

import java.sql.SQLException;
import java.time.LocalDate;

import io.javalin.Javalin;
import io.javalin.config.SizeUnit;
import io.javalin.rendering.template.JavalinMustache;

import java.util.HashMap;
import java.util.Map;

import negocio.Curso;
import negocio.Requerimento;
import negocio.TipoRequerimento;
import negocio.Usuario;
import persistencia.AlunoDAO;
import persistencia.CursoDAO;
import persistencia.RequerimentoDAO;
import persistencia.TipoRequerimentoDAO;
import persistencia.UsuarioDAO;

public class Main {
    public static void main(String[] args) throws SQLException {
        // ------------------------------------
        // testes

        // testando conexao
        // new ConexaoPostgreSQL().getConexao();

        // testando metodo listar da classe cursodao
        // new CursoDAO().listar().forEach(p -> System.out.println(p.getNome()));
        // Curso curso = new Curso();
        // curso.setNome("curso do igor");
        // curso.setDuracao(1);
        // new CursoDAO().inserir(curso);
        // --------------------

        // var app =
        Javalin.create(config -> {
            // define qual vai ser a minha engine de templates
            config.fileRenderer(new JavalinMustache());

            config.jetty.multipartConfig.cacheDirectory("/tmp");

            // Tamanho máximo permitido para um arquivo
            config.jetty.multipartConfig.maxFileSize(
                    10,
                    SizeUnit.MB);

            // Limite em memória antes de usar disco
            config.jetty.multipartConfig.maxInMemoryFileSize(
                    10,
                    SizeUnit.MB);

            // Limite total da requisição
            config.jetty.multipartConfig.maxTotalRequestSize(
                    1,
                    SizeUnit.GB);

            // defino as minhas rotas

            // a unica rota que tenha eh a index
            config.routes.get("/", ctx -> {
                // crio um map <chave, valor> para que seja usado la no html
                Map<String, Object> map = new HashMap<>();
                // defino um apelido para a colecao de objetos de curso vindos do banco
                map.put("vetCurso", new CursoDAO().listar());
                map.put("teste", "oi!! igor paraninfo!");
                // renderizo a pagina html encaminhando tb o map
                ctx.render("/templates/index.html", map);
            });

            config.routes.get("/novo_requerimento", ctx -> {
                // crio um map <chave, valor> para que seja usado la no html
                Map<String, Object> map = new HashMap<>();
                // defino um apelido para a colecao de objetos de curso vindos do banco
                map.put("vetTipoRequerimento", new TipoRequerimentoDAO().listar());
                map.put("vetAluno", new AlunoDAO().listar());
                // renderizo a pagina html encaminhando tb o map
                ctx.render("/templates/requerimento/tela_adicionar.html", map);
            });

            config.routes.get("/usuarios", ctx -> {
                // crio um map <chave, valor> para que seja usado la no html
                Map<String, Object> map = new HashMap<>();
                // defino um apelido para a colecao de objetos de curso vindos do banco
                map.put("vetUsuario", new UsuarioDAO().listar());
                // renderizo a pagina html encaminhando tb o map
                ctx.render("/templates/usuario/index.html", map);
            });

            config.routes.get("/curso/excluir/{id}", ctx -> {
                new CursoDAO().excluir(Integer.parseInt(ctx.pathParam("id")));
                ctx.redirect("/");
            });

            config.routes.get("/usuario/excluir/{id}", ctx -> {
                new UsuarioDAO().excluir(Integer.parseInt(ctx.pathParam("id")));
                ctx.redirect("/usuarios");
            });

            config.routes.get("/usuario/tela_alterar/{id}", ctx -> {
                Usuario usuario = new UsuarioDAO().obter(Integer.parseInt(ctx.pathParam("id")));
                Map<String, Object> map = new HashMap<>();
                // defino um apelido para a colecao de objetos de curso vindos do banco
                map.put("usuario", usuario);
                ctx.render("/templates/usuario/tela_alterar.html", map);
            });

            config.routes.get("/curso/tela_alterar/{id}", ctx -> {
                Curso curso = new CursoDAO().obter(Integer.parseInt(ctx.pathParam("id")));
                Map<String, Object> map = new HashMap<>();
                // defino um apelido para a colecao de objetos de curso vindos do banco
                map.put("curso", curso);
                ctx.render("/templates/curso/tela_alterar.html", map);
            });

            config.routes.get("/curso/tela_adicionar", ctx -> {
                ctx.render("/templates/curso/tela_adicionar.html");
            });

            config.routes.get("/usuario/tela_adicionar", ctx -> {
                ctx.render("/templates/usuario/tela_adicionar.html");
            });

            config.routes.get("/requerimento/{id}", ctx -> {
                Requerimento requerimento = new RequerimentoDAO().obter(Integer.parseInt(ctx.pathParam("id")));
                Map<String, Object> map = new HashMap<>();
                map.put("requerimento", requerimento);
                ctx.render("/templates/requerimento/tela_visualizar.html", map);
            });

            config.routes.post("/requerimento/adicionar", ctx -> {
                // recebendo no servidor os valores escolhidos vindos do form html
                String aluno_matricula = ctx.formParam("aluno_matricula");
                int tipo_requerimento_id = Integer.parseInt(ctx.formParam("tipo_requerimento_id"));
                String observacao = ctx.formParam("observacao");
                byte[] anexo = ctx.uploadedFile("anexo").content().readAllBytes();
                
                // criando um objeto novo de requerimento
                Requerimento requerimento = new Requerimento();
                // baseado no tipo
                TipoRequerimento tipoRequerimento = new TipoRequerimentoDAO().obter(tipo_requerimento_id);
                requerimento.setTipoRequerimento(tipoRequerimento);
                // baseado no que foi preenchido pelo usuario no campo de observacao
                requerimento.setObservacao(observacao);
                // com o anexo que ta vindo tb do formulario
                requerimento.setAnexo(anexo);
                // baseado no que foi escolhido no select html
                requerimento.setAluno(new AlunoDAO().obter(aluno_matricula));
                // chamei o metodo de adicao dentro do meu DAO
                new RequerimentoDAO().adicionar(requerimento);
                ctx.redirect("/");
            });

            config.routes.post("/usuario/adicionar", ctx -> {
                String nome = ctx.formParam("nome");
                String email = ctx.formParam("email");
                String senha = ctx.formParam("senha");
                String cpf = ctx.formParam("cpf");
                String dataNascimento = ctx.formParam("data_nascimento");
                String rua = ctx.formParam("rua");
                String complemento = ctx.formParam("complemento");
                String nro = ctx.formParam("nro");

                Usuario usuario = new Usuario();
                usuario.setNome(nome);
                usuario.setEmail(email);
                usuario.setSenha(senha);
                System.out.println(dataNascimento);
                usuario.setDataNascimento(LocalDate.parse(dataNascimento));
                usuario.setCpf(cpf);
                usuario.setRua(rua);
                usuario.setNro(nro);
                usuario.setComplemento(complemento);

                if (new UsuarioDAO().adicionar(usuario)) {
                    ctx.redirect("/usuarios");
                } else {
                    ctx.redirect("/templates/usuario/tela_adicionar.html");
                }
                // ctx.render("/templates/curso/tela_adicionar.html");
            });

            config.routes.post("/curso/adicionar", ctx -> {
                String nome = ctx.formParam("nome");
                String site = ctx.formParam("site");
                String turno = ctx.formParam("turno");
                int duracao = Integer.parseInt(ctx.formParam("duracao"));
                Curso curso = new Curso();
                curso.setNome(nome);
                curso.setSite(site);
                curso.setTurno(turno);
                curso.setDuracao(duracao);
                if (new CursoDAO().adicionar(curso)) {
                    ctx.redirect("/");
                } else {
                    ctx.redirect("/templates/curso/tela_adicionar.html");
                }
                // ctx.render("/templates/curso/tela_adicionar.html");
            });

            config.routes.post("/curso/alterar", ctx -> {
                int id = Integer.parseInt(ctx.formParam("id"));
                String nome = ctx.formParam("nome");
                String site = ctx.formParam("site");
                String turno = ctx.formParam("turno");
                int duracao = Integer.parseInt(ctx.formParam("duracao"));
                Curso curso = new Curso();
                curso.setId(id);
                curso.setNome(nome);
                curso.setSite(site);
                curso.setTurno(turno);
                curso.setDuracao(duracao);

                Map<String, Object> map = new HashMap<>();

                if (new CursoDAO().alterar(curso)) {
                    ctx.redirect("/");
                } else {
                    // defino um apelido para a colecao de objetos de curso vindos do banco
                    map.put("curso", curso);
                    ctx.render("/templates/curso/tela_alterar.html", map);
                }
                // ctx.render("/templates/curso/tela_adicionar.html");
            });

            config.routes.post("/usuario/alterar", ctx -> {
                int id = Integer.parseInt(ctx.formParam("id"));
                String nome = ctx.formParam("nome");
                String cpf = ctx.formParam("cpf");
                String email = ctx.formParam("email");
                String cep = ctx.formParam("cep");
                String rua = ctx.formParam("rua");
                String complemento = ctx.formParam("complemento");
                String nro = ctx.formParam("nro");
                String manter_senha = ctx.formParam("manter_senha");
                // System.out.println(manter_senha);
                String senha = ctx.formParam("senha");

                String dataNascimento = ctx.formParam("data_nascimento");
                LocalDate date = LocalDate.parse(dataNascimento);

                Usuario usuario = new Usuario();
                boolean manter_senha_boolean = true;
                if (manter_senha != null && manter_senha.equals("manter")) {
                    usuario = new UsuarioDAO().obter(id);
                } else if (manter_senha == null) {
                    manter_senha_boolean = false;
                    usuario.setSenha(senha);
                }
                usuario.setId(id);
                usuario.setNome(nome);
                usuario.setCpf(cpf);
                usuario.setEmail(email);
                usuario.setCep(cep);
                usuario.setComplemento(complemento);
                usuario.setRua(rua);
                usuario.setNro(nro);
                usuario.setDataNascimento(date);

                Map<String, Object> map = new HashMap<>();
                if (new UsuarioDAO().alterar(usuario, manter_senha_boolean)) {
                    ctx.redirect("/usuarios");
                } else {
                    // defino um apelido para a colecao de objetos de curso vindos do banco
                    map.put("usuario", usuario);
                    ctx.render("/templates/usuario/tela_alterar.html", map);
                }
                // ctx.render("/templates/curso/tela_adicionar.html");
            });

            // defino que minha aplicacao rodara na porta 7070
        }).start(7070);
    }
}