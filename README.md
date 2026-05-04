# 🗄️ Implementação e Operação em Banco de Dados

> Repositório da disciplina **Implementação e Operação em Banco de Dados** — material de aula, exercícios, scripts SQL e projetos práticos.

---

## 📋 Sobre a Disciplina

Esta disciplina aborda os fundamentos e a prática no desenvolvimento e administração de bancos de dados relacionais, cobrindo desde a modelagem até a integração com aplicações back-end.

**Ementa:**
- Modelo Relacional
- Linguagem para definição, manipulação e consulta de dados (SQL)
- Normalização
- Noções de programação em bancos de dados com **PostgreSQL**, **JDBC**, **Javalin** e **Mustache**

---

## 🗂️ Estrutura do Repositório

```
📦 bd-implementacao-operacao/
├── 📁 01-modelo-relacional/
│   ├── diagramas/          # Diagramas ER e relacionais
│   └── exercicios/         # Atividades práticas
│
├── 📁 02-sql/
│   ├── ddl/                # Scripts de definição (CREATE, ALTER, DROP)
│   ├── dml/                # Scripts de manipulação (INSERT, UPDATE, DELETE)
│   └── dql/                # Scripts de consulta (SELECT, JOIN, subconsultas)
│
├── 📁 03-normalizacao/
│   ├── exemplos/           # Exemplos de 1FN, 2FN, 3FN e BCNF
│   └── exercicios/         # Exercícios de normalização
│
├── 📁 04-postgresql/
│   ├── procedures/         # Stored procedures e functions
│   ├── triggers/           # Triggers e regras
│   └── views/              # Views e views materializadas
│
├── 📁 05-jdbc-javalin/
│   ├── src/                # Código-fonte Java
│   ├── pom.xml             # Dependências Maven
│   └── README.md           # Instruções do projeto
│
├── 📁 06-mustache/
│   ├── templates/          # Templates .mustache
│   └── exemplos/           # Integração com Javalin
│
├── 📁 projetos/
│   └── projeto-final/      # Projeto integrador da disciplina
│
└── 📁 recursos/
    ├── slides/             # Material de apoio das aulas
    └── referencias.md      # Referências bibliográficas
```

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Versão | Descrição |
|---|---|---|
| ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white) | 15+ | SGBD principal |
| ![Java](https://img.shields.io/badge/Java-ED8B00?style=flat&logo=openjdk&logoColor=white) | 17+ | Linguagem de programação |
| **JDBC** | — | Conectividade Java ↔ Banco de Dados |
| **Javalin** | 6+ | Framework web leve para Java |
| **Mustache** | — | Motor de templates para views |
| ![Maven](https://img.shields.io/badge/Maven-C71A36?style=flat&logo=apache-maven&logoColor=white) | 3.8+ | Gerenciador de dependências |

---

## 🚀 Como Executar os Projetos

### Pré-requisitos

- [Java JDK 17+](https://adoptium.net/)
- [PostgreSQL 15+](https://www.postgresql.org/download/)
- [Maven 3.8+](https://maven.apache.org/)
- [pgAdmin](https://www.pgadmin.org/) ou `psql` (cliente SQL)

### Configurando o Banco de Dados

```bash
# 1. Acesse o PostgreSQL
psql -U postgres

# 2. Crie o banco de dados da disciplina
CREATE DATABASE bd_disciplina;

# 3. Execute o script de inicialização
\i 04-postgresql/init.sql
```

### Executando a Aplicação Javalin

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/bd-implementacao-operacao.git
cd bd-implementacao-operacao/05-jdbc-javalin

# 2. Configure as variáveis de ambiente (ou edite application.properties)
export DB_URL=jdbc:postgresql://localhost:5432/bd_disciplina
export DB_USER=postgres
export DB_PASSWORD=sua_senha

# 3. Compile e execute
mvn clean install
mvn exec:java
```

A aplicação estará disponível em `http://localhost:7070`.

---

## 📚 Conteúdo Programático

### 1. Modelo Relacional
- Conceitos fundamentais: relações, tuplas, atributos e domínios
- Restrições de integridade: chave primária, chave estrangeira e unicidade
- Álgebra relacional

### 2. SQL — Linguagem de Banco de Dados
- **DDL** — `CREATE`, `ALTER`, `DROP`, `TRUNCATE`
- **DML** — `INSERT`, `UPDATE`, `DELETE`, `MERGE`
- **DQL** — `SELECT`, `JOIN`, subconsultas, funções de agregação, `GROUP BY`, `HAVING`
- **DCL** — `GRANT`, `REVOKE`
- **TCL** — `COMMIT`, `ROLLBACK`, `SAVEPOINT`

### 3. Normalização
- Dependências funcionais
- Primeira Forma Normal (1FN)
- Segunda Forma Normal (2FN)
- Terceira Forma Normal (3FN)
- Forma Normal de Boyce-Codd (BCNF)

### 4. Programação em PostgreSQL
- Stored procedures e functions (PL/pgSQL)
- Triggers e event triggers
- Views e views materializadas
- Índices e otimização de consultas
- Transações e controle de concorrência

### 5. Integração com JDBC + Javalin + Mustache
- Configuração e gerenciamento de conexões JDBC
- DAO (Data Access Object) pattern
- Rotas e controllers com Javalin
- Renderização de templates com Mustache
- Tratamento de erros e validação

---

## 📖 Referências Bibliográficas

- **SILBERSCHATZ, A.; KORTH, H. F.; SUDARSHAN, S.** *Sistema de Banco de Dados*. 7. ed. GEN LTC, 2020.
- **ELMASRI, R.; NAVATHE, S. B.** *Sistemas de Banco de Dados*. 6. ed. Pearson, 2011.
- **DATE, C. J.** *Introdução a Sistemas de Banco de Dados*. 8. ed. Campus, 2004.
- [Documentação oficial do PostgreSQL](https://www.postgresql.org/docs/)
- [Documentação do Javalin](https://javalin.io/documentation)
- [Especificação JDBC](https://docs.oracle.com/javase/tutorial/jdbc/)
- [Mustache Manual](https://mustache.github.io/mustache.5.html)

---

## 📝 Licença

Este repositório é de uso acadêmico. O conteúdo pode ser utilizado como referência de estudo.

---

<div align="center">
  <sub>Desenvolvido durante a graduação &mdash; Disciplina de Implementação e Operação em Banco de Dados</sub>
</div>
