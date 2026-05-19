# Browsersync - AutoReload para o Javalin

Dentro desse projeto estamos usando o Mustache, os arquivos HTML precisam passar pelo Javalin para que as tags (como ``{{vetCurso}}``) sejam preenchidas com os dados do banco de dados. 

O Browsersync vai funcionar como um "espelho inteligente", atualizando o navegador sempre que você alterar o CSS ou o HTML.

> Eis Aqui um passo a passo completo para esses casos

---

## Passo 1 - Instalar o Browsersync na sua máquina

- O Browsersync roda através do Node.js. Se você ainda não tem o Node.js instalado, baixe a versão LTS no site oficial.

- Com o Node.js pronto, abra o terminal do seu computador (ou o terminal embutido da sua IDE) e instale o Browsersync globalmente:

```bash
npm install -g browser-sync
```

---

## Passo 2 - Ajustar o Javalin para ler os arquivos em tempo real

- Por padrão, o Java compila os arquivos de src/main/resources para uma pasta temporária (target ou build).

> **Se você alterar o CSS na pasta src, o Javalin não verá a mudança até que você recompile o projeto**

- Para resolver isso, vamos dizer ao Javalin para ler a pasta física do projeto em ambiente de desenvolvimento.

- Dentro do ``Main.java``, adicione a linha de ``staticFiles`` usando ``Location.EXTERNAL``:

```java
public static void main(String[] args) throws SQLException {
    Javalin.create(config -> {
        
        // 1. Configura o Mustache normalmente
        config.fileRenderer(new JavalinMustache());

        // 2. O PULO DO GATO: Aponta diretamente para a pasta física do seu código-fonte
        // Substitua pelo caminho correto da sua pasta onde ficam os HTMLs e CSS
        config.staticFiles.add("src/main/resources/templates", io.javalin.http.staticfiles.Location.EXTERNAL);

        // Habilita o CORS (você já fez isso, mantenha!)
        config.plugins.enableCors(cors -> {
            cors.add(it -> it.anyHost()); 
        });

        // ... suas rotas e outras configurações (Multipart, etc) ...

    }).start(7070); // Seu Javalin rodando na 7070
}
```

---

## Passo 3 - Iniciar o servidor Javalin

- Execute o seu projeto Java normalmente

    * clicando em Run na sua IDE;
    * usando comandos via Maven/Gradle.

---

## Passo 4 - Inicializar o Browsersync no Terminal

- Agora, abra o terminal na raiz do seu projeto (onde fica a pasta src) e execute o seguinte comando:

```bash
browser-sync start --proxy "localhost:7070" --files "src/main/resources/templates/**/*"
```
> **O que esse Comando Está Fazendo?**

- ``--proxy "localhost:7070":`` : Diz ao Browsersync para "escutar" o seu Javalin. Ele vai abrir uma nova porta (geralmente http://localhost:3000) que reflete exatamente o seu sistema Java.

- ``--files "src/main/resources/templates//*"`` : Diz ao Browsersync para ficar vigiando qualquer alteração em arquivos HTML, CSS ou JS dentro dessa pasta

---

## Passo 5 - O Fluxo de Trabalho no Dia a Dia

- A partir do momento em que o comando do passo 4 for executado, uma aba do navegador se abrirá automaticamente em ``http://localhost:3000.``

    - 1. Deixe o Javalin rodando de fundo.
    - 2. Acesse o sistema pela porta 3000 (e não pela 7070).
    - 3. Abra o seu arquivo CSS ou HTML na IDE e faça uma alteração (ex: mude a cor de fundo de um botão).
    - 4. Salve o arquivo (Ctrl + S ou Cmd + S).
    - 5. Browsersync vai notar a alteração, o Javalin vai ler o arquivo atualizado instantaneamente (graças ao Location.EXTERNAL)
    - 6. Por fim, a página no seu navegador vai atualizar sozinha no mesmo segundo, mantendo todos os dados do Mustache preenchidos na tela!


