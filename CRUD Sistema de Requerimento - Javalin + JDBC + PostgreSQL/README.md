# ♨️ CRUD Completo de um Sistema de Requerimento - Java + PostgreSQL + JDBC + Javalin

## 📖 Visão Geral e Objetivo do Projeto

Criar uma aplicação web em Java para gerenciamento de requerimentos acadêmicos, utilizando o banco PostgreSQL já fornecido.

A aplicação deve utilizar:

    Javalin para criação do servidor web
    JDBC para comunicação com o banco
    Padrão DAO para acesso a dados
    Arquitetura em camadas

O sistema permitirá visualizar, criar e gerenciar requerimentos de alunos.

## 💻 Estrutura do Projeto - Instalação

O Maven é uma ferramenta de gerenciamento e automação de builds para projetos Java.

Ele permite:

Gerenciar dependências automaticamente
Padronizar estrutura de projetos
Automatizar compilação, testes e empacotamento
Facilitar integração com bibliotecas externas

O Maven utiliza um arquivo chamado:

```bash
pom.xml
```

Esse arquivo define:

- dependências
- versão do Java
- plugins
- configurações de build

### ⚙️ Pré-requisitos

- 1️⃣ Java JDK

Verifique se o Java está instalado:

```bash
java -version
javac -version
```

- 2️⃣ Maven

Verifique se o Maven está instalado:

```bash
mvn -version
```

Caso não esteja instalado, baixe em:

> https://maven.apache.org/download.cgi

### 🚀 Criando um Projeto Maven

- 1️⃣ Pressione ```Ctrl + Shift + P```
    * Isso Vai abrir a Paleta de Comandos no VsCode

- 2️⃣ Digite ```Maven: New Project```
    * Selecione essa opção quando ela aparecer.

- 3️⃣ Escolha um Archetype (modelo de projeto)
    * Selecione:
    ```bash
    maven-archetype-quickstart
    ```
    * Esse arquétipo cria um projeto Java básico já configurado.

- 4️⃣ Defina o GroupId
    * O GroupId representa a organização ou domínio do projeto.
    * Exemplo:
    ```bash
    com.exemplo
    ```

- 5️⃣ Defina o ArtifactId
    * O ArtifactId é o nome do projeto
    * Exemplo:
    ```bash
    sistema-requerimentos
    ```

- 6️⃣ Escolha a pasta onde o projeto será criado
    * O VSCode abrirá um explorador de arquivos para selecionar o diretório.

- 7️⃣ Aguarde a criação do projeto
    * O Maven irá gerar automaticamente a seguinte estrutura:
    ```bash
    sistema-requerimentos
    │
    ├── pom.xml
    └── src
        ├── main
        │   └── java
        │       └── com
        │           └── exemplo
        │               └── App.java
        │
        └── test
            └── java
    ```

- 📦 O que foi criado automaticamente?

| Arquivo/Pasta   | Função                                     |
| --------------- | ------------------------------------------ |
| `pom.xml`       | Arquivo principal de configuração do Maven |
| `src/main/java` | Código fonte da aplicação                  |
| `src/test/java` | Código de testes                           |
| `App.java`      | Classe inicial gerada automaticamente      |


Como vamos utilizar uma estrutura personalizada, podemos remover o pacote criado automaticamente:

```bash
com/exemplo
```

Depois criaremos nossa própria organização:

```bash
src/main/java/
apresentacao/
negocio/
persistencia/
```

Ao final nossa estrutura estará do seguinte modo:

```bash
src/main/java/

apresentacao/
    Main.java

negocio/
    Aluno.java
    Requerimento.java
    Curso.java
    TipoRequerimento.java

persistencia/
    ConexaoPostgreSQL.java
    AlunoDAO.java
    RequerimentoDAO.java
    TipoRequerimentoDAO.java
```