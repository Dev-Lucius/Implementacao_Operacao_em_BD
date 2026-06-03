# 🐘 Apostila Completa de PostgreSQL
> **Do Iniciante ao Avançado** — Um guia prático, progressivo e de alta qualidade para dominar o PostgreSQL.

---

## 📌 Sumário

1. [Introdução ao PostgreSQL](#1-introdução-ao-postgresql)
2. [Modelagem de Dados](#2-modelagem-de-dados)
   - [Modelagem Conceitual (ER)](#21-modelagem-conceitual-er)
   - [Modelagem Lógica (Relacional)](#22-modelagem-lógica-relacional)
3. [DDL – Linguagem de Definição de Dados](#3-ddl--linguagem-de-definição-de-dados)
   - [Tipos de Dados](#31-tipos-de-dados)
   - [CREATE TABLE e Constraints](#32-create-table-e-constraints)
   - [ALTER TABLE e DROP](#33-alter-table-e-drop)
4. [DML – Linguagem de Manipulação de Dados](#4-dml--linguagem-de-manipulação-de-dados)
5. [Consultas Avançadas com SELECT](#5-consultas-avançadas-com-select)
   - [JOINs](#51-joins)
   - [Subqueries](#52-subqueries)
   - [CTEs – Common Table Expressions](#53-ctes--common-table-expressions)
   - [CASE WHEN](#54-case-when)
6. [Funções de Agregação e Agrupamento](#6-funções-de-agregação-e-agrupamento)
7. [Window Functions – Funções de Janela](#7-window-functions--funções-de-janela)
8. [Views – Visões](#8-views--visões)
9. [Transações e ACID](#9-transações-e-acid)
10. [PL/pgSQL – Funções e Procedimentos](#10-plpgsql--funções-e-procedimentos)
11. [Triggers – Gatilhos](#11-triggers--gatilhos)
12. [Herança – O Modelo Objeto-Relacional](#12-herança--o-modelo-objeto-relacional)
13. [Índices](#13-índices)
14. [JSON e JSONB](#14-json-e-jsonb)
15. [Particionamento de Tabelas](#15-particionamento-de-tabelas)
16. [Performance e Otimização](#16-performance-e-otimização)
17. [Boas Práticas e Padrões](#17-boas-práticas-e-padrões)
18. [Cheat Sheet Rápido](#18-cheat-sheet-rápido)

---

## 1. Introdução ao PostgreSQL

PostgreSQL (ou simplesmente "Postgres") é um **Sistema Gerenciador de Banco de Dados Relacional de código aberto**, reconhecido mundialmente por sua robustez, extensibilidade e conformidade com os padrões SQL.

Ao contrário de um SGBD puramente relacional, o PostgreSQL é classificado como **objeto-relacional** — ele incorpora conceitos de Orientação a Objetos (herança, tipos customizados, polimorfismo) diretamente na engine do banco.

### Por que PostgreSQL?

| Característica | Descrição |
|---|---|
| **Open Source** | Gratuito, com licença permissiva (sem vendor lock-in) |
| **ACID** | Garante integridade transacional completa |
| **Objeto-Relacional** | Herança, tipos customizados, funções em múltiplas linguagens |
| **Extensível** | PostGIS (geodados), TimescaleDB (séries temporais), pgvector (IA) |
| **Confiável** | Usado por Netflix, Instagram, Reddit, Nubank, iFood e grandes bancos |
| **Padrão SQL** | Alta conformidade com ANSI SQL |
| **JSONB Nativo** | Banco relacional + documental em uma única tecnologia |

### Conceitos Fundamentais

- **Database**: Contêiner lógico que agrupa tabelas, views, funções e outros objetos.
- **Schema**: Namespace dentro de um banco de dados. O padrão é `public`.
- **Table (Tabela)**: Estrutura bidimensional com linhas (tuplas) e colunas (atributos).
- **Row (Linha / Tupla)**: Um único registro de dados.
- **Column (Coluna / Atributo)**: Um campo de dados com um tipo específico.
- **Constraint**: Regra de integridade aplicada a colunas ou tabelas.
- **Index**: Estrutura auxiliar para acelerar consultas.
- **Transaction**: Unidade lógica de trabalho com garantias ACID.

### Comandos Essenciais do psql (CLI)

```bash
# Conectar ao banco
psql -U postgres -d nome_banco

# Usando URI completa
psql "postgresql://usuario:senha@host:5432/banco"
```

```sql
-- Dentro do terminal psql
\l              -- Listar todos os bancos de dados
\c meu_banco    -- Conectar a um banco específico
\dt             -- Listar tabelas do schema atual
\d nome_tabela  -- Descrever estrutura de uma tabela
\di             -- Listar índices
\dv             -- Listar views
\df             -- Listar funções
\dn             -- Listar schemas
\timing         -- Ativar/desativar medição de tempo das queries
\q              -- Sair do psql
```

---

## 2. Modelagem de Dados

A modelagem de dados ocorre em **três níveis progressivos**, do mais abstrato ao mais concreto:

```
Mundo Real ──► [Conceitual / ER] ──► [Lógico / Relacional] ──► [Físico / SQL DDL] ──► Banco de Dados
```

### 2.1 Modelagem Conceitual (ER)

O Modelo Entidade-Relacionamento (ER) descreve o domínio do problema de forma **independente de tecnologia**. É a linguagem de comunicação entre o analista e o cliente.

**Componentes Principais:**

| Elemento | Descrição |
|---|---|
| **Entidade Forte** | Existe por conta própria (ex: `Cliente`, `Produto`) |
| **Entidade Fraca** | Depende de outra entidade para existir (ex: `ItemPedido` dependendo de `Pedido`) |
| **Entidade Associativa** | Representa um relacionamento N:M com atributos próprios |
| **Atributo** | Propriedade de uma entidade |
| **Atributo Identificador** | Identifica unicamente cada instância (equivale à PK) |
| **Atributo Multivalorado** | Pode ter múltiplos valores (ex: telefones de um cliente) |
| **Atributo Composto** | Pode ser decomposto em sub-atributos (ex: endereço → rua, CEP, cidade) |
| **Relacionamento** | Associação semântica entre duas entidades |
| **Herança / Generalização** | Hierarquia entre entidades (ex: `PessoaFísica` e `PessoaJurídica` herdam de `Pessoa`) |

**Cardinalidade de Relacionamentos:**

| Notação | Leitura | Exemplo |
|---|---|---|
| `1:1` | Um para um | Um funcionário tem uma carteira de trabalho |
| `1:N` | Um para muitos | Um cliente tem muitos pedidos |
| `N:M` | Muitos para muitos | Alunos cursam muitas disciplinas |

**As 10 Regras de Ouro para Diagramas ER:**

1. **Evite loops** — Relacionamentos cíclicos geram ambiguidade e anomalias de consulta.
2. **Preste atenção ao sentido da cardinalidade** — Inverter a cardinalidade muda completamente o significado do modelo.
3. **Prefira atributos identificadores fortes** — Para evitar entidades fracas, crie sempre um campo `id` na entidade.
4. **Prefira entidades fortes** — Para evitar entidades associativas, transforme o relacionamento em uma nova entidade forte com seu próprio `id`.
5. **Evite relacionamentos ternários** — Quando possível, quebre-os em dois relacionamentos binários.
6. **Um atributo não pode ser multivalorado E composto ao mesmo tempo** — Se precisar das duas características, crie uma nova entidade separada com um relacionamento `1:N`.
7. **Se um relacionamento tem atributos, transforme-o em entidade** — Relacionamentos com dados próprios (ex: a nota de um aluno em uma disciplina) devem virar tabelas.
8. **Nomes de entidades são substantivos no singular** — `Cliente`, não `Clientes`.
9. **Nomes de relacionamentos são verbos** — `realiza`, `possui`, `contém`.
10. **Evite herança quando possível** — Prefira composição, pois herança gera complexidade de mapeamento e, no PostgreSQL, tem limitações de integridade referencial.

---

### 2.2 Modelagem Lógica (Relacional)

A modelagem lógica transforma o diagrama ER em tabelas relacionais, seguindo regras de mapeamento bem definidas.

**Regras de Mapeamento ER → Relacional:**

| Elemento ER | Resultado Relacional |
|---|---|
| Entidade Forte | Tabela |
| Entidade Fraca | Tabela com FK obrigatória para a entidade forte |
| Atributo Identificador | Coluna de Chave Primária (PK) |
| Atributo Simples | Coluna na tabela |
| Atributo Multivalorado | Nova tabela com FK para a tabela pai |
| Atributo Composto | Colunas separadas na mesma tabela (ou nova tabela se precisar de múltiplas instâncias) |
| Relacionamento 1:1 | FK em uma das tabelas (preferencialmente na de menor cardinalidade) |
| Relacionamento 1:N | FK na tabela do lado **N** |
| Relacionamento N:M | Tabela intermediária com 2 FKs |
| Relacionamento com atributos | Tabela intermediária com os atributos adicionais |
| Herança | Três estratégias possíveis (ver seção 12) |

**Exemplo de Mapeamento Completo:**

```
ER: Aluno (matrícula, nome) ──[cursou, nota]── Disciplina (código, nome)
     Cardinalidade: N:M com atributo "nota" no relacionamento

Resultado:
  Aluno(matrícula PK, nome)
  Disciplina(código PK, nome)
  Cursou(matrícula FK → Aluno, código FK → Disciplina, nota)
```

```
ER: Cliente (cpf, nome) ──1:N──  Pedido (numero, data)
                                 Pedido ──1:N── ItemPedido (quantidade, preco_unit)
                                                ItemPedido ──N:1── Produto (id, nome, preco)

Resultado:
  Cliente(cpf PK, nome)
  Pedido(numero PK, data, cpf FK → Cliente)
  Produto(id PK, nome, preco)
  ItemPedido(pedido_num FK → Pedido, produto_id FK → Produto, quantidade, preco_unit)
             └── PK composta: (pedido_num, produto_id)
```

---

## 3. DDL – Linguagem de Definição de Dados

DDL (Data Definition Language) é o conjunto de comandos SQL usado para **criar, alterar e remover estruturas** no banco de dados.

Os principais comandos são: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`.

---

### 3.1 Tipos de Dados

O PostgreSQL possui uma rica variedade de tipos nativos.

**Numéricos:**

| Tipo | Tamanho | Intervalo | Uso Recomendado |
|---|---|---|---|
| `SMALLINT` | 2 bytes | -32.768 a 32.767 | Números pequenos, enumerações |
| `INTEGER` / `INT` | 4 bytes | ~±2,1 bilhões | Uso geral |
| `BIGINT` | 8 bytes | ~±9,2 quintilhões | IDs grandes, contadores |
| `SERIAL` | 4 bytes | Auto-incremento | PKs simples (legado) |
| `BIGSERIAL` | 8 bytes | Auto-incremento grande | PKs em tabelas grandes |
| `DECIMAL(p,s)` | variável | Precisão exata | **Valores monetários** |
| `NUMERIC(p,s)` | variável | Precisão exata | Equivalente a DECIMAL |
| `REAL` | 4 bytes | ~6 dígitos decimais | Ponto flutuante |
| `DOUBLE PRECISION` | 8 bytes | ~15 dígitos decimais | Científico, coordenadas |

> ⚠️ **Atenção**: Para valores monetários, **sempre use `DECIMAL` ou `NUMERIC`**. Jamais use `FLOAT` ou `REAL` — eles possuem erros de arredondamento binário que podem gerar diferenças centesimais em cálculos financeiros.

**Texto:**

| Tipo | Descrição |
|---|---|
| `CHAR(n)` | String de tamanho **fixo**, preenchida com espaços |
| `VARCHAR(n)` | String de tamanho variável com limite máximo |
| `TEXT` | String de tamanho ilimitado |

> 💡 No PostgreSQL, `TEXT` e `VARCHAR` têm **desempenho idêntico**. Use `TEXT` para flexibilidade e `VARCHAR(n)` quando o limite de tamanho tem significado de negócio (ex: `CEP CHAR(8)`, `UF CHAR(2)`).

**Data e Hora:**

| Tipo | Exemplo | Obs. |
|---|---|---|
| `DATE` | `'2025-01-15'` | Apenas data |
| `TIME` | `'14:30:00'` | Apenas hora |
| `TIMESTAMP` | `'2025-01-15 14:30:00'` | Sem fuso horário |
| `TIMESTAMPTZ` | `'2025-01-15 14:30:00-03'` | **Com fuso horário (preferido)** |
| `INTERVAL` | `'3 hours'`, `'2 days 4 hours'` | Duração |

> ⚠️ **Prefira `TIMESTAMPTZ`** (`TIMESTAMP WITH TIME ZONE`) em sistemas que possam operar em múltiplos fusos. Evita bugs sutis ao mover o banco para outro servidor.

**Outros Tipos Importantes:**

| Tipo | Uso |
|---|---|
| `BOOLEAN` | `TRUE`, `FALSE`, `NULL` |
| `UUID` | Identificador único universal (ex: `gen_random_uuid()`) |
| `JSON` / `JSONB` | Dados semiestruturados (ver seção 14) |
| `ARRAY` | Listas de valores (`INTEGER[]`, `TEXT[]`) |
| `BYTEA` | Dados binários (arquivos pequenos) |
| `INET` / `CIDR` | Endereços IP e redes |
| `TSVECTOR` | Full-Text Search |
| `ENUM` | Tipo enumerado definido pelo usuário |

**Criando um ENUM:**

```sql
CREATE TYPE status_pedido AS ENUM ('pendente', 'aprovado', 'enviado', 'entregue', 'cancelado');

CREATE TABLE pedidos (
    id     BIGSERIAL         PRIMARY KEY,
    status status_pedido     NOT NULL DEFAULT 'pendente'
);
```

---

### 3.2 CREATE TABLE e Constraints

```sql
CREATE TABLE clientes (
    -- Identificação
    id            BIGSERIAL       PRIMARY KEY,
    cpf           CHAR(11)        NOT NULL UNIQUE,

    -- Informações pessoais
    nome          VARCHAR(150)    NOT NULL,
    email         TEXT            NOT NULL UNIQUE,
    nascimento    DATE,

    -- Financeiro
    saldo         DECIMAL(15, 2)  NOT NULL DEFAULT 0.00,

    -- Controle
    ativo         BOOLEAN         NOT NULL DEFAULT TRUE,
    criado_em     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Constraints nomeadas (melhor prática)
    CONSTRAINT chk_clientes_saldo   CHECK (saldo >= 0),
    CONSTRAINT chk_clientes_email   CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_clientes_cpf_len CHECK (LENGTH(cpf) = 11)
);
```

**Tipos de Constraints e seus papéis:**

| Constraint | Descrição | Permite NULL? |
|---|---|---|
| `PRIMARY KEY` | Identificador único + NOT NULL (implícito) | ❌ |
| `FOREIGN KEY` | Referência a outra tabela | ✅ (se não houver NOT NULL) |
| `UNIQUE` | Não permite duplicatas | ✅ (múltiplos NULLs são permitidos) |
| `NOT NULL` | Valor obrigatório | ❌ |
| `CHECK` | Regra de validação expressiva | N/A |
| `DEFAULT` | Valor aplicado quando omitido no INSERT | N/A |
| `EXCLUDE` | Exclusão de sobreposição (usado em ranges, geodados) | N/A |

**Foreign Keys com ações referenciais:**

```sql
CREATE TABLE pedidos (
    id            BIGSERIAL       PRIMARY KEY,
    cliente_id    BIGINT          NOT NULL,
    status        VARCHAR(20)     NOT NULL DEFAULT 'pendente',
    total         DECIMAL(12, 2)  NOT NULL CHECK (total > 0),
    criado_em     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id)
        ON DELETE RESTRICT    -- Impede deletar o cliente se ele tiver pedidos
        ON UPDATE CASCADE     -- Propaga a atualização do ID do cliente
);

-- ⚠️ FK não cria índice automaticamente — crie você mesmo!
CREATE INDEX idx_pedidos_cliente_id ON pedidos (cliente_id);
```

**Opções de `ON DELETE` / `ON UPDATE`:**

| Ação | Comportamento |
|---|---|
| `RESTRICT` | Bloqueia a operação na tabela pai se houver filhos |
| `CASCADE` | Propaga o `DELETE` ou `UPDATE` para os registros filhos |
| `SET NULL` | Define a FK como `NULL` nos registros filhos |
| `SET DEFAULT` | Define a FK como o valor `DEFAULT` nos registros filhos |
| `NO ACTION` | Similar ao `RESTRICT`, mas verificado ao final da transação |

---

### 3.3 ALTER TABLE e DROP

```sql
-- Adicionar nova coluna
ALTER TABLE clientes ADD COLUMN telefone VARCHAR(20);

-- Remover coluna (irreversível!)
ALTER TABLE clientes DROP COLUMN telefone;

-- Renomear coluna
ALTER TABLE clientes RENAME COLUMN nome TO nome_completo;

-- Alterar tipo de dado
ALTER TABLE clientes ALTER COLUMN saldo TYPE NUMERIC(20, 2);

-- Adicionar constraint
ALTER TABLE clientes
    ADD CONSTRAINT chk_nome_min CHECK (LENGTH(nome_completo) >= 2);

-- Remover constraint pelo nome
ALTER TABLE clientes DROP CONSTRAINT chk_nome_min;

-- Definir / remover valor DEFAULT
ALTER TABLE clientes ALTER COLUMN ativo SET DEFAULT TRUE;
ALTER TABLE clientes ALTER COLUMN ativo DROP DEFAULT;

-- Definir NOT NULL em coluna existente
-- (exige que não haja NULL na coluna antes de executar)
ALTER TABLE clientes ALTER COLUMN email SET NOT NULL;

-- Renomear tabela
ALTER TABLE clientes RENAME TO customers;

-- Remover tabela (sem aviso!)
DROP TABLE IF EXISTS logs;

-- Remover com cascata (remove objetos dependentes como views, FKs)
DROP TABLE IF EXISTS clientes CASCADE;

-- Esvaziar tabela (DDL — mais rápido que DELETE, sem WHERE, sem rollback)
TRUNCATE TABLE logs;

-- Esvaziar e reiniciar sequências (SERIALs)
TRUNCATE TABLE logs RESTART IDENTITY CASCADE;
```

---

## 4. DML – Linguagem de Manipulação de Dados

DML (Data Manipulation Language) opera sobre os **dados** dentro das tabelas: `INSERT`, `SELECT`, `UPDATE`, `DELETE`.

### 4.1 INSERT

```sql
-- Inserção simples
INSERT INTO clientes (cpf, nome, email)
VALUES ('12345678901', 'João Silva', 'joao@email.com');

-- Inserção de múltiplas linhas (mais eficiente que múltiplos INSERTs)
INSERT INTO clientes (cpf, nome, email) VALUES
    ('12345678901', 'João Silva',  'joao@email.com'),
    ('98765432100', 'Maria Souza', 'maria@email.com'),
    ('55544433322', 'Pedro Lima',  'pedro@email.com');

-- RETURNING: retorna dados do registro inserido/alterado
INSERT INTO clientes (cpf, nome, email)
VALUES ('11122233344', 'Ana Costa', 'ana@email.com')
RETURNING id, criado_em;

-- UPSERT — INSERT ou UPDATE em caso de conflito
INSERT INTO clientes (cpf, nome, email)
VALUES ('12345678901', 'João Santos', 'joaonovo@email.com')
ON CONFLICT (cpf)
    DO UPDATE SET
        nome  = EXCLUDED.nome,
        email = EXCLUDED.email;

-- Ignorar silenciosamente em caso de conflito
INSERT INTO clientes (cpf, nome, email)
VALUES ('12345678901', 'João', 'j@email.com')
ON CONFLICT (cpf) DO NOTHING;
```

> 💡 `EXCLUDED` é uma pseudo-tabela que representa os valores que **tentamos** inserir, disponível dentro do `ON CONFLICT DO UPDATE`.

---

### 4.2 SELECT (Fundamentos)

```sql
-- Seleção básica de colunas específicas
SELECT id, nome, email FROM clientes;

-- Alias de colunas e expressões calculadas
SELECT
    id,
    nome                  AS "Nome Completo",
    email                 AS "E-mail",
    saldo * 1.1           AS "Saldo com 10% de Bônus",
    AGE(nascimento)       AS "Idade"
FROM clientes;

-- Filtragem com WHERE e operadores lógicos
SELECT * FROM clientes
WHERE ativo = TRUE
  AND saldo > 1000
  AND nome ILIKE '%silva%';   -- ILIKE: comparação case-insensitive

-- Operadores de filtro especiais
SELECT * FROM clientes WHERE saldo    BETWEEN 100 AND 500;
SELECT * FROM clientes WHERE email    IN ('a@b.com', 'c@d.com');
SELECT * FROM clientes WHERE telefone IS NULL;
SELECT * FROM clientes WHERE telefone IS NOT NULL;
SELECT * FROM clientes WHERE nome     LIKE 'Jo%';      -- Começa com "Jo"
SELECT * FROM clientes WHERE nome     LIKE '%silva';   -- Termina com "silva"
SELECT * FROM clientes WHERE nome     LIKE '%ao%';     -- Contém "ao"
SELECT * FROM clientes WHERE nome     SIMILAR TO '(Jo|Ma)%'; -- Regex simplificada
SELECT * FROM clientes WHERE nome     ~ '^Jo';         -- Regex completa (case-sensitive)

-- Ordenação (múltiplos critérios, ASC/DESC por coluna)
SELECT * FROM clientes ORDER BY nome ASC, saldo DESC;

-- Paginação com LIMIT e OFFSET
SELECT * FROM clientes
ORDER BY id
LIMIT 10 OFFSET 20;  -- Página 3 (offset = (página - 1) * limite)

-- DISTINCT: eliminar linhas duplicadas
SELECT DISTINCT cidade FROM clientes ORDER BY cidade;
```

---

### 4.3 UPDATE

```sql
-- Atualização simples
UPDATE clientes
SET saldo = saldo + 100
WHERE id = 1;

-- Atualizar múltiplas colunas
UPDATE clientes
SET
    nome          = 'João Roberto Silva',
    email         = 'joaoroberto@email.com',
    atualizado_em = NOW()
WHERE id = 1
RETURNING id, nome, email;

-- UPDATE com dados de outra tabela (via FROM)
UPDATE pedidos
SET status = 'suspenso'
FROM clientes
WHERE pedidos.cliente_id = clientes.id
  AND clientes.ativo = FALSE;
```

---

### 4.4 DELETE

```sql
-- Deletar registro específico
DELETE FROM clientes WHERE id = 1;

-- Deletar com condição e retornar o que foi removido
DELETE FROM logs
WHERE criado_em < NOW() - INTERVAL '90 days'
RETURNING id, criado_em;

-- TRUNCATE: esvazia toda a tabela (DDL, sem transação parcial)
TRUNCATE TABLE logs;
TRUNCATE TABLE logs RESTART IDENTITY;  -- Reinicia o SERIAL também
```

> ⚠️ **Regra de Ouro**: Sempre use `WHERE` no `UPDATE` e no `DELETE`. Sem `WHERE`, você opera sobre **todas** as linhas da tabela. Uma boa prática é testar a condição com um `SELECT` antes de executar o `UPDATE`/`DELETE`.

---

## 5. Consultas Avançadas com SELECT

### 5.1 JOINs

JOINs combinam linhas de duas ou mais tabelas com base em uma condição de relacionamento.

**INNER JOIN** — Retorna apenas registros com correspondência em **ambas** as tabelas.

```sql
-- Pedidos e seus clientes (apenas pedidos com cliente cadastrado)
SELECT p.id AS pedido, c.nome AS cliente, p.total
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.id;
```

**LEFT JOIN** — Retorna **todos** os registros da tabela à esquerda, e os correspondentes da direita (NULL se não houver correspondência).

```sql
-- Todos os clientes, mesmo os que ainda não fizeram pedidos
SELECT c.nome, COUNT(p.id) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id
GROUP BY c.id, c.nome
ORDER BY total_pedidos DESC;
```

**RIGHT JOIN** — Inverso do LEFT JOIN. Na prática, reescreva como LEFT JOIN invertendo as tabelas para maior clareza.

**FULL OUTER JOIN** — Retorna todos os registros de ambas as tabelas, com NULL nas colunas sem correspondência.

```sql
SELECT c.nome, p.id AS pedido_id
FROM clientes c
FULL OUTER JOIN pedidos p ON p.cliente_id = c.id;
```

**CROSS JOIN** — Produto cartesiano: cada linha de A combinada com cada linha de B.

```sql
-- Útil para gerar combinações (ex: tamanhos × cores de camisetas)
SELECT cor.nome AS cor, tam.sigla AS tamanho
FROM cores cor
CROSS JOIN tamanhos tam;
```

**SELF JOIN** — Uma tabela unida com ela mesma. Útil para hierarquias.

```sql
-- Lista de funcionários com seus respectivos gerentes
SELECT
    f.nome AS funcionario,
    g.nome AS gerente
FROM funcionarios f
LEFT JOIN funcionarios g ON f.gerente_id = g.id
ORDER BY g.nome, f.nome;
```

**Resumo Visual dos Tipos de JOIN:**

```
INNER JOIN        LEFT JOIN         RIGHT JOIN        FULL OUTER JOIN
   ┌─┬─┐            ┌─┬─┐             ┌─┬─┐              ┌─┬─┐
   │ │█│            │█│█│             │ │█│              │█│█│
   └─┴─┘            └─┴─┘             └─┴─┘              └─┴─┘
  Só a intersecção  Tudo da esq.    Tudo da dir.       Tudo de ambos
```

---

### 5.2 Subqueries

Uma subquery é um `SELECT` aninhado dentro de outra instrução SQL.

```sql
-- Clientes com saldo acima da média geral
SELECT nome, saldo
FROM clientes
WHERE saldo > (SELECT AVG(saldo) FROM clientes);

-- Clientes que fizeram pelo menos um pedido acima de R$1.000
SELECT nome FROM clientes
WHERE id IN (
    SELECT DISTINCT cliente_id FROM pedidos
    WHERE total > 1000
);

-- EXISTS — mais eficiente que IN para grandes volumes
-- (para quando basta saber se existe, sem precisar do valor)
SELECT c.nome
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.cliente_id = c.id
      AND p.total > 500
);

-- Subquery no FROM (derived table / inline view)
SELECT cat.categoria, cat.preco_medio
FROM (
    SELECT categoria, AVG(preco) AS preco_medio
    FROM produtos
    GROUP BY categoria
) AS cat
WHERE cat.preco_medio > 100
ORDER BY cat.preco_medio DESC;
```

> 💡 **`EXISTS` vs `IN`**: Use `EXISTS` quando a subquery pode retornar muitas linhas — ele para na primeira correspondência. Use `IN` quando a lista de valores é pequena e conhecida.

---

### 5.3 CTEs – Common Table Expressions

CTEs (cláusula `WITH`) tornam consultas complexas mais **legíveis e reutilizáveis**, nomeando subqueries como blocos lógicos.

```sql
-- CTE básica: equivale a uma derived table nomeada
WITH clientes_ativos AS (
    SELECT id, nome, saldo
    FROM clientes
    WHERE ativo = TRUE
),
top_clientes AS (
    SELECT id, nome, saldo
    FROM clientes_ativos
    WHERE saldo > 5000
)
SELECT *
FROM top_clientes
ORDER BY saldo DESC;
```

**CTE Recursiva** — Ideal para percorrer hierarquias (organogramas, categorias em árvore, BFS/DFS em grafos).

```sql
-- Organograma: lista todos os subordinados de um gerente
WITH RECURSIVE hierarquia AS (
    -- Caso base: o funcionário raiz (sem gerente)
    SELECT id, nome, gerente_id, 1 AS nivel
    FROM funcionarios
    WHERE gerente_id IS NULL

    UNION ALL

    -- Caso recursivo: subordinados diretos de cada nível anterior
    SELECT f.id, f.nome, f.gerente_id, h.nivel + 1
    FROM funcionarios f
    INNER JOIN hierarquia h ON f.gerente_id = h.id
)
SELECT
    REPEAT('  ', nivel - 1) || nome AS estrutura,
    nivel
FROM hierarquia
ORDER BY nivel, nome;
```

---

### 5.4 CASE WHEN

Permite lógica condicional inline dentro de qualquer parte de uma query SQL.

```sql
-- Classifica clientes por faixa de saldo
SELECT
    nome,
    saldo,
    CASE
        WHEN saldo >= 10000 THEN 'Ouro'
        WHEN saldo >= 5000  THEN 'Prata'
        WHEN saldo >= 1000  THEN 'Bronze'
        ELSE 'Padrão'
    END AS categoria
FROM clientes
ORDER BY saldo DESC;

-- CASE com expressão (equivalente a switch/case)
SELECT
    id,
    CASE status
        WHEN 'A' THEN 'Ativo'
        WHEN 'I' THEN 'Inativo'
        WHEN 'S' THEN 'Suspenso'
        ELSE 'Desconhecido'
    END AS status_desc
FROM clientes;

-- CASE no ORDER BY para ordenação personalizada
SELECT nome, status
FROM pedidos
ORDER BY
    CASE status
        WHEN 'pendente'  THEN 1
        WHEN 'aprovado'  THEN 2
        WHEN 'enviado'   THEN 3
        WHEN 'entregue'  THEN 4
        WHEN 'cancelado' THEN 5
        ELSE 99
    END;

-- CASE como "pivot" manual
SELECT
    DATE_TRUNC('month', criado_em) AS mes,
    SUM(CASE WHEN status = 'entregue'  THEN total ELSE 0 END) AS receita_entregue,
    SUM(CASE WHEN status = 'cancelado' THEN total ELSE 0 END) AS receita_perdida,
    COUNT(CASE WHEN status = 'pendente' THEN 1 END)           AS pedidos_pendentes
FROM pedidos
GROUP BY DATE_TRUNC('month', criado_em)
ORDER BY mes;
```

---

## 6. Funções de Agregação e Agrupamento

### Funções de Agregação Principais

| Função | Descrição | Trata NULL? |
|---|---|---|
| `COUNT(*)` | Conta todas as linhas | Inclui NULLs |
| `COUNT(coluna)` | Conta valores não-NULL | Ignora NULLs |
| `COUNT(DISTINCT col)` | Conta valores únicos | Ignora NULLs |
| `SUM(coluna)` | Soma todos os valores | Ignora NULLs |
| `AVG(coluna)` | Média aritmética | Ignora NULLs |
| `MIN(coluna)` | Menor valor | Ignora NULLs |
| `MAX(coluna)` | Maior valor | Ignora NULLs |
| `STRING_AGG(col, sep)` | Concatena strings com separador | Ignora NULLs |
| `ARRAY_AGG(col)` | Agrega valores em um array | Inclui NULLs (use `FILTER`) |
| `BOOL_AND(col)` | TRUE se todos forem TRUE | — |
| `BOOL_OR(col)` | TRUE se ao menos um for TRUE | — |

### GROUP BY e HAVING

```sql
-- Resumo de clientes por cidade
SELECT
    cidade,
    COUNT(*)          AS total_clientes,
    AVG(saldo)        AS saldo_medio,
    SUM(saldo)        AS saldo_total,
    MAX(saldo)        AS maior_saldo
FROM clientes
GROUP BY cidade
ORDER BY total_clientes DESC;

-- HAVING filtra grupos APÓS a agregação
-- (WHERE filtra linhas ANTES da agregação — não pode usar funções de agregação)
SELECT
    categoria,
    COUNT(*)          AS qtd_produtos,
    AVG(preco)        AS preco_medio
FROM produtos
WHERE ativo = TRUE                   -- Filtro de linha (antes do agrupamento)
GROUP BY categoria
HAVING COUNT(*) > 5                  -- Filtro de grupo (depois do agrupamento)
   AND AVG(preco) > 50
ORDER BY preco_medio DESC;
```

> 💡 **Regra do GROUP BY**: Toda coluna no `SELECT` que **não** está dentro de uma função de agregação **obrigatoriamente** deve aparecer no `GROUP BY`.

### ROLLUP — Subtotais e Total Geral

```sql
SELECT
    COALESCE(regiao, '== TOTAL ==')                  AS regiao,
    COALESCE(cidade, '  Subtotal')                   AS cidade,
    SUM(total)                                       AS receita
FROM pedidos
INNER JOIN clientes c ON pedidos.cliente_id = c.id
GROUP BY ROLLUP(regiao, cidade)
ORDER BY regiao NULLS LAST, cidade NULLS LAST;
```

### Funções de String e Data Úteis em Agregações

```sql
-- Concatenar nomes de produtos por categoria
SELECT
    categoria,
    STRING_AGG(nome, ', ' ORDER BY nome) AS produtos
FROM produtos
GROUP BY categoria;

-- Agrupar por mês
SELECT
    DATE_TRUNC('month', criado_em) AS mes,
    COUNT(*)                       AS novos_clientes
FROM clientes
GROUP BY DATE_TRUNC('month', criado_em)
ORDER BY mes;

-- Funções utilitárias frequentes
SELECT
    UPPER(nome),
    LOWER(email),
    LENGTH(nome),
    TRIM(nome),
    SUBSTRING(nome FROM 1 FOR 10),
    REPLACE(email, '@', '[at]'),
    COALESCE(telefone, 'Não informado'),  -- Substituir NULL
    NULLIF(saldo, 0)                      -- Retorna NULL se saldo = 0
FROM clientes;
```

---

## 7. Window Functions – Funções de Janela

Window Functions executam cálculos sobre um **conjunto relacionado de linhas** (a "janela"), **sem colapsar as linhas** como o `GROUP BY` faz.

```
GROUP BY   →  10 linhas de entrada  →  3 linhas de saída (uma por grupo)
WINDOW FN  →  10 linhas de entrada  →  10 linhas de saída (detalhe preservado + cálculo)
```

**Sintaxe:**

```sql
função() OVER (
    PARTITION BY coluna_agrupamento   -- Divide em grupos (opcional)
    ORDER BY coluna_ordenacao         -- Ordem dentro de cada grupo
    ROWS BETWEEN ... AND ...          -- Define o "frame" da janela (opcional)
)
```

**Funções de Ranking:**

```sql
SELECT
    nome,
    departamento,
    salario,
    ROW_NUMBER()  OVER (PARTITION BY departamento ORDER BY salario DESC) AS row_num,
    RANK()        OVER (PARTITION BY departamento ORDER BY salario DESC) AS ranking,
    DENSE_RANK()  OVER (PARTITION BY departamento ORDER BY salario DESC) AS dense_rank,
    PERCENT_RANK() OVER (ORDER BY salario)                               AS pct_rank
FROM funcionarios;
```

| Função | Comportamento com empate | Exemplo (1°, 1°, 3°) |
|---|---|---|
| `ROW_NUMBER()` | Sem empate: número único e arbitrário | 1, 2, 3 |
| `RANK()` | Com saltos após empate | 1, 1, 3 |
| `DENSE_RANK()` | Sem saltos após empate | 1, 1, 2 |

**Funções de Acesso a Linhas Adjacentes:**

```sql
-- Variação de receita mês a mês
SELECT
    mes,
    receita,
    LAG(receita)  OVER (ORDER BY mes)  AS receita_mes_anterior,
    LEAD(receita) OVER (ORDER BY mes)  AS receita_proximo_mes,
    receita - LAG(receita) OVER (ORDER BY mes) AS variacao_absoluta,
    ROUND(
        (receita - LAG(receita) OVER (ORDER BY mes))
        / NULLIF(LAG(receita) OVER (ORDER BY mes), 0) * 100, 2
    ) AS variacao_pct
FROM receitas_mensais
ORDER BY mes;
```

**Funções de Agregação como Janela:**

```sql
-- Participação de cada produto na receita da sua categoria
SELECT
    nome,
    categoria,
    preco,
    SUM(preco)   OVER (PARTITION BY categoria)               AS total_categoria,
    ROUND(preco / SUM(preco) OVER (PARTITION BY categoria) * 100, 2) AS pct_categoria,
    AVG(preco)   OVER (PARTITION BY categoria)               AS media_categoria,

    -- Acumulado ordenado por preço
    SUM(preco)   OVER (
        PARTITION BY categoria
        ORDER BY preco
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado
FROM produtos
ORDER BY categoria, preco;
```

**NTILE — Divisão em Buckets:**

```sql
-- Classificar clientes em quartis de saldo
SELECT
    nome,
    saldo,
    NTILE(4) OVER (ORDER BY saldo) AS quartil
FROM clientes;
```

---

## 8. Views – Visões

Uma View é uma **consulta SQL salva com um nome**, que pode ser usada como se fosse uma tabela — sem armazenar dados fisicamente.

```sql
-- Criar view
CREATE VIEW vw_clientes_ativos AS
SELECT id, nome, email, saldo, criado_em
FROM clientes
WHERE ativo = TRUE;

-- Usar como tabela
SELECT * FROM vw_clientes_ativos WHERE saldo > 1000;

-- Atualizar a definição da view
CREATE OR REPLACE VIEW vw_clientes_ativos AS
SELECT id, nome, email, saldo, cidade, criado_em
FROM clientes
WHERE ativo = TRUE;

-- Remover view
DROP VIEW IF EXISTS vw_clientes_ativos;
```

**Quando usar Views:**

- Simplificar queries complexas com JOINs recorrentes
- Criar camada de abstração (ocultar colunas sensíveis)
- Controle de acesso: dar permissão à view sem expor a tabela
- Nomear queries de negócio ("relatório de clientes VIP")

---

### Views Materializadas

Uma View Materializada **armazena fisicamente** o resultado da query — funciona como uma tabela "cache". Precisa ser atualizada manualmente.

```sql
-- Criar view materializada
CREATE MATERIALIZED VIEW mv_relatorio_vendas AS
SELECT
    c.cidade,
    DATE_TRUNC('month', p.criado_em)  AS mes,
    COUNT(p.id)                        AS total_pedidos,
    SUM(p.total)                       AS receita_total,
    AVG(p.total)                       AS ticket_medio
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.id
WHERE p.status = 'entregue'
GROUP BY c.cidade, DATE_TRUNC('month', p.criado_em);

-- Criar índice para acelerar consultas na view materializada
CREATE INDEX idx_mv_relatorio_cidade_mes
    ON mv_relatorio_vendas (cidade, mes DESC);

-- Atualizar os dados (deve ser executado periodicamente)
REFRESH MATERIALIZED VIEW mv_relatorio_vendas;

-- Atualizar sem bloquear leituras (requer índice UNIQUE na view)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_relatorio_vendas;
```

**Comparativo: View vs View Materializada:**

| | View | View Materializada |
|---|---|---|
| **Dados** | Sempre ao vivo (executa na hora) | Dados armazenados (snapshot) |
| **Performance de leitura** | Depende da query base | Muito rápida (pré-computada) |
| **Índices** | Não | Sim |
| **Atualização** | Automática (sempre fresca) | Manual (`REFRESH`) |
| **Uso ideal** | Abstração, queries simples | Relatórios pesados, dashboards |

---

## 9. Transações e ACID

Uma **transação** é um conjunto de operações SQL tratadas como uma unidade indivisível: ou **tudo é confirmado** (`COMMIT`), ou **tudo é desfeito** (`ROLLBACK`).

### O Acrônimo ACID

| Propriedade | Significado | Exemplo prático |
|---|---|---|
| **A**tomicidade | Tudo ou nada — não existe estado parcial | Transferência bancária: débito + crédito juntos ou nenhum |
| **C**onsistência | O banco sempre passa de um estado válido para outro válido | Saldo nunca fica negativo se houver CHECK |
| **I**solamento | Transações concorrentes não se interferem | Dois saques simultâneos não "somam" para o mesmo saldo |
| **D**urabilidade | Dados confirmados persistem mesmo após falhas | Um `COMMIT` registrado no WAL sobrevive a um crash |

### Comandos de Controle de Transação

```sql
-- Iniciar transação explícita
BEGIN;                    -- ou: START TRANSACTION;

    UPDATE contas SET saldo = saldo - 500.00 WHERE id = 1;  -- Débito
    UPDATE contas SET saldo = saldo + 500.00 WHERE id = 2;  -- Crédito

COMMIT;    -- Confirma permanentemente

-- Em caso de erro ou decisão de abortar:
ROLLBACK;  -- Desfaz tudo desde o BEGIN
```

> 💡 No PostgreSQL, cada instrução SQL executada fora de um `BEGIN` explícito é **automaticamente** envolvida em uma transação individual (autocommit).

### Savepoints – Controle Granular

```sql
BEGIN;

    INSERT INTO pedidos (cliente_id, total) VALUES (1, 500.00) RETURNING id;

    SAVEPOINT sp_pedido;  -- Marca um ponto de restauração

    INSERT INTO itens_pedido (pedido_id, produto_id, qtd) VALUES (1, 10, 2);
    INSERT INTO itens_pedido (pedido_id, produto_id, qtd) VALUES (1, 99, 1); -- Produto inexistente!

    -- Ocorreu um erro nos itens — volta ao ponto seguro sem perder o pedido
    ROLLBACK TO SAVEPOINT sp_pedido;

    -- Continua com outra tentativa...
    INSERT INTO itens_pedido (pedido_id, produto_id, qtd) VALUES (1, 10, 3);

COMMIT;
```

### Níveis de Isolamento

Controlam como transações concorrentes se "enxergam". Há quatro anomalias possíveis:

- **Dirty Read**: Ler dados de uma transação não confirmada
- **Non-Repeatable Read**: Releitura da mesma linha retorna valor diferente
- **Phantom Read**: Nova linha aparece/desaparece entre duas consultas idênticas

| Nível | Dirty Read | Non-Repeatable | Phantom |
|---|---|---|---|
| `READ UNCOMMITTED` | ✅ Possível | ✅ | ✅ |
| `READ COMMITTED` *(padrão PG)* | ❌ Não | ✅ | ✅ |
| `REPEATABLE READ` | ❌ Não | ❌ Não | ✅ |
| `SERIALIZABLE` | ❌ Não | ❌ Não | ❌ Não |

```sql
-- Definir nível de isolamento para a transação
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    -- operações
COMMIT;
```

---

## 10. PL/pgSQL – Funções e Procedimentos

PL/pgSQL é a linguagem procedural nativa do PostgreSQL. Ela combina SQL com estruturas de programação (variáveis, condicionais, loops, exceções).

### Funções (`FUNCTION`)

```sql
-- Função simples com parâmetros e retorno escalar
CREATE OR REPLACE FUNCTION calcular_desconto(
    p_preco    DECIMAL,
    p_pct_desc DECIMAL DEFAULT 10.0   -- parâmetro com valor padrão
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    v_desconto    DECIMAL;
    v_preco_final DECIMAL;
BEGIN
    v_desconto    := p_preco * (p_pct_desc / 100.0);
    v_preco_final := p_preco - v_desconto;
    RETURN v_preco_final;
END;
$$;

-- Usando a função em uma query
SELECT nome, preco, calcular_desconto(preco, 15) AS preco_com_desconto
FROM produtos
ORDER BY preco DESC;
```

**Função que retorna um conjunto de linhas (`TABLE`):**

```sql
CREATE OR REPLACE FUNCTION buscar_top_clientes(p_saldo_min DECIMAL)
RETURNS TABLE(id BIGINT, nome TEXT, email TEXT, saldo DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT c.id, c.nome, c.email, c.saldo
        FROM clientes c
        WHERE c.ativo = TRUE
          AND c.saldo >= p_saldo_min
        ORDER BY c.saldo DESC;
END;
$$;

-- Uso
SELECT * FROM buscar_top_clientes(5000.00);
```

### Procedures (`PROCEDURE`)

Procedures são executadas com `CALL` e **podem controlar transações** internamente.

```sql
-- Procedure de transferência bancária com validações
CREATE OR REPLACE PROCEDURE transferir_saldo(
    p_origem  BIGINT,
    p_destino BIGINT,
    p_valor   DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo_origem DECIMAL;
BEGIN
    -- Bloquear a linha origem para evitar race condition
    SELECT saldo INTO v_saldo_origem
    FROM contas WHERE id = p_origem
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conta de origem % não encontrada.', p_origem;
    END IF;

    IF v_saldo_origem < p_valor THEN
        RAISE EXCEPTION 'Saldo insuficiente. Disponível: R$%, Solicitado: R$%',
                        v_saldo_origem, p_valor;
    END IF;

    UPDATE contas SET saldo = saldo - p_valor WHERE id = p_origem;
    UPDATE contas SET saldo = saldo + p_valor WHERE id = p_destino;

    INSERT INTO transferencias (origem_id, destino_id, valor, realizado_em)
    VALUES (p_origem, p_destino, p_valor, NOW());

    RAISE NOTICE 'Transferência de R$% realizada com sucesso.', p_valor;
END;
$$;

-- Chamada
CALL transferir_saldo(1, 2, 500.00);
```

### Estruturas de Controle

```sql
-- IF / ELSIF / ELSE
IF saldo > 10000 THEN
    categoria := 'VIP';
ELSIF saldo > 1000 THEN
    categoria := 'Premium';
ELSE
    categoria := 'Padrão';
END IF;

-- Loop simples com EXIT
FOR i IN 1..10 LOOP
    EXIT WHEN i = 5;          -- Sai do loop quando i = 5
    CONTINUE WHEN i = 3;      -- Pula iteração quando i = 3
    -- processamento
END LOOP;

-- Loop iterando sobre resultado de query
FOR registro IN SELECT * FROM clientes WHERE ativo = TRUE LOOP
    RAISE NOTICE 'Processando cliente: %', registro.nome;
    -- acesso: registro.id, registro.nome, registro.email, etc.
END LOOP;

-- WHILE
WHILE contador < 100 LOOP
    contador := contador + 1;
END LOOP;

-- Tratamento de exceções
BEGIN
    INSERT INTO clientes (cpf, nome) VALUES ('123', 'Teste');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'CPF já cadastrado: %', SQLERRM;
    WHEN check_violation THEN
        RAISE NOTICE 'Dado inválido: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro inesperado: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
```

**Diferença FUNCTION vs PROCEDURE:**

| | `FUNCTION` | `PROCEDURE` |
|---|---|---|
| **Retorno** | Sempre retorna um valor | Pode não retornar nada |
| **Uso em SELECT** | ✅ Sim (`SELECT fn()`) | ❌ Não |
| **Chamada** | `SELECT func(args)` | `CALL proc(args)` |
| **Controle de transação** | Não pode `COMMIT`/`ROLLBACK` | Pode controlar transações |

---

## 11. Triggers – Gatilhos

Triggers executam automaticamente uma **função** quando um evento DML (`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`) ocorre em uma tabela.

**Anatomia de um Trigger:**

```
[BEFORE | AFTER | INSTEAD OF]
[INSERT | UPDATE | DELETE | TRUNCATE]
ON tabela
[FOR EACH ROW | FOR EACH STATEMENT]
→ EXECUTE FUNCTION nome_da_funcao()
```

### Exemplo 1: Auditoria Automática

```sql
-- 1. Tabela de auditoria
CREATE TABLE auditoria_clientes (
    id           SERIAL      PRIMARY KEY,
    cliente_id   BIGINT,
    operacao     CHAR(1)     NOT NULL CHECK (operacao IN ('I','U','D')),
    dados_antes  JSONB,
    dados_depois JSONB,
    usuario      TEXT        NOT NULL DEFAULT current_user,
    momento      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Função do trigger (deve retornar TRIGGER)
CREATE OR REPLACE FUNCTION fn_auditar_clientes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_clientes (cliente_id, operacao, dados_depois)
        VALUES (NEW.id, 'I', to_jsonb(NEW));

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_clientes (cliente_id, operacao, dados_antes, dados_depois)
        VALUES (NEW.id, 'U', to_jsonb(OLD), to_jsonb(NEW));

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_clientes (cliente_id, operacao, dados_antes)
        VALUES (OLD.id, 'D', to_jsonb(OLD));
    END IF;

    RETURN NEW;
END;
$$;

-- 3. Associar o trigger à tabela
CREATE TRIGGER tg_after_clientes_audit
    AFTER INSERT OR UPDATE OR DELETE
    ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditar_clientes();
```

### Exemplo 2: Normalização Automática (BEFORE)

```sql
-- Normaliza e valida o email antes de salvar
CREATE OR REPLACE FUNCTION fn_normalizar_email()
RETURNS TRIGGER AS $$
BEGIN
    -- Normalizar
    NEW.email := LOWER(TRIM(NEW.email));

    -- Validar
    IF NEW.email NOT LIKE '%@%.%' THEN
        RAISE EXCEPTION 'Email inválido: ''%''', NEW.email;
    END IF;

    RETURN NEW;  -- Em triggers BEFORE, retornar NEW confirma a operação
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_before_clientes_email
    BEFORE INSERT OR UPDATE OF email
    ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fn_normalizar_email();
```

### Exemplo 3: Atualizar `atualizado_em` Automaticamente

```sql
CREATE OR REPLACE FUNCTION fn_set_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_before_update_timestamp
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_atualizado_em();
```

**Variáveis Especiais em Triggers:**

| Variável | Tipo | Disponível em |
|---|---|---|
| `NEW` | RECORD | `INSERT`, `UPDATE` |
| `OLD` | RECORD | `UPDATE`, `DELETE` |
| `TG_OP` | TEXT | Todos (`'INSERT'`, `'UPDATE'`, `'DELETE'`) |
| `TG_TABLE_NAME` | TEXT | Todos |
| `TG_WHEN` | TEXT | Todos (`'BEFORE'`, `'AFTER'`) |
| `TG_LEVEL` | TEXT | Todos (`'ROW'`, `'STATEMENT'`) |

---

## 12. Herança – O Modelo Objeto-Relacional

O PostgreSQL é um banco **objeto-relacional**: ele implementa herança entre tabelas diretamente na engine, sem necessidade de código adicional.

### Como Funciona Internamente

- A tabela filha **aponta** para a tabela mãe (relação de ancestralidade nos catálogos).
- Cada tabela (mãe e filhas) possui seu próprio **arquivo físico** de armazenamento.
- Um `SELECT` na tabela mãe retorna dados dela **e de todas as filhas** (polimorfismo).

### Exemplo: Sistema de E-commerce

```sql
-- Tabela mãe (atributos comuns a todos os produtos)
CREATE TABLE produtos (
    id            SERIAL,
    nome          VARCHAR(100)   NOT NULL,
    preco         DECIMAL(10, 2) NOT NULL,
    data_cadastro TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- Filha 1: herda id, nome, preco, data_cadastro + adiciona novos campos
CREATE TABLE produtos_fisicos (
    peso      FLOAT        NOT NULL,
    dimensoes VARCHAR(50)
) INHERITS (produtos);

-- Filha 2: herda id, nome, preco, data_cadastro + adiciona novos campos
CREATE TABLE produtos_digitais (
    tamanho_arquivo_mb INT  NOT NULL,
    link_download      TEXT NOT NULL
) INHERITS (produtos);
```

### Inserção e Consulta

```sql
-- Inserir em cada tabela filha
INSERT INTO produtos_fisicos (nome, preco, peso, dimensoes)
VALUES ('Cadeira Gamer', 1200.00, 18.5, '120x60x60cm');

INSERT INTO produtos_digitais (nome, preco, tamanho_arquivo_mb, link_download)
VALUES ('Curso de PostgreSQL', 49.90, 25, 'https://site.com/download');

-- Inserir diretamente na mãe
INSERT INTO produtos (nome, preco)
VALUES ('Serviço de Consultoria', 250.00);

-- SELECT polimórfico: retorna dados da mãe + todas as filhas
SELECT id, nome, preco FROM produtos;

-- SELECT exclusivo da tabela mãe (ignora filhas)
SELECT id, nome, preco FROM ONLY produtos;

-- Identificar a origem de cada registro
SELECT tableoid::regclass AS tabela_origem, nome, preco
FROM produtos;
```

### ⚠️ Limitações Críticas — Leia com atenção!

| Tipo de Restrição / Comportamento | É herdado? |
|---|---|
| Colunas e tipos de dados | ✅ Sim |
| `DEFAULT` | ✅ Sim |
| `NOT NULL` | ✅ Sim |
| **`PRIMARY KEY`** | ❌ Não |
| **`UNIQUE`** | ❌ Não |
| **`CHECK`** | ❌ Não |
| **`FOREIGN KEY`** | ❌ Não |
| **Índices** | ❌ Não |
| **Triggers** | ❌ Não |

> ❗ **Consequência grave**: Sem `PRIMARY KEY` global, você pode ter `id = 1` em `produtos_fisicos` **e** `id = 1` em `produtos_digitais`. Uma FK de `itens_pedido` apontando para `produtos(id)` **não conseguirá** validar os IDs das tabelas filhas — gerando inconsistências silenciosas.

### Quando Usar (e Quando Não Usar) Herança

**✅ Use herança para:**
- Particionamento manual (histórico de logs por ano, ex: `logs_2023`, `logs_2024`)
- Organização lógica sem dependência de integridade referencial entre filhas
- Leitura consolidada onde você quer consultar tudo com um único `SELECT`

**❌ Evite herança quando:**
- O sistema depende de `FOREIGN KEY` que referencia a tabela mãe
- Você precisa de `UNIQUE` ou `PRIMARY KEY` global entre mãe e filhas
- É um sistema transacional puro (use uma das estratégias alternativas abaixo)

### As Três Estratégias de Mapeamento de Herança

| Estratégia | Estrutura | Vantagens | Desvantagens |
|---|---|---|---|
| **1 tabela única** (Table Per Hierarchy) | Todos os campos numa tabela + coluna discriminadora (`tipo`) | FK simples, queries simples | Muitas colunas `NULL`; tabela cresce muito |
| **Tabela por entidade filha** (Table Per Concrete Class) | Cada filha tem todos os campos (repete os da mãe) | Sem `NULL` desnecessário; independente | Dados comuns duplicados; `SELECT` global exige `UNION ALL` |
| **Tabela por entidade** (Table Per Class / Normalizada) | Uma tabela por entidade + `JOIN` para montar o objeto completo | Totalmente normalizado; FK e `UNIQUE` funcionam | `JOIN` necessário em toda consulta |

---

## 13. Índices

Índices são estruturas auxiliares que permitem ao PostgreSQL localizar registros **sem varrer a tabela inteira** (sequential scan), de forma análoga ao índice remissivo de um livro.

> ⚠️ **Custo dos índices**: Todo índice ocupa espaço em disco e precisa ser atualizado a cada `INSERT`, `UPDATE` ou `DELETE`. Crie índices com propósito definido, não por precaução.

### Tipos de Índices

**1. B-Tree (padrão) — o mais versátil**

```sql
CREATE INDEX idx_clientes_nome ON clientes (nome);
```

Ideal para: `=`, `<`, `>`, `<=`, `>=`, `BETWEEN`, `ORDER BY`, `IN`, `LIKE 'prefixo%'`.

**2. Hash — igualdade pura**

```sql
CREATE INDEX idx_clientes_email_hash ON clientes USING HASH (email);
```

Ideal para: apenas `=`. Pode ser ligeiramente mais rápido que B-Tree para lookups de igualdade pura, sem ordenação.

**3. GIN (Generalized Inverted Index) — dados compostos**

```sql
-- Para JSONB
CREATE INDEX idx_produtos_props_gin ON produtos USING GIN (properties);

-- Para Full-Text Search
CREATE INDEX idx_posts_fts ON posts
    USING GIN (to_tsvector('portuguese', conteudo));

-- Para arrays
CREATE INDEX idx_artigos_tags_gin ON artigos USING GIN (tags);
```

Ideal para: `JSONB` (operadores `@>`, `?`, `?|`), `ARRAY`, Full-Text Search.

**4. GiST (Generalized Search Tree) — geometria e ranges**

```sql
CREATE INDEX idx_locations_gist ON locations USING GIST (geom);
```

Ideal para: dados geoespaciais (PostGIS), busca por similaridade, `RANGE` types, operadores de sobreposição.

**5. BRIN (Block Range INdex) — tabelas muito grandes**

```sql
CREATE INDEX idx_logs_criado_brin ON logs USING BRIN (criado_em);
```

Ideal para: tabelas **muito grandes** com dados **naturalmente ordenados** (timestamps, IDs sequenciais). Ocupa **muito menos espaço** que B-Tree, mas é menos preciso.

---

### Índices Especializados

```sql
-- UNIQUE: garante unicidade na coluna
CREATE UNIQUE INDEX idx_clientes_cpf_unique ON clientes (cpf);

-- Parcial: indexa apenas um subconjunto das linhas
-- (menor e mais rápido para queries que usam a mesma condição)
CREATE INDEX idx_clientes_email_ativos ON clientes (email)
WHERE ativo = TRUE;

-- Composto: múltiplas colunas (atenção à ordem!)
-- Esta query se beneficia:  WHERE cliente_id = 1 ORDER BY criado_em DESC
CREATE INDEX idx_pedidos_cliente_data ON pedidos (cliente_id, criado_em DESC);

-- Em expressão: indexa o resultado de uma função
CREATE INDEX idx_clientes_email_lower ON clientes (LOWER(email));
-- Agora esta query usa o índice:
SELECT * FROM clientes WHERE LOWER(email) = 'joao@email.com';
```

---

### EXPLAIN ANALYZE — Entendendo o Plano de Execução

```sql
EXPLAIN ANALYZE
SELECT c.nome, SUM(p.total)
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id
WHERE c.cidade = 'Porto Alegre'
GROUP BY c.nome;
```

**Termos do plano de execução:**

| Termo | Significado |
|---|---|
| `Seq Scan` | Varredura sequencial (sem índice) |
| `Index Scan` | Usando índice para encontrar e acessar a heap |
| `Index Only Scan` | Resposta completa via índice, sem acessar a heap (mais eficiente) |
| `Bitmap Heap Scan` | Lê múltiplos blocos identificados via índice |
| `Hash Join` | Join usando tabela hash em memória |
| `Nested Loop` | Join com loop aninhado (bom para tabelas pequenas) |
| `Merge Join` | Join com dados pré-ordenados |
| `cost=X..Y` | Custo estimado: X = startup (primeira linha), Y = total |
| `actual time=X..Y` | Tempo real de execução em ms |
| `rows=N` | Número de linhas processadas |
| `Buffers: shared hit=N` | Blocos lidos do cache (bom) vs. `read=N` (do disco) |

---

### Quando Criar (e Não Criar) Índices

| **Crie índice ✅** | **Não crie índice ❌** |
|---|---|
| Colunas usadas frequentemente no `WHERE` | Tabelas pequenas (< ~1.000 linhas) |
| Colunas de `JOIN ON` (especialmente FKs!) | Colunas raramente consultadas |
| Colunas de `ORDER BY` em queries frequentes | Colunas com baixa seletividade (boolean, status c/ 3 valores) |
| PKs (automático) e FKs (manual!) | Tabelas com altíssima taxa de escrita |

> 💡 **Dica importante**: FKs no PostgreSQL **não criam índice automaticamente** na coluna filha. Sempre crie o índice manualmente para evitar sequential scans nos `JOIN`s:
>
> ```sql
> ALTER TABLE pedidos ADD CONSTRAINT fk_pedidos_clientes
>     FOREIGN KEY (cliente_id) REFERENCES clientes(id);
>
> -- Criar manualmente o índice da FK!
> CREATE INDEX idx_pedidos_cliente_id ON pedidos (cliente_id);
> ```

---

### O que a PRIMARY KEY cria automaticamente

```sql
-- Este comando:
CREATE TABLE users (
    id    SERIAL PRIMARY KEY,
    nome  TEXT,
    email TEXT
);

-- É equivalente a:
CREATE TABLE users (id SERIAL, nome TEXT, email TEXT);
ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
-- E internamente: CREATE UNIQUE INDEX users_pkey ON users (id);
```

**Resumo das constraints e seus índices:**

| Constraint | Cria índice automaticamente? | Tipo |
|---|---|---|
| `PRIMARY KEY` | ✅ Sim | B-Tree único |
| `UNIQUE` | ✅ Sim | B-Tree único |
| `FOREIGN KEY` | ❌ Não | (crie manualmente!) |

---

## 14. JSON e JSONB

PostgreSQL permite armazenar dados semiestruturados nativamente com suporte completo a operadores, indexação e funções.

### Diferença: JSON vs JSONB

| Recurso | `JSON` | `JSONB` |
|---|---|---|
| Armazenamento | Texto exato (verbatim) | Binário pré-processado |
| Velocidade de escrita | Mais rápido | Ligeiramente mais lento |
| Velocidade de leitura/query | Mais lento (reparsa cada vez) | Mais rápido (já parseado) |
| Indexação | Limitada | Completa (GIN, etc.) |
| Preserva ordem das chaves | ✅ Sim | ❌ Não |
| Chaves duplicadas | Permite (retém a última) | Não permite |
| **Uso recomendado** | Preservar formato exato | **Quase todos os casos** |

> ✅ **Regra prática**: Use sempre `JSONB`. Use `JSON` apenas se a aplicação exige preservar a ordem original das chaves ou o formato exato do documento.

---

### Criação, Inserção e Consulta

```sql
-- 1. Tabela com JSONB
CREATE TABLE produtos (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(255) NOT NULL,
    properties JSONB
);

-- 2. Inserção (string JSON dentro de aspas simples)
INSERT INTO produtos (nome, properties) VALUES
    ('Camiseta Fusion',  '{"cor": "branco", "tamanhos": ["P","M","G","GG"], "preco_custo": 15.00}'),
    ('Camiseta ThreadV', '{"cor": "preto",  "tamanhos": ["P","M","G"],      "preco_custo": 12.00}'),
    ('Camiseta Dynamo',  '{"cor": "azul",   "tamanhos": ["M","G"],          "preco_custo": 10.00}');

-- 3. Operadores de acesso
SELECT
    nome,
    properties -> 'cor'            AS cor_json,     -- "branco" (com aspas JSON)
    properties ->> 'cor'           AS cor_texto,    -- branco (texto puro)
    properties -> 'tamanhos'       AS tamanhos,     -- ["P","M","G","GG"]
    properties -> 'tamanhos' ->> 0 AS primeiro_tam  -- P (índice 0 do array)
FROM produtos;
```

### Tabela Completa de Operadores JSONB

| Operador | Retorno | Descrição | Exemplo |
|---|---|---|---|
| `->` | JSON/JSONB | Acessa por chave ou índice | `props -> 'cor'` → `"branco"` |
| `->>` | TEXT | Acessa por chave/índice como texto | `props ->> 'cor'` → `branco` |
| `#>` | JSON/JSONB | Acessa por caminho aninhado | `props #> '{itens,0}'` |
| `#>>` | TEXT | Caminho aninhado como texto | `props #>> '{itens,0,nome}'` |
| `?` | BOOLEAN | Chave existe no nível raiz? | `props ? 'desconto'` |
| `?|` | BOOLEAN | Alguma das chaves existe? | `props ?| ARRAY['cor','tam']` |
| `?&` | BOOLEAN | Todas as chaves existem? | `props ?& ARRAY['cor','tam']` |
| `@>` | BOOLEAN | Contém o subconjunto JSON? | `props @> '{"cor":"azul"}'` |
| `<@` | BOOLEAN | Está contido no JSON? | `'{"cor":"azul"}' <@ props` |
| `\|\|` | JSONB | Merge (união) de dois JSONB | `props \|\| '{"novo":"val"}'` |
| `-` | JSONB | Remove chave | `props - 'cor'` |

---

### Filtragem e Atualização

```sql
-- Filtrar por valor de campo JSON
SELECT nome FROM produtos
WHERE properties ->> 'cor' = 'branco';

-- Filtrar usando containment (mais eficiente com GIN)
SELECT nome FROM produtos
WHERE properties @> '{"cor": "branco"}';

-- Verificar se tamanho GG existe no array
SELECT nome FROM produtos
WHERE properties -> 'tamanhos' ? 'GG';

-- Adicionar/sobrescrever campo (merge)
UPDATE produtos
SET properties = properties || '{"preco_promocional": 39.90}'
WHERE id = 1;

-- Remover campo
UPDATE produtos
SET properties = properties - 'preco_custo'
WHERE id = 1;

-- Atualizar valor em campo específico (jsonb_set)
UPDATE produtos
SET properties = jsonb_set(properties, '{cor}', '"vermelho"')
WHERE id = 1;

-- Atualizar campo aninhado
UPDATE produtos
SET properties = jsonb_set(properties, '{dimensoes,altura}', '180')
WHERE id = 1;
```

---

### Indexação de JSONB

```sql
-- GIN geral: suporta ?, ?|, ?&, @>, @?
CREATE INDEX idx_produtos_props_gin ON produtos USING GIN (properties);

-- GIN otimizado para @> e @? (menor, mais rápido para containment)
CREATE INDEX idx_produtos_props_path ON produtos
    USING GIN (properties jsonb_path_ops);

-- Índice em campo específico do JSON (como se fosse coluna regular)
CREATE INDEX idx_produtos_cor ON produtos ((properties ->> 'cor'));
```

---

### Funções Avançadas de JSON

```sql
-- Expandir array JSON como linhas
SELECT produto_id, tamanho
FROM produtos,
     jsonb_array_elements_text(properties -> 'tamanhos') AS tamanho;

-- Expandir objeto como pares chave-valor
SELECT chave, valor
FROM produtos,
     jsonb_each_text(properties)
WHERE id = 1;

-- Construir JSON a partir de colunas
SELECT
    id,
    jsonb_build_object(
        'id',    id,
        'nome',  nome,
        'cor',   properties ->> 'cor'
    ) AS produto_resumo
FROM produtos;

-- Agregar linhas como array JSON
SELECT jsonb_agg(
    jsonb_build_object('id', id, 'nome', nome)
    ORDER BY nome
) AS produtos_json
FROM produtos;

-- Converter JSONB para estrutura relacional (jsonb_to_recordset)
SELECT *
FROM jsonb_to_recordset('[
    {"nome": "João", "idade": 30},
    {"nome": "Maria", "idade": 25}
]'::jsonb) AS t(nome TEXT, idade INT);
```

---

## 15. Particionamento de Tabelas

Particionamento divide fisicamente uma tabela grande em subtabelas menores (partições), mantendo uma **interface unificada** para consultas. O PostgreSQL lida com o roteamento automaticamente.

**Benefícios:**
- **Query Pruning**: O PostgreSQL lê apenas as partições relevantes.
- **Manutenção fácil**: `DROP` de uma partição antiga é instantâneo (sem `DELETE` linha a linha).
- **Cache eficiente**: Tabelas menores cabem melhor no `shared_buffers`.
- **VACUUM**: Roda por partição — muito mais rápido.

### RANGE — Por intervalo de valores

```sql
-- Tabela particionada por data
CREATE TABLE pedidos (
    id         BIGSERIAL,
    criado_em  DATE          NOT NULL,
    cliente_id BIGINT,
    total      DECIMAL(10,2)
) PARTITION BY RANGE (criado_em);

-- Criando as partições
CREATE TABLE pedidos_2023 PARTITION OF pedidos
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE pedidos_2024 PARTITION OF pedidos
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE pedidos_2025 PARTITION OF pedidos
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Partição default para valores fora dos ranges
CREATE TABLE pedidos_outros PARTITION OF pedidos DEFAULT;

-- Esta query só lê pedidos_2024 (query pruning automático)
SELECT * FROM pedidos WHERE criado_em BETWEEN '2024-06-01' AND '2024-06-30';
```

### LIST — Por lista de valores

```sql
CREATE TABLE vendas (
    id     BIGSERIAL,
    estado CHAR(2)       NOT NULL,
    total  DECIMAL(10,2)
) PARTITION BY LIST (estado);

CREATE TABLE vendas_sul      PARTITION OF vendas FOR VALUES IN ('RS','SC','PR');
CREATE TABLE vendas_sudeste  PARTITION OF vendas FOR VALUES IN ('SP','RJ','MG','ES');
CREATE TABLE vendas_nordeste PARTITION OF vendas FOR VALUES IN ('BA','PE','CE','MA','PI');
CREATE TABLE vendas_outros   PARTITION OF vendas DEFAULT;
```

### HASH — Distribuição uniforme

```sql
CREATE TABLE eventos (
    id         BIGSERIAL,
    usuario_id BIGINT NOT NULL,
    tipo       TEXT
) PARTITION BY HASH (usuario_id);

-- Distribui em 4 partições pelo hash do usuario_id
CREATE TABLE eventos_p0 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE eventos_p1 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE eventos_p2 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE eventos_p3 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

### Gerenciando Partições

```sql
-- Adicionar nova partição (sem downtime)
CREATE TABLE pedidos_2026 PARTITION OF pedidos
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Remover partição antiga (instantâneo, sem varrer linhas)
DROP TABLE pedidos_2022;

-- "Destacar" uma partição (vira tabela independente)
ALTER TABLE pedidos DETACH PARTITION pedidos_2022;

-- Criar índice em todas as partições de uma vez
CREATE INDEX ON pedidos (cliente_id);
```

---

## 16. Performance e Otimização

### EXPLAIN ANALYZE — Diagnóstico de Queries

```sql
-- Plano estimado (não executa)
EXPLAIN SELECT * FROM clientes WHERE cidade = 'Porto Alegre';

-- Executa e retorna o plano real + tempo real
EXPLAIN ANALYZE SELECT * FROM clientes WHERE cidade = 'Porto Alegre';

-- Detalhe máximo
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT c.nome, SUM(p.total)
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id
GROUP BY c.nome
ORDER BY SUM(p.total) DESC;
```

### Identificando Queries Lentas

```sql
-- Ativar extensão de estatísticas de queries
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- As 20 queries com maior tempo médio de execução
SELECT
    LEFT(query, 80)           AS query_resumo,
    calls                     AS execucoes,
    ROUND(total_exec_time / calls, 2) AS avg_ms,
    ROUND(rows / calls::NUMERIC, 1)   AS avg_rows
FROM pg_stat_statements
ORDER BY avg_ms DESC
LIMIT 20;

-- Tabelas com mais "lixo" (linhas mortas que precisam de VACUUM)
SELECT
    tablename,
    n_live_tup        AS linhas_vivas,
    n_dead_tup        AS linhas_mortas,
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;
```

### VACUUM — Manutenção do Banco

O PostgreSQL usa MVCC (Multi-Version Concurrency Control): em vez de modificar linhas, ele cria novas versões. Linhas "mortas" (versões antigas) precisam ser limpas periodicamente.

```sql
-- VACUUM normal: marca espaço como reutilizável (não devolve ao SO)
VACUUM clientes;

-- VACUUM com estatísticas (atualiza o planner)
VACUUM ANALYZE clientes;

-- VACUUM FULL: compacta a tabela (devolve espaço ao SO, mas bloqueia!)
VACUUM FULL clientes;

-- Atualizar estatísticas manualmente (se o autovacuum não rodou)
ANALYZE clientes;
```

### Boas Práticas de Performance

```sql
-- 1. Prefira colunas específicas a SELECT *
SELECT id, nome, email FROM clientes;      -- ✅ Bom
SELECT * FROM clientes;                     -- ❌ Evite em produção

-- 2. Use índices em FKs (não são automáticos)
CREATE INDEX idx_pedidos_cliente ON pedidos (cliente_id);

-- 3. EXISTS é mais eficiente que IN para subqueries grandes
SELECT * FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);

-- 4. Evite funções em colunas filtradas (impede uso de índice B-Tree)
-- ❌ Ruim: full scan mesmo com índice em nome
SELECT * FROM clientes WHERE UPPER(nome) = 'JOÃO';
-- ✅ Bom: índice em expressão
CREATE INDEX idx_clientes_nome_upper ON clientes (UPPER(nome));
SELECT * FROM clientes WHERE UPPER(nome) = 'JOÃO'; -- usa o índice

-- 5. Use LIMIT em queries exploratórias
SELECT * FROM logs ORDER BY criado_em DESC LIMIT 100;

-- 6. Para queries de relatório pesadas, use Views Materializadas
REFRESH MATERIALIZED VIEW mv_relatorio_vendas;
SELECT * FROM mv_relatorio_vendas WHERE cidade = 'São Paulo';

-- 7. Use índices parciais para subconjuntos comuns
CREATE INDEX idx_pedidos_pendentes ON pedidos (cliente_id, criado_em)
WHERE status = 'pendente';
```

---

## 17. Boas Práticas e Padrões

### Convenção de Nomenclatura

| Elemento | Convenção | Exemplos |
|---|---|---|
| Tabelas | `snake_case`, plural | `clientes`, `itens_pedido` |
| Colunas | `snake_case` | `nome_completo`, `criado_em` |
| PK | `id` | `id BIGSERIAL PRIMARY KEY` |
| FK | `{tabela_singular}_id` | `cliente_id`, `produto_id` |
| Índices | `idx_{tabela}_{col(s)}` | `idx_pedidos_cliente_id` |
| Views | `vw_{nome}` | `vw_relatorio_vendas` |
| View Materializada | `mv_{nome}` | `mv_dashboard_mensal` |
| Functions | `fn_{verbo}_{contexto}` | `fn_calcular_desconto` |
| Procedures | `prc_{verbo}_{contexto}` | `prc_transferir_saldo` |
| Triggers | `tg_{momento}_{tabela}` | `tg_before_insert_clientes` |
| Constraints | `{tipo}_{tabela}_{col}` | `chk_clientes_saldo`, `fk_pedidos_clientes` |

### Checklist de Design de Schema

Antes de dar `CREATE TABLE` em produção, verifique:

- [ ] Toda tabela tem `id BIGSERIAL PRIMARY KEY` (ou `UUID`)
- [ ] Campos de auditoria: `criado_em TIMESTAMPTZ DEFAULT NOW()` e `atualizado_em`
- [ ] Trigger para atualizar `atualizado_em` automaticamente no `UPDATE`
- [ ] Colunas obrigatórias têm `NOT NULL`
- [ ] FKs têm `ON DELETE` e `ON UPDATE` definidos explicitamente
- [ ] Índices criados **manualmente** nas colunas FK
- [ ] Índices adicionais nas colunas mais usadas em `WHERE` e `ORDER BY`
- [ ] Tipos monetários usam `DECIMAL`/`NUMERIC`, nunca `FLOAT`
- [ ] Senhas **nunca** armazenadas em texto plano (use `pgcrypto` ou hash na aplicação)
- [ ] Constraints nomeadas (facilita o diagnóstico de erros de violação)
- [ ] Schema documentado com comentários

```sql
-- Documentando tabelas e colunas com COMMENT
COMMENT ON TABLE clientes IS 'Tabela de clientes pessoas físicas e jurídicas.';
COMMENT ON COLUMN clientes.cpf IS 'CPF sem máscara, apenas dígitos (11 chars).';
COMMENT ON COLUMN clientes.saldo IS 'Saldo disponível em reais. Nunca negativo (CHECK constraint).';
```

### Template de Tabela Bem Modelada

```sql
-- Tabela de pedidos com todas as boas práticas aplicadas

CREATE TABLE pedidos (

    -- Identificação
    id              BIGSERIAL       PRIMARY KEY,

    -- Chave estrangeira (com ação referencial explícita)
    cliente_id      BIGINT          NOT NULL,
    CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Dados de negócio
    status          VARCHAR(20)     NOT NULL DEFAULT 'pendente',
    CONSTRAINT chk_pedidos_status
        CHECK (status IN ('pendente','aprovado','enviado','entregue','cancelado')),

    total           DECIMAL(12,2)   NOT NULL,
    CONSTRAINT chk_pedidos_total CHECK (total > 0),

    observacoes     TEXT,

    -- Auditoria
    criado_em       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    atualizado_em   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    criado_por      TEXT            NOT NULL DEFAULT current_user
);

-- Índice na FK (obrigatório!)
CREATE INDEX idx_pedidos_cliente_id     ON pedidos (cliente_id);

-- Índice composto para consultas típicas de dashboard
CREATE INDEX idx_pedidos_status_data    ON pedidos (status, criado_em DESC);

-- Documentação
COMMENT ON TABLE pedidos IS 'Pedidos realizados pelos clientes.';

-- Trigger para atualizar atualizado_em automaticamente
CREATE OR REPLACE FUNCTION fn_set_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_before_update_pedidos
    BEFORE UPDATE ON pedidos
    FOR EACH ROW EXECUTE FUNCTION fn_set_atualizado_em();
```

---

## 18. Cheat Sheet Rápido

### DDL

```sql
-- Criar
CREATE TABLE t (id BIGSERIAL PRIMARY KEY, nome TEXT NOT NULL, ativo BOOLEAN DEFAULT TRUE);

-- Alterar
ALTER TABLE t ADD COLUMN col TEXT;
ALTER TABLE t DROP COLUMN col;
ALTER TABLE t ALTER COLUMN col TYPE INTEGER;
ALTER TABLE t RENAME COLUMN col TO novo_nome;

-- Remover
DROP TABLE IF EXISTS t CASCADE;
TRUNCATE TABLE t RESTART IDENTITY;
```

### DML

```sql
INSERT INTO t (nome) VALUES ('x') RETURNING id;
INSERT INTO t (nome) VALUES ('x') ON CONFLICT (nome) DO UPDATE SET nome = EXCLUDED.nome;

SELECT id, nome FROM t WHERE ativo = TRUE ORDER BY nome LIMIT 10 OFFSET 20;

UPDATE t SET nome = 'y', ativo = FALSE WHERE id = 1 RETURNING *;

DELETE FROM t WHERE id = 1 RETURNING *;
```

### JOINs

```sql
-- INNER: apenas correspondências em ambos
FROM a INNER JOIN b ON a.id = b.a_id

-- LEFT: todos de A + correspondências de B
FROM a LEFT JOIN b ON a.id = b.a_id

-- FULL OUTER: todos de ambos
FROM a FULL OUTER JOIN b ON a.id = b.a_id

-- SELF JOIN: hierarquia
FROM funcionarios f LEFT JOIN funcionarios g ON f.gerente_id = g.id
```

### Agregação

```sql
SELECT col, COUNT(*), SUM(val), AVG(val), MIN(val), MAX(val)
FROM t
WHERE condicao
GROUP BY col
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;
```

### Window Functions

```sql
ROW_NUMBER()   OVER (PARTITION BY col ORDER BY val DESC)
RANK()         OVER (ORDER BY val DESC)
DENSE_RANK()   OVER (PARTITION BY col ORDER BY val DESC)
LAG(val)       OVER (ORDER BY data)
LEAD(val)      OVER (ORDER BY data)
SUM(val)       OVER (PARTITION BY grupo ORDER BY data ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
NTILE(4)       OVER (ORDER BY val)
```

### CTE e Subquery

```sql
-- CTE
WITH nome AS (SELECT ...) SELECT * FROM nome;

-- CTE Recursiva
WITH RECURSIVE hier AS (
    SELECT id, pai_id, 1 AS nivel FROM t WHERE pai_id IS NULL
    UNION ALL
    SELECT t.id, t.pai_id, h.nivel + 1 FROM t JOIN hier h ON t.pai_id = h.id
) SELECT * FROM hier;
```

### JSONB

```sql
col ->> 'chave'                         -- Texto do campo
col -> 'chave'                          -- JSON do campo
col -> 'array' ->> 0                    -- Primeiro elemento do array
col @> '{"chave": "valor"}'             -- Contém subconjunto?
col ? 'chave'                           -- Chave existe?
col || '{"nova_chave": "valor"}'        -- Merge
col - 'chave'                           -- Remover chave
jsonb_set(col, '{path}', '"novo_val"')  -- Atualizar valor
CREATE INDEX ON t USING GIN (col);      -- Indexar JSONB
```

### Índices

```sql
CREATE INDEX idx_t_col                  ON t (col);
CREATE UNIQUE INDEX idx_t_col_u         ON t (col);
CREATE INDEX idx_t_gin                  ON t USING GIN (jsonb_col);
CREATE INDEX idx_t_parcial              ON t (col) WHERE ativo = TRUE;
CREATE INDEX idx_t_expressao            ON t (LOWER(email));
CREATE INDEX idx_t_composto             ON t (fk_id, criado_em DESC);
EXPLAIN ANALYZE SELECT * FROM t WHERE col = 'x';
```

### Transações

```sql
BEGIN;
    -- operações DML
SAVEPOINT sp1;
    -- mais operações
ROLLBACK TO SAVEPOINT sp1;  -- ou COMMIT;
COMMIT;
```

### PL/pgSQL

```sql
CREATE OR REPLACE FUNCTION fn_nome(p_arg TIPO) RETURNS TIPO AS $$
DECLARE v_var TIPO;
BEGIN
    v_var := expressao;
    RETURN v_var;
EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION '%', SQLERRM;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE prc_nome(p_arg TIPO) AS $$
BEGIN
    -- lógica sem RETURN
END; $$ LANGUAGE plpgsql;
```

---

> ## 📚 Continue Aprendendo
>
> - [Documentação Oficial do PostgreSQL](https://www.postgresql.org/docs/) — A referência definitiva
> - [pgexercises.com](https://pgexercises.com/) — Exercícios práticos interativos
> - [use-the-index-luke.com](https://use-the-index-luke.com/) — Guia completo de índices em SQL
> - [explain.dalibo.com](https://explain.dalibo.com/) — Visualizador gráfico de planos EXPLAIN
> - [postgresqltutorial.com](https://www.postgresqltutorial.com/) — Tutoriais progressivos
> - [pgvector](https://github.com/pgvector/pgvector) — Extensão para buscas vetoriais (IA/ML)
> - [PostGIS](https://postgis.net/) — Extensão para dados geoespaciais

---