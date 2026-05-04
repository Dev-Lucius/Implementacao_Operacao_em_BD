# 📘 Aula 01 — Revisão: Modelagem de Dados

> Revisão da disciplina anterior, **Modelagem de Dados**, aplicada na construção de um sistema de requerimentos acadêmicos em PostgreSQL.

---

## 🎯 Objetivo da Aula

Retomar os conceitos fundamentais de modelagem de banco de dados relacionais e consolidá-los na prática com a criação completa de um banco de dados real, desde a definição do esquema até consultas com múltiplos JOINs.

---

## 📚 Ementa Revisada

| # | Tópico |
|---|--------|
| 1 | Introdução aos conceitos básicos de banco de dados e SGBDs |
| 2 | Projeto de banco de dados |
| 3 | Modelagem conceitual, lógica e física de banco de dados relacionais |
| 4 | Noções de linguagem para implementação e operação (SQL) |

---

## 🗃️ Sistema Desenvolvido — `sistema_requerimento`

O banco de dados construído em aula modela um **sistema de requerimentos acadêmicos**, onde alunos vinculados a cursos podem abrir requerimentos de diferentes tipos (declarações, aproveitamentos, trancamentos), anexando documentos ao processo.

---

## 🧩 Modelagem

### Diagrama de Entidade-Relacionamento (Conceitual)

```
┌──────────┐       ┌─────────┐       ┌──────────────┐
│  usuario │ 1───1 │  aluno  │ N───1 │    curso     │
└──────────┘       └────┬────┘       └──────────────┘
                        │ 1
                        │
                        │ N
               ┌────────┴──────────┐
               │    requerimento   │ N───1 ┌───────────────────┐
               └────────┬──────────┘       │ tipo_requerimento │
                        │ 1                └───────────────────┘
                        │ N
                   ┌────┴────┐
                   │  anexo  │
                   └─────────┘
```

### Modelo Lógico — Tabelas e Relacionamentos

```
curso          (id PK, nome, site, turno, duracao)
usuario        (id PK, nome, email UQ, cpf UQ, data_nascimento, cep, complemento, numero)
tipo_req       (id PK, descricao)
aluno          (matricula PK, usuario_id FK → usuario, curso_id FK → curso)
requerimento   (id PK, aluno_matricula FK → aluno, data_hora_abertura, status, tipo_req_id FK → tipo_req)
anexo          (id PK, descricao, arquivo, requerimento_id FK → requerimento)
```

---

## 🏗️ Estrutura do Banco — DDL

### Criação do Banco

```sql
DROP DATABASE IF EXISTS sistema_requerimento;
CREATE DATABASE sistema_requerimento;
\c sistema_requerimento;
```

### Tabelas

<details>
<summary><strong>curso</strong></summary>

```sql
CREATE TABLE curso(
    id      SERIAL PRIMARY KEY,
    nome    VARCHAR(200) NOT NULL,
    site    VARCHAR(200) NOT NULL,
    turno   VARCHAR(20) CHECK (turno IN ('noturno', 'diurno', 'vespertino')),
    duracao INTEGER CHECK (duracao > 0) -- Duração em horas
);
```

> **Destaques:** uso de `CHECK` para restringir os valores aceitos em `turno` e garantir que a duração seja positiva.

</details>

<details>
<summary><strong>usuario</strong></summary>

```sql
CREATE TABLE usuario(
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(200) NOT NULL,
    email           VARCHAR(200) UNIQUE,
    cpf             CHAR(11) UNIQUE,
    data_nascimento DATE,
    cep             CHAR(8),
    complemento     TEXT,
    numero          VARCHAR(10)
);
```

> **Destaques:** `email` e `cpf` com restrição `UNIQUE`; `cpf` como `CHAR(11)` por ter tamanho fixo.

</details>

<details>
<summary><strong>tipo_requerimento</strong></summary>

```sql
CREATE TABLE tipo_requerimento(
    id      SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL
);
```

</details>

<details>
<summary><strong>aluno</strong></summary>

```sql
CREATE TABLE aluno(
    matricula  CHAR(10) PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(id),
    curso_id   INTEGER REFERENCES curso(id)
);
```

> **Destaques:** `matricula` como `CHAR(10)` e chave primária; duas chaves estrangeiras estabelecendo que um aluno É um usuário e PERTENCE a um curso.

</details>

<details>
<summary><strong>requerimento</strong></summary>

```sql
CREATE TABLE requerimento(
    id                  SERIAL PRIMARY KEY,
    aluno_matricula     CHAR(10) REFERENCES aluno(matricula),
    data_hora_abertura  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status              TEXT CHECK (status IN ('em análise', 'indeferido', 'deferido'))
                             DEFAULT 'em análise',
    tipo_requerimento_id INTEGER REFERENCES tipo_requerimento(id)
);
```

> **Destaques:** `DEFAULT CURRENT_TIMESTAMP` para registro automático da data/hora; `CHECK` + `DEFAULT` combinados no campo `status`.

</details>

<details>
<summary><strong>anexo</strong></summary>

```sql
CREATE TABLE anexo(
    id              SERIAL PRIMARY KEY,
    descricao       TEXT NOT NULL,
    arquivo         BYTEA,
    requerimento_id INTEGER REFERENCES requerimento(id)
);
```

> **Destaques:** tipo `BYTEA` para armazenamento binário de arquivos diretamente no banco.

</details>

---

## 📥 Dados de Exemplo — DML

```sql
-- Cursos
INSERT INTO curso (nome, site, turno, duracao) VALUES
('Sistemas de Informação', 'https://si.exemplo.edu.br',  'noturno',    3000),
('Administração',          'https://adm.exemplo.edu.br', 'diurno',     2800),
('Direito',                'https://dir.exemplo.edu.br', 'vespertino', 4000);

-- Usuários
INSERT INTO usuario (nome, email, cpf, data_nascimento, cep, complemento, numero) VALUES
('João Silva',     'joao@email.com',   '12345678901', '2000-05-10', '12345678', 'Apto 101', '100'),
('Maria Oliveira', 'maria@email.com',  '98765432100', '1999-08-22', '87654321', 'Casa',     '200'),
('Carlos Souza',   'carlos@email.com', '45678912300', '2001-01-15', '11223344', 'Bloco B',  '300');

-- Tipos de Requerimento
INSERT INTO tipo_requerimento (descricao) VALUES
('Declaração de Matrícula'),
('Aproveitamento de Disciplina'),
('Trancamento de Curso');

-- Alunos
INSERT INTO aluno (matricula, usuario_id, curso_id) VALUES
('2024000001', 1, 1),
('2024000002', 2, 2),
('2024000003', 3, 1);

-- Requerimentos
INSERT INTO requerimento (aluno_matricula, status, tipo_requerimento_id) VALUES
('2024000001', 'em análise', 1),
('2024000002', 'deferido',   2),
('2024000003', 'indeferido', 3);

-- Anexos
INSERT INTO anexo (descricao, arquivo, requerimento_id) VALUES
('Documento RG',              NULL, 1),
('Histórico Escolar',         NULL, 2),
('Comprovante de Pagamento',  NULL, 3);
```

---

## 🔍 Consultas — DQL

### 1. Requerimentos com nome do aluno

```sql
SELECT 
    usuario.nome             AS aluno_nome,
    requerimento.id          AS requerimento_id,
    requerimento.status,
    requerimento.data_hora_abertura
FROM requerimento
INNER JOIN aluno    ON aluno.matricula  = requerimento.aluno_matricula
INNER JOIN usuario  ON usuario.id       = aluno.usuario_id;
```

| aluno_nome | requerimento_id | status | data_hora_abertura |
|---|---|---|---|
| João Silva | 1 | em análise | 2024-… |
| Maria Oliveira | 2 | deferido | 2024-… |
| Carlos Souza | 3 | indeferido | 2024-… |

---

### 2. Requerimentos com descrição do tipo (`LEFT JOIN`)

```sql
SELECT 
    requerimento.id              AS requerimento_codigo,
    tipo_requerimento.descricao  AS descricao_requerimento
FROM requerimento
LEFT JOIN tipo_requerimento ON tipo_requerimento.id = requerimento.tipo_requerimento_id;
```

> **Por que `LEFT JOIN`?** Garante que requerimentos sem tipo associado também apareçam no resultado.

---

### 3. Nome do aluno + tipo do requerimento (cadeia de JOINs)

```sql
SELECT
    usuario.nome,
    tipo_requerimento.descricao
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
INNER JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;
```

---

## 💡 Conceitos-Chave Revisados

| Conceito | Aplicação no Sistema |
|---|---|
| **Chave Primária** (`PRIMARY KEY`) | `curso.id`, `aluno.matricula`, `requerimento.id` |
| **Chave Estrangeira** (`REFERENCES`) | `aluno → usuario`, `aluno → curso`, `requerimento → aluno` |
| **Restrição de domínio** (`CHECK`) | `turno IN (...)`, `status IN (...)`, `duracao > 0` |
| **Unicidade** (`UNIQUE`) | `usuario.email`, `usuario.cpf` |
| **Valor padrão** (`DEFAULT`) | `status DEFAULT 'em análise'`, `data_hora_abertura DEFAULT CURRENT_TIMESTAMP` |
| **Tipo binário** (`BYTEA`) | `anexo.arquivo` — armazenamento de arquivos |
| **`INNER JOIN`** | Retorna somente registros com correspondência em ambas as tabelas |
| **`LEFT JOIN`** | Retorna todos os registros da tabela esquerda, mesmo sem correspondência |

---

## 📁 Arquivos desta Aula

```
📁 aula-01/
├── 📄 README.md          # Este arquivo
└── 📄 sistema_requerimento.sql  # Script completo (DDL + DML + DQL)
```

---

<div align="center">
  <sub>🏫 Aula 01 &mdash; Revisão de Modelagem de Dados &nbsp;|&nbsp; Implementação e Operação em Banco de Dados</sub>
</div>