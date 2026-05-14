# Upload, Armazenamento e Recuperação de Arquivos com JDBC, PostgreSQL e Javalin

Os exemplos abaixo demonstram a implementação de upload, armazenamento e recuperação de arquivos utilizando:

* Java
* JDBC
* PostgreSQL
* Javalin
* Mustache Templates

O sistema armazena arquivos binários no banco de dados utilizando colunas do tipo `BYTEA`, convertendo posteriormente os dados para Base64 quando necessário para exibição no navegador.

---

# 1. Configuração do Javalin

## Objetivo

Este trecho configura o servidor web Javalin, incluindo:

* renderização de templates Mustache;
* diretório de arquivos estáticos;
* configuração de upload multipart;
* limites de tamanho de arquivos;
* diretório temporário de uploads.

## Código

```java
var app = Javalin.create(config -> {

    // Configura o mecanismo de templates Mustache
    config.fileRenderer(new JavalinMustache());

    // Define a pasta de arquivos estáticos
    config.staticFiles.add("/static", Location.CLASSPATH);

    // Diretório temporário para uploads
    config.jetty.multipartConfig.cacheDirectory("c:/temp");

    // Tamanho máximo permitido para um arquivo
    config.jetty.multipartConfig.maxFileSize(
        Integer.parseInt(prop.getProperty("MAX_SIZE")),
        SizeUnit.MB
    );

    // Limite em memória antes de usar disco
    config.jetty.multipartConfig.maxInMemoryFileSize(
        10,
        SizeUnit.MB
    );

    // Limite total da requisição
    config.jetty.multipartConfig.maxTotalRequestSize(
        1,
        SizeUnit.GB
    );

}).start(Integer.parseInt(prop.getProperty("javalin_port")));
```

## Função do código

Este trecho prepara o ambiente para permitir upload de arquivos no sistema web.

---

# 2. Upload e armazenamento de arquivos

## Objetivo

Esta rota:

* recebe dados de um formulário HTML;
* processa upload de arquivos;
* converte o arquivo em `byte[]`;
* salva o conteúdo binário no banco PostgreSQL.

## Código

```java
app.post("/adicionar_palestra", ctx -> {

    if (isLogado(ctx)) {

        Palestra palestra = new Palestra();

        palestra.setTitulo(ctx.formParam("titulo"));

        palestra.setDuracao(
            Integer.parseInt(ctx.formParam("duracao"))
        );

        String palavrasChave = ctx.formParam("palavras_chave");

        palestra.setVetPalavraChave(
            Arrays.asList(palavrasChave.split(";"))
        );

        if (ctx.uploadedFile("material") != null) {

            if (ctx.uploadedFile("material").size() > 0) {

                // Lê o arquivo como vetor de bytes
                palestra.setMaterial(
                    ctx.uploadedFile("material")
                       .content()
                       .readAllBytes()
                );

                // Armazena o MIME TYPE
                palestra.setMaterialTipo(
                    ctx.uploadedFile("material")
                       .contentType()
                );

            } else {

                Map<String, Object> map = new HashMap<>();

                map.put(
                    "mensagem",
                    "Arquivo inválido"
                );

                ctx.render("templates/erro.html", map);
            }
        }

        palestra.setEvento(
            new EventoDAO().obter(
                Integer.parseInt(ctx.formParam("evento_id"))
            )
        );

        // Salva no banco usando JDBC
        new PalestraDAO().adicionar(palestra);

        ctx.redirect("/");

    } else {

        ctx.render("templates/tela_login.html");
    }
});
```

## Função do código

O principal objetivo deste trecho é transformar o arquivo enviado pelo navegador em um vetor de bytes (`byte[]`) e persistir os dados no banco PostgreSQL utilizando JDBC.

---

# 3. Recuperação de arquivos do banco

## Objetivo

Esta rota:

* busca os dados binários no banco;
* converte o conteúdo para Base64;
* exibe diretamente no navegador;
* ou fornece link para download.

## Código

```java
app.get("/baixar_material/{id}", ctx -> {

    if (isLogado(ctx)) {

        Palestra palestra = new PalestraDAO().obter(
            Integer.parseInt(ctx.pathParam("id"))
        );

        if (palestra.getMaterialTipo() != null) {

            // Se não for ZIP, exibe no navegador
            if (!palestra.getMaterialTipo().contains("zip")) {

                ctx.html(
                    "<embed src=\"data:"
                    + palestra.getMaterialTipo()
                    + ";base64,"
                    + encodeImageToBase64(palestra.getMaterial())
                    + "\">"
                );

            } else {

                // Se for ZIP, gera página de download
                Map<String, Object> model = new HashMap<>();

                model.put("palestra", palestra);

                ctx.render(
                    "/templates/palestra/baixar.html",
                    model
                );
            }

        } else {

            ctx.html("Sem material");
        }

    } else {

        ctx.render("templates/tela_login.html");
    }
});
```

## Função do código

Este trecho demonstra como recuperar um arquivo armazenado como `byte[]` no PostgreSQL e disponibilizá-lo novamente ao navegador.

---

# 4. Conversão para Base64

## Objetivo

Converter arquivos binários em texto Base64 para utilização em HTML.

## Código

```java
public static String encodeImageToBase64(byte[] imageBytes) {

    return Base64
            .getEncoder()
            .encodeToString(imageBytes);
}
```

## Função do código

O navegador não consegue interpretar diretamente um vetor `byte[]` dentro de HTML. Por isso, o arquivo é convertido para Base64.

---

# 5. Link de download utilizando Base64

## Objetivo

Criar um link HTML para download do arquivo.

## Código

```html
<a href="data:{{palestra.materialTipo}};base64,{{palestra.materialEncode}}">
    baixar
</a>
```

## Função do código

O atributo `href` recebe:

* o tipo MIME do arquivo;
* os dados codificados em Base64.

Isso permite realizar download diretamente no navegador sem criar arquivo temporário no servidor.

---

# 6. Exibição de imagens armazenadas no banco

## Objetivo

Exibir imagens salvas no PostgreSQL diretamente no HTML.

## Código

```html
<img
    height="100px"
    width="100px"
    src="data:image/jpeg;base64,{{participante.fotoEncode}}"
>
```

## Função do código

A imagem armazenada como `byte[]` no banco é convertida para Base64 e exibida diretamente no navegador utilizando a tag `<img>`.

---

# Conclusão

Os exemplos demonstram uma arquitetura comum em aplicações Java Web:

1. Upload de arquivos via formulário HTML;
2. Conversão para `byte[]`;
3. Persistência utilizando JDBC;
4. Armazenamento no PostgreSQL (`BYTEA`);
5. Recuperação dos dados binários;
6. Conversão para Base64;
7. Exibição ou download no navegador.

Essa abordagem elimina a necessidade de salvar arquivos fisicamente no servidor, centralizando todos os dados diretamente no banco de dados.

