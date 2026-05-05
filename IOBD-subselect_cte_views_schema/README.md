# 📖 Apostila — SQL Avançado em PostgreSQL

### Implementação e Operação em Banco de Dados

> Subconsultas · CTE · Views · Schemas · Evolução de Esquema com ALTER TABLE

---

## Sumário

1. [Subconsultas (SUBSELECT)](#1-subconsultas-subselect)
   - 1.1 [O que é uma subconsulta?](#11-o-que-é-uma-subconsulta)
   - 1.2 [Subconsulta no WHERE](#12-subconsulta-no-where)
   - 1.3 [Subconsulta Escalar](#13-subconsulta-escalar)
   - 1.4 [EXISTS e NOT EXISTS](#14-exists-e-not-exists)
   - 1.5 [EXISTS vs IN — Quando usar cada um](#15-exists-vs-in--quando-usar-cada-um)
2. [CTE — Common Table Expressions](#2-cte--common-table-expressions)
   - 2.1 [O que é uma CTE?](#21-o-que-é-uma-cte)
   - 2.2 [Sintaxe básica](#22-sintaxe-básica)
   - 2.3 [CTE vs Subquery — Diferenças práticas](#23-cte-vs-subquery--diferenças-práticas)
   - 2.4 [CTEs encadeadas](#24-ctes-encadeadas)
3. [Views](#3-views)
   - 3.1 [O que é uma View?](#31-o-que-é-uma-view)
   - 3.2 [Criando e consultando Views](#32-criando-e-consultando-views)
   - 3.3 [Atualizando e removendo Views](#33-atualizando-e-removendo-views)
   - 3.4 [Boas práticas com Views](#34-boas-práticas-com-views)
4. [Schemas](#4-schemas)
   - 4.1 [O que é um Schema?](#41-o-que-é-um-schema)
   - 4.2 [Criando e usando Schemas](#42-criando-e-usando-schemas)
   - 4.3 [Movendo tabelas entre Schemas](#43-movendo-tabelas-entre-schemas)
   - 4.4 [search_path — Schema padrão de busca](#44-search_path--schema-padrão-de-busca)
5. [ALTER TABLE — Evolução de Esquema](#5-alter-table--evolução-de-esquema)
   - 5.1 [Por que evoluir um esquema?](#51-por-que-evoluir-um-esquema)
   - 5.2 [Adicionando colunas](#52-adicionando-colunas)
   - 5.3 [Alterando tipo de coluna](#53-alterando-tipo-de-coluna)
   - 5.4 [Restrições NOT NULL](#54-restrições-not-null)
   - 5.5 [Renomeando colunas](#55-renomeando-colunas)
   - 5.6 [Constraints CHECK](#56-constraints-check)
   - 5.7 [Removendo constraints](#57-removendo-constraints)
6. [Exercícios Resolvidos](#6-exercícios-resolvidos)
7. [Referências](#7-referências)

---

## Banco de Dados Utilizado

Todos os exemplos e exercícios desta apostila operam sobre o banco `sistema_requerimento`, que modela um sistema de abertura de requerimentos acadêmicos.

```sql
-- Schema do banco de referência
usuario           (id, nome, email, cpf, data_nascimento, cep, complemento, numero)
curso             (id, nome, site, turno, duracao)
aluno             (matricula PK, usuario_id FK, curso_id FK)
tipo_requerimento (id, descricao)
requerimento      (id, aluno_matricula FK, data_hora_abertura, status, tipo_requerimento_id FK)
anexo             (id, descricao, arquivo BYTEA, requerimento_id FK)
```

---

## 1. Subconsultas (SUBSELECT)

### 1.1 O que é uma subconsulta?

Uma **subconsulta** (ou subquery / subselect) é um comando `SELECT` aninhado dentro de outro comando SQL. Ela pode aparecer em diferentes partes de uma query:

```sql
SELECT ...
  FROM ...
 WHERE coluna = (SELECT ...)   -- no WHERE como valor escalar
   AND EXISTS  (SELECT ...)   -- com EXISTS como verificação de existência
```

A subconsulta é sempre executada **primeiro**, e seu resultado é usado pela consulta externa (query principal). Isso permite resolver em uma única instrução SQL problemas que precisariam de múltiplas etapas.

---

### 1.2 Subconsulta no WHERE

A forma mais comum de subconsulta filtra linhas com base em valores calculados por outra query. Há dois comportamentos possíveis dependendo de quantas linhas a subconsulta retorna:

| Retorno da subconsulta | Operador correto |
|---|---|
| Exatamente **1 valor** (escalar) | `=`, `<>`, `<`, `>` |
| **Múltiplos valores** | `IN`, `NOT IN`, `ANY`, `ALL` |

**Exemplo — retorno múltiplo com `IN`:**

```sql
-- Busca requerimentos cujos tipos têm mais de uma palavra na descrição
SELECT id, status
FROM requerimento
WHERE tipo_requerimento_id IN (
    SELECT id
    FROM tipo_requerimento
    WHERE descricao LIKE '% %'
);
```

> ⚠️ **Cuidado com `NOT IN` e NULLs:** se a subconsulta retornar qualquer valor `NULL`, `NOT IN` retorna zero linhas — comportamento inesperado. Prefira `NOT EXISTS` nesses casos.

---

### 1.3 Subconsulta Escalar

Uma subconsulta escalar retorna **exatamente um valor** (uma linha, uma coluna). Pode ser usada com `=` e inclusive dentro do próprio `SELECT`:

```sql
-- Retorna o nome do tipo junto com cada requerimento (subconsulta no SELECT)
SELECT
    r.id,
    r.status,
    (SELECT descricao
     FROM tipo_requerimento
     WHERE id = r.tipo_requerimento_id) AS tipo
FROM requerimento r;
```

```sql
-- Filtra por um tipo específico com subconsulta escalar no WHERE
SELECT id, aluno_matricula, status
FROM requerimento
WHERE tipo_requerimento_id = (
    SELECT id
    FROM tipo_requerimento
    WHERE descricao = 'Reingresso'
);
```

> 💡 Se a subconsulta retornar mais de uma linha com `=`, o PostgreSQL lança um erro: `ERROR: more than one row returned by a subquery used as an expression`. Nesse caso, use `IN`.

---

### 1.4 EXISTS e NOT EXISTS

`EXISTS` é um operador que recebe uma subconsulta e retorna `TRUE` se ela produzir **ao menos uma linha**, e `FALSE` caso contrário. O valor das colunas selecionadas não importa — por convenção usa-se `SELECT 1`.

```
Para cada linha da consulta externa:
  └─ executa a subconsulta correlacionada
       ├─ retornou alguma linha? → EXISTS = TRUE  → linha incluída no resultado
       └─ não retornou nada?    → EXISTS = FALSE → linha excluída do resultado
```

A subconsulta é dita **correlacionada** porque referencia colunas da consulta externa. Isso é o que conecta as duas queries e faz o EXISTS funcionar linha a linha.

**Sintaxe:**

```sql
SELECT colunas
FROM tabela_externa te
WHERE EXISTS (
    SELECT 1
    FROM outra_tabela ot
    WHERE ot.chave_fk = te.chave_pk   -- correlação entre as duas queries
);
```

**`NOT EXISTS`** funciona de forma inversa — inclui a linha apenas quando a subconsulta **não** retorna nenhum resultado:

```sql
SELECT colunas
FROM tabela_externa te
WHERE NOT EXISTS (
    SELECT 1
    FROM outra_tabela ot
    WHERE ot.chave_fk = te.chave_pk
);
```

---

### 1.5 EXISTS vs IN — Quando usar cada um

Embora `EXISTS` e `IN` possam resolver problemas similares, eles têm comportamentos e perfis de performance diferentes:

| Característica | `IN (subquery)` | `EXISTS (subquery)` |
|---|---|---|
| O que avalia | Lista de valores retornados | Existência de ao menos uma linha |
| Sensível a `NULL` | Sim — `NOT IN` falha silenciosamente com NULLs | Não — comportamento previsível |
| Performance (tabela grande) | Pode ser lento (materializa tudo) | Mais rápido — para no primeiro match |
| Subconsulta correlacionada | Não (executa uma vez) | Sim (executa por linha) |
| Legibilidade para "tem/não tem" | Moderada | Alta — intenção explícita |

**Regra prática:**
- Use `IN` quando a subconsulta retorna uma lista de IDs conhecida e sem NULLs.
- Use `EXISTS` quando a pergunta é "esse registro tem ou não tem correspondência em outra tabela".

---

## 2. CTE — Common Table Expressions

### 2.1 O que é uma CTE?

Uma **CTE** (Common Table Expression — Expressão de Tabela Comum) é um bloco nomeado de `SELECT` que existe temporariamente durante a execução de uma query. Ela é definida antes da query principal com a cláusula `WITH` e pode ser referenciada como se fosse uma tabela real.

**Analogia:** pense em uma CTE como uma variável de consulta — você calcula algo, dá um nome a esse resultado, e usa mais à frente na mesma instrução.

A CTE **não é armazenada** no banco. Ela existe apenas na memória durante a execução da instrução SQL que a contém.

---

### 2.2 Sintaxe básica

```sql
WITH nome_da_cte AS (
    -- Qualquer SELECT válido
    SELECT
        coluna1,
        coluna2,
        COUNT(*) AS total
    FROM tabela
    GROUP BY coluna1, coluna2
)
-- Query principal que usa a CTE como se fosse uma tabela
SELECT *
FROM nome_da_cte
WHERE total > 5
ORDER BY total DESC;
```

**Regras importantes:**
- A cláusula `WITH` vem **antes** do `SELECT` principal.
- Quando há múltiplas CTEs, elas são separadas por vírgula.
- Uma CTE pode referenciar tabelas reais, outras CTEs anteriores, ou uma combinação.

---

### 2.3 CTE vs Subquery — Diferenças práticas

As duas abordagens abaixo resolvem o mesmo problema. Compare a legibilidade:

**Com subquery aninhada:**

```sql
SELECT aluno_nome, total
FROM (
    SELECT u.nome AS aluno_nome, COUNT(r.id) AS total
    FROM aluno a
    INNER JOIN usuario u      ON u.id              = a.usuario_id
    LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
    GROUP BY u.nome
) AS sub
WHERE sub.total > 1;
```

**Com CTE:**

```sql
WITH contagem AS (
    SELECT u.nome AS aluno_nome, COUNT(r.id) AS total
    FROM aluno a
    INNER JOIN usuario u      ON u.id              = a.usuario_id
    LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
    GROUP BY u.nome
)
SELECT aluno_nome, total
FROM contagem
WHERE total > 1;
```

| Critério | Subquery | CTE |
|---|---|---|
| Legibilidade | Baixa (aninhada) | Alta (separada por etapas) |
| Reutilização na mesma query | Não | Sim — pode ser referenciada várias vezes |
| Debugar parcialmente | Difícil | Fácil — executa só o bloco WITH |
| Performance | Similar na maioria dos casos | Similar na maioria dos casos |

---

### 2.4 CTEs encadeadas

É possível definir múltiplas CTEs em sequência, onde cada uma pode usar as anteriores. Isso torna queries muito complexas legíveis como um algoritmo passo a passo:

```sql
WITH
-- Etapa 1: detalhar os requerimentos com JOINs
detalhes AS (
    SELECT
        u.nome              AS aluno_nome,
        tr.descricao        AS tipo,
        r.status,
        r.data_hora_abertura
    FROM requerimento r
    INNER JOIN aluno a              ON a.matricula = r.aluno_matricula
    INNER JOIN usuario u            ON u.id        = a.usuario_id
    INNER JOIN tipo_requerimento tr ON tr.id       = r.tipo_requerimento_id
),
-- Etapa 2: contar requerimentos por aluno usando a CTE anterior
contagem AS (
    SELECT aluno_nome, COUNT(*) AS total
    FROM detalhes
    GROUP BY aluno_nome
)
-- Query final: combinar as duas CTEs
SELECT d.aluno_nome, d.tipo, d.status, c.total
FROM detalhes d
INNER JOIN contagem c ON c.aluno_nome = d.aluno_nome
ORDER BY c.total DESC;
```

> 💡 CTEs encadeadas transformam queries complexas em etapas nomeadas — cada bloco tem propósito claro, o que facilita tanto a leitura quanto a manutenção futura.

---

## 3. Views

### 3.1 O que é uma View?

Uma **view** é uma consulta SQL salva no banco de dados com um nome próprio. Ela se comporta exatamente como uma tabela para quem a consulta, mas **não armazena dados** — cada acesso executa a query original e retorna o resultado atualizado.

```
Tabelas reais                 View (query salva)              Consumidor
  usuario      ─────────────────────────────────────────►  SELECT * FROM
  aluno        ──► vw_requerimentos_detalhados ──────────►  vw_req_det...
  requerimento ─────────────────────────────────────────►  WHERE status = ...
  tipo_req     ─────────────────────────────────────────►
```

**Por que usar Views?**

- **Abstração:** o consumidor não precisa conhecer os JOINs e lógicas internas.
- **Reutilização:** uma query complexa escrita uma vez, acessível em muitos lugares.
- **Segurança:** é possível conceder acesso à view sem expor as tabelas base.
- **Manutenção:** alterar a query interna da view não impacta quem a consome.
- **Consistência:** garante que todos usem a mesma lógica para acessar os dados.

---

### 3.2 Criando e consultando Views

```sql
-- Criação simples
CREATE VIEW nome_da_view AS
SELECT ...;

-- Criação com substituição (recomendado — não falha se já existir)
CREATE OR REPLACE VIEW nome_da_view AS
SELECT ...;
```

**Exemplo completo:**

```sql
CREATE OR REPLACE VIEW vw_requerimentos_detalhados AS
SELECT
    u.nome              AS aluno_nome,
    tr.descricao        AS tipo_requerimento,
    r.status,
    r.data_hora_abertura
FROM requerimento r
INNER JOIN aluno a              ON a.matricula = r.aluno_matricula
INNER JOIN usuario u            ON u.id        = a.usuario_id
INNER JOIN tipo_requerimento tr ON tr.id       = r.tipo_requerimento_id;
```

A view pode ser usada em qualquer `SELECT` como se fosse uma tabela:

```sql
-- Consulta simples
SELECT * FROM vw_requerimentos_detalhados;

-- Com filtro adicional
SELECT * FROM vw_requerimentos_detalhados
WHERE status = 'em análise';

-- Com agrupamento
SELECT tipo_requerimento, COUNT(*) AS total
FROM vw_requerimentos_detalhados
GROUP BY tipo_requerimento
ORDER BY total DESC;
```

---

### 3.3 Atualizando e removendo Views

```sql
-- Atualizar a definição (substitui a query interna)
CREATE OR REPLACE VIEW vw_requerimentos_detalhados AS
SELECT
    u.nome,
    u.email,          -- nova coluna adicionada
    tr.descricao,
    r.status
FROM requerimento r
INNER JOIN aluno a              ON a.matricula = r.aluno_matricula
INNER JOIN usuario u            ON u.id        = a.usuario_id
INNER JOIN tipo_requerimento tr ON tr.id       = r.tipo_requerimento_id;

-- Remover a view
DROP VIEW vw_requerimentos_detalhados;

-- Remover sem erro se não existir
DROP VIEW IF EXISTS vw_requerimentos_detalhados;
```

---

### 3.4 Boas práticas com Views

| Prática | Motivo |
|---|---|
| Prefixo `vw_` no nome | Identificar visualmente que é uma view, não uma tabela |
| Usar `CREATE OR REPLACE` | Evita erro ao tentar recriar uma view que já existe |
| Nomear colunas com `AS` | Garante nomes claros mesmo quando vêm de funções ou expressões |
| Documentar com `COMMENT ON VIEW` | Facilita entendimento por outros desenvolvedores |
| Não criar views de views muito aninhadas | Dificulta manutenção e pode impactar a performance |

```sql
-- Documentar uma view
COMMENT ON VIEW vw_requerimentos_detalhados IS
    'Retorna todos os requerimentos com nome do aluno, tipo e status.';
```

---

## 4. Schemas

### 4.1 O que é um Schema?

Um **schema** é um **namespace** (espaço de nomes) dentro de um banco de dados. Ele organiza tabelas, views, funções e outros objetos em grupos lógicos, permitindo que objetos com o mesmo nome coexistam em schemas diferentes sem conflito.

```
banco: sistema_requerimento
│
├── public                    (schema padrão — criado automaticamente)
│   ├── usuario
│   ├── curso
│   ├── aluno
│   ├── requerimento
│   └── anexo
│
└── administrativo            (schema criado manualmente)
    └── tipo_requerimento
```

O schema padrão do PostgreSQL é o `public`. Quando você cria uma tabela sem especificar schema, ela vai para `public` automaticamente.

**Vantagens de usar schemas:**
- Separar módulos de um sistema grande (ex: `financeiro`, `academico`, `rh`)
- Isolar objetos por área de responsabilidade
- Controle de permissões em nível de schema (`GRANT ON SCHEMA`)
- Evitar conflitos de nome entre módulos distintos do sistema

---

### 4.2 Criando e usando Schemas

```sql
-- Criar schema
CREATE SCHEMA nome_do_schema;

-- Criar somente se não existir (mais seguro)
CREATE SCHEMA IF NOT EXISTS administrativo;

-- Criar objeto diretamente dentro de um schema
CREATE TABLE administrativo.configuracao (
    id     SERIAL PRIMARY KEY,
    chave  VARCHAR(100),
    valor  TEXT
);

-- Consultar objeto com schema explícito (schema.tabela)
SELECT * FROM administrativo.configuracao;

-- Remover schema (apenas se estiver vazio)
DROP SCHEMA administrativo;

-- Remover schema e todos os objetos dentro dele
DROP SCHEMA administrativo CASCADE;
```

---

### 4.3 Movendo tabelas entre Schemas

```sql
-- Mover tabela do schema atual para outro
ALTER TABLE tipo_requerimento SET SCHEMA administrativo;

-- Acesso após a migração (necessário usar o prefixo do schema)
SELECT * FROM administrativo.tipo_requerimento;
```

> ✅ **Chaves estrangeiras são preservadas automaticamente.** O PostgreSQL atualiza internamente as referências — a coluna `requerimento.tipo_requerimento_id` continua válida sem necessidade de recriar a constraint.

---

### 4.4 search_path — Schema padrão de busca

O `search_path` define em quais schemas o PostgreSQL procura objetos quando o schema não é especificado explicitamente na query. Por padrão, é `"$user", public`.

```sql
-- Ver o search_path atual
SHOW search_path;

-- Incluir o schema administrativo no caminho de busca
SET search_path TO public, administrativo;

-- Agora é possível acessar sem prefixo (PostgreSQL busca em public, depois em administrativo)
SELECT * FROM tipo_requerimento;  -- encontra administrativo.tipo_requerimento

-- Restaurar ao padrão
SET search_path TO DEFAULT;
```

---

## 5. ALTER TABLE — Evolução de Esquema

### 5.1 Por que evoluir um esquema?

Um banco de dados raramente permanece estático ao longo do ciclo de vida de um sistema. Novas funcionalidades exigem novos campos, regras de negócio mudam, tipos de dados precisam ser revisados. O comando `ALTER TABLE` permite **modificar a estrutura de uma tabela existente sem recriar nem perder os dados já armazenados**.

---

### 5.2 Adicionando colunas

```sql
ALTER TABLE nome_tabela
    ADD COLUMN nome_coluna tipo_dado;
```

**Comportamento:** novas colunas recebem `NULL` nas linhas já existentes, a menos que um `DEFAULT` seja fornecido.

```sql
-- Sem DEFAULT → linhas existentes ficam com NULL
ALTER TABLE usuario
    ADD COLUMN telefone VARCHAR(20);

-- Com DEFAULT → linhas existentes recebem o valor padrão
ALTER TABLE usuario
    ADD COLUMN ativo BOOLEAN DEFAULT TRUE;

-- Com DEFAULT e NOT NULL (mais restritivo)
ALTER TABLE usuario
    ADD COLUMN pontuacao INTEGER NOT NULL DEFAULT 0;
```

> 💡 No PostgreSQL 11+, adicionar uma coluna com `DEFAULT` não reescreve todas as linhas da tabela fisicamente — o valor é armazenado no catálogo e aplicado dinamicamente. Isso torna a operação muito mais rápida em tabelas grandes.

---

### 5.3 Alterando tipo de coluna

```sql
ALTER TABLE nome_tabela
    ALTER COLUMN nome_coluna TYPE novo_tipo;
```

O PostgreSQL tenta converter os dados existentes automaticamente. Para conversões onde a transformação não é óbvia, é necessário informar como converter com `USING`:

```sql
-- Conversão simples (VARCHAR → CHAR do mesmo tamanho)
ALTER TABLE usuario
    ALTER COLUMN telefone TYPE CHAR(11);

-- Conversão com expressão USING (TEXT → INTEGER)
ALTER TABLE usuario
    ALTER COLUMN pontuacao TYPE INTEGER USING pontuacao::INTEGER;

-- Reduzindo VARCHAR (pode falhar se dados existentes excedem o novo tamanho)
ALTER TABLE usuario
    ALTER COLUMN nome TYPE VARCHAR(100);
```

> ⚠️ Reduções de tamanho de tipo podem lançar erro se algum valor existente for maior que o novo limite. Verifique os dados antes de executar.

---

### 5.4 Restrições NOT NULL

**Definir NOT NULL** — torna a coluna obrigatória (não aceita valores nulos):

```sql
ALTER TABLE usuario
    ALTER COLUMN telefone SET NOT NULL;
```

> ⚠️ **Pré-requisito:** todas as linhas existentes devem ter valor na coluna. Se houver `NULL`, o banco rejeita o comando com erro. Solução: preencher os NULLs antes.

```sql
-- Passo 1: preencher NULLs existentes com um valor padrão
UPDATE usuario SET telefone = '00000000000' WHERE telefone IS NULL;

-- Passo 2: agora é seguro adicionar NOT NULL
ALTER TABLE usuario ALTER COLUMN telefone SET NOT NULL;
```

**Remover NOT NULL** — torna a coluna opcional novamente:

```sql
ALTER TABLE usuario
    ALTER COLUMN telefone DROP NOT NULL;
```

---

### 5.5 Renomeando colunas

```sql
ALTER TABLE nome_tabela
    RENAME COLUMN nome_atual TO novo_nome;
```

```sql
ALTER TABLE usuario
    RENAME COLUMN telefone TO celular;
```

> ⚠️ Se a coluna é referenciada em views, funções, triggers ou código de aplicação, essas dependências precisam ser atualizadas. Sempre verifique o impacto antes de renomear em ambiente de produção.

---

### 5.6 Constraints CHECK

Uma **constraint CHECK** define uma regra de validação expressa como uma condição booleana. O banco rejeita qualquer `INSERT` ou `UPDATE` que faça a condição retornar `FALSE`.

```sql
ALTER TABLE nome_tabela
    ADD CONSTRAINT nome_constraint CHECK (expressao_booleana);
```

O nome explícito da constraint (`nome_constraint`) é fundamental para poder identificá-la e removê-la futuramente.

**Exemplos:**

```sql
-- Garante que o campo ativo nunca seja NULL
ALTER TABLE usuario
    ADD CONSTRAINT chk_usuario_ativo CHECK (ativo IS NOT NULL);

-- Garante que pontuação esteja dentro de um intervalo válido
ALTER TABLE usuario
    ADD CONSTRAINT chk_pontuacao_range CHECK (pontuacao >= 0 AND pontuacao <= 100);

-- Garante que o email contenha ao menos um @
ALTER TABLE usuario
    ADD CONSTRAINT chk_email_formato CHECK (email LIKE '%@%');
```

**Diferença entre DEFAULT e CHECK:**

| | `DEFAULT` | `CHECK` |
|---|---|---|
| Quando atua | Na inserção, quando o valor não é informado | Em toda inserção e atualização |
| O que faz | Preenche o valor ausente | Valida o valor fornecido |
| Rejeita operações? | Não — apenas completa | Sim — bloqueia se a condição falhar |

---

### 5.7 Removendo constraints

```sql
ALTER TABLE nome_tabela
    DROP CONSTRAINT nome_constraint;
```

```sql
-- Remover a constraint criada anteriormente
ALTER TABLE usuario
    DROP CONSTRAINT chk_usuario_ativo;
```

Para descobrir o nome de uma constraint existente quando não se sabe qual é:

```sql
SELECT conname AS constraint_nome, contype AS tipo
FROM pg_constraint
WHERE conrelid = 'usuario'::regclass;
```

| Código | Tipo de constraint |
|---|---|
| `p` | PRIMARY KEY |
| `f` | FOREIGN KEY |
| `u` | UNIQUE |
| `c` | CHECK |

---

## 6. Exercícios Resolvidos

### Exercício 86 — Alunos COM requerimento (EXISTS)

```sql
SELECT
    u.nome,
    a.matricula
FROM aluno a
INNER JOIN usuario u ON u.id = a.usuario_id
WHERE EXISTS (
    SELECT 1
    FROM requerimento r
    WHERE r.aluno_matricula = a.matricula
);
```

Para cada aluno, a subconsulta verifica se existe ao menos uma linha em `requerimento` com aquela matrícula. O `SELECT 1` é convencional — o valor retornado não importa, apenas a existência de linhas.

---

### Exercício 87 — Alunos SEM requerimento (NOT EXISTS)

```sql
SELECT
    u.nome,
    a.matricula
FROM aluno a
INNER JOIN usuario u ON u.id = a.usuario_id
WHERE NOT EXISTS (
    SELECT 1
    FROM requerimento r
    WHERE r.aluno_matricula = a.matricula
);
```

Lógica inversa do exercício 86. Retorna alunos para quem a subconsulta não produz nenhuma linha — ou seja, não abriram nenhum requerimento.

---

### Exercício 88 — Requerimentos do tipo "Reingresso" (subselect escalar)

```sql
SELECT
    r.id             AS requerimento_id,
    r.aluno_matricula,
    r.status,
    r.data_hora_abertura
FROM requerimento r
WHERE r.tipo_requerimento_id = (
    SELECT id
    FROM tipo_requerimento
    WHERE descricao = 'Reingresso'
);
```

A subconsulta retorna um único `id` inteiro (valor escalar), portanto o operador `=` é correto. A consulta externa filtra requerimentos cujo `tipo_requerimento_id` corresponde a esse id.

---

### Exercício 89 — CTE com filtro por status

```sql
WITH requerimentos_detalhados AS (
    SELECT
        u.nome              AS aluno_nome,
        r.id                AS requerimento_id,
        r.status,
        tr.descricao        AS tipo,
        r.data_hora_abertura
    FROM requerimento r
    INNER JOIN aluno a              ON a.matricula = r.aluno_matricula
    INNER JOIN usuario u            ON u.id        = a.usuario_id
    INNER JOIN tipo_requerimento tr ON tr.id       = r.tipo_requerimento_id
)
SELECT *
FROM requerimentos_detalhados
WHERE status = 'em análise';
```

A CTE monta o conjunto completo de dados com os JOINs. O `SELECT` externo aplica o filtro de status, separando claramente a montagem dos dados da filtragem — cada etapa com propósito explícito.

---

### Exercício 90 — CTE com contagem e filtro de quantidade

```sql
WITH contagem_por_aluno AS (
    SELECT
        a.matricula,
        u.nome          AS aluno_nome,
        COUNT(r.id)     AS total_requerimentos
    FROM aluno a
    INNER JOIN usuario u      ON u.id              = a.usuario_id
    LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
    GROUP BY a.matricula, u.nome
)
SELECT matricula, aluno_nome, total_requerimentos
FROM contagem_por_aluno
WHERE total_requerimentos > 1;
```

`LEFT JOIN` inclui alunos sem requerimentos (`total = 0`), tornando a CTE completa. `COUNT(r.id)` conta apenas linhas não-NULL — alunos sem requerimentos ficam com `0`. O filtro `> 1` no SELECT externo isola os casos relevantes.

---

### Exercício 91 — VIEW de requerimentos detalhados

```sql
CREATE OR REPLACE VIEW vw_requerimentos_detalhados AS
SELECT
    u.nome              AS aluno_nome,
    tr.descricao        AS tipo_requerimento,
    r.status,
    r.data_hora_abertura
FROM requerimento r
INNER JOIN aluno a              ON a.matricula = r.aluno_matricula
INNER JOIN usuario u            ON u.id        = a.usuario_id
INNER JOIN tipo_requerimento tr ON tr.id       = r.tipo_requerimento_id;

-- Uso
SELECT * FROM vw_requerimentos_detalhados;
```

Encapsula os quatro JOINs em uma view nomeada. Qualquer consulta futura que precisar dessas informações usa `vw_requerimentos_detalhados` diretamente, sem repetir a lógica.

---

### Exercício 92 — Criar schema e mover tabela

```sql
-- Criar o schema
CREATE SCHEMA IF NOT EXISTS administrativo;

-- Mover a tabela
ALTER TABLE tipo_requerimento SET SCHEMA administrativo;

-- Acesso após a migração
SELECT * FROM administrativo.tipo_requerimento;
```

O schema `administrativo` agrupa objetos de cunho administrativo separados do schema `public`. O `ALTER TABLE ... SET SCHEMA` migra sem recriar — as FKs existentes em `requerimento` são mantidas automaticamente pelo PostgreSQL.

---

### Exercícios 93 a 100 — Ciclo completo de ALTER TABLE

```sql
-- 93: Adicionar coluna telefone
ALTER TABLE usuario ADD COLUMN telefone VARCHAR(20);

-- 94: Alterar o tipo para CHAR(11)
ALTER TABLE usuario ALTER COLUMN telefone TYPE CHAR(11);

-- 95: Tornar obrigatória (NOT NULL)
ALTER TABLE usuario ALTER COLUMN telefone SET NOT NULL;

-- 96: Tornar opcional novamente (DROP NOT NULL)
ALTER TABLE usuario ALTER COLUMN telefone DROP NOT NULL;

-- 97: Renomear para celular
ALTER TABLE usuario RENAME COLUMN telefone TO celular;

-- 98: Adicionar coluna ativo com valor padrão
ALTER TABLE usuario ADD COLUMN ativo BOOLEAN DEFAULT TRUE;

-- 99: Adicionar constraint CHECK nomeada
ALTER TABLE usuario
    ADD CONSTRAINT chk_usuario_ativo CHECK (ativo IS NOT NULL);

-- 100: Remover a constraint pelo nome
ALTER TABLE usuario DROP CONSTRAINT chk_usuario_ativo;
```

Os exercícios 93 a 97 ilustram o **ciclo de vida de uma coluna**: criação → mudança de tipo → restrição → flexibilização → renomeação. Os exercícios 98 a 100 demonstram o fluxo de criação e remoção de constraints nomeadas.

---

## 7. Referências

- [PostgreSQL — Subqueries](https://www.postgresql.org/docs/current/functions-subquery.html)
- [PostgreSQL — WITH Queries (CTEs)](https://www.postgresql.org/docs/current/queries-with.html)
- [PostgreSQL — CREATE VIEW](https://www.postgresql.org/docs/current/sql-createview.html)
- [PostgreSQL — Schemas](https://www.postgresql.org/docs/current/ddl-schemas.html)
- [PostgreSQL — ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)
- **SILBERSCHATZ, A.; KORTH, H. F.; SUDARSHAN, S.** *Sistema de Banco de Dados*. 7. ed. GEN LTC, 2020.
- **ELMASRI, R.; NAVATHE, S. B.** *Sistemas de Banco de Dados*. 6. ed. Pearson, 2011.

---

## 📁 Arquivos desta Aula

```
📁 aula-02/
├── 📄 README.md              # Esta apostila
└── 📄 exercicios_86_100.sql  # Scripts dos exercícios resolvidos
```

---

<div align="center">
  <sub>🏫 Lista de Exercícios — SQL Avançado em PostgreSQL &nbsp;|&nbsp; Implementação e Operação em Banco de Dados</sub>
</div>