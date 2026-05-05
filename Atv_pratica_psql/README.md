# 📚 Implementação e Operação em Banco de Dados
### Atividade Avaliada — 1º Bimestre | Valor: 5,0 pontos
**Prof. Igor Avila Pereira**

---

## 📋 Sumário

1. [Enunciado](#enunciado)
2. [Modelagem do Banco de Dados](#modelagem-do-banco-de-dados)
3. [Criação das Tabelas](#criação-das-tabelas)
4. [Inserção de Dados de Teste](#inserção-de-dados-de-teste)
5. [Questão 1 — SELECT com JOIN e ORDER BY](#questão-1--select-com-join-e-order-by)
6. [Questão 2 — GROUP BY, HAVING e Filtragem](#questão-2--group-by-having-e-filtragem)
7. [Questão 3 — COALESCE e valores nulos](#questão-3--coalesce-e-valores-nulos)
8. [Questão 4 — CREATE VIEW](#questão-4--create-view)
9. [Questão 5 — Filtro por data e LIMIT](#questão-5--filtro-por-data-e-limit)
10. [Conceitos Abordados](#conceitos-abordados)
11. [Dicas e Erros Comuns](#dicas-e-erros-comuns)

---

## Enunciado

> Considere uma base de dados de um sistema de gerenciamento de academia, organizada da seguinte forma:

- **Tabela `clientes`** → `(id, nome, email, data_cadastro)`
- **Tabela `planos`** → `(id, nome_plano, tipo, valor_mensal)`
- **Tabela `matriculas`** → `(id, cliente_id, plano_id, data_inicio, data_fim, status)`

### Relacionamentos
- Um cliente pode ter **várias matrículas** ao longo do tempo.
- Um plano pode ser contratado por **vários clientes**.
- Trata-se de um relacionamento **N:N** resolvido pela tabela `matriculas`.

### Questões

| # | Enunciado | Valor |
|---|-----------|-------|
| 1 | Escreva uma *query* que liste o nome do cliente, nome do plano e data de início da matrícula. Ordene pelo nome do cliente. | 1,0 |
| 2 | Escreva uma *query* que mostre, para cada plano, a quantidade de clientes **ativos** (`status = 'ativo'`). Mostre apenas planos com **mais de 5** clientes ativos. | 1,0 |
| 3 | Escreva uma *query* que retorne o nome do cliente e a `data_fim` da matrícula, substituindo valores nulos por `Ativo`. | 1,0 |
| 4 | Crie uma **VIEW** chamada `relatorio_planos` que mostre o nome do plano, a quantidade total de matrículas e o valor médio mensal pago pelos clientes. | 1,0 |
| 5 | Escreva uma *query* que retorne o nome e email dos clientes cadastrados nos **últimos 6 meses**. A consulta deve trazer no máximo **10 registros**. | 1,0 |

> **Observação:** O estudante deve criar o banco, as tabelas e inserir alguns registros para testar suas consultas. Todas as queries devem ser escritas em **SQL válido para PostgreSQL**.

---

## Modelagem do Banco de Dados

```
┌──────────────┐         ┌──────────────────┐         ┌─────────────┐
│   clientes   │         │    matriculas     │         │    planos   │
├──────────────┤         ├──────────────────┤         ├─────────────┤
│ id (PK)      │◄───────►│ id (PK)          │◄───────►│ id (PK)     │
│ nome         │         │ cliente_id (FK)  │         │ nome_plano  │
│ email        │         │ plano_id (FK)    │         │ tipo        │
│ data_cadastro│         │ data_inicio      │         │ valor_mensal│
└──────────────┘         │ data_fim         │         └─────────────┘
                         │ status           │
                         └──────────────────┘
```

> Relacionamento **N:N** entre `clientes` e `planos`, intermediado pela tabela `matriculas`.

---

## Criação das Tabelas

```sql
-- Tabela de clientes
CREATE TABLE clientes (
    id             SERIAL PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    email          VARCHAR(100),
    data_cadastro  DATE NOT NULL
);

-- Tabela de planos
CREATE TABLE planos (
    id            SERIAL PRIMARY KEY,
    nome_plano    VARCHAR(100) NOT NULL,
    tipo          VARCHAR(50),
    valor_mensal  NUMERIC(10,2)
);

-- Tabela de matrículas (tabela associativa)
CREATE TABLE matriculas (
    id          SERIAL PRIMARY KEY,
    cliente_id  INT REFERENCES clientes(id),
    plano_id    INT REFERENCES planos(id),
    data_inicio DATE NOT NULL,
    data_fim    DATE,           -- NULL significa matrícula ainda ativa
    status      VARCHAR(20)
);
```

### Pontos importantes
- `SERIAL` → incremento automático (equivalente ao `AUTO_INCREMENT` do MySQL).
- `REFERENCES` → cria a **chave estrangeira (FK)** garantindo integridade referencial.
- `data_fim DATE` → aceita `NULL`, pois matrículas ativas não têm data de encerramento.

---

## Inserção de Dados de Teste

```sql
-- Clientes
INSERT INTO clientes (nome, email, data_cadastro) VALUES
('Ana Silva',      'ana@email.com',     '2024-11-01'),
('Bruno Costa',    'bruno@email.com',   '2024-12-15'),
('Carla Souza',    'carla@email.com',   '2025-01-10'),
('Diego Martins',  'diego@email.com',   '2025-02-20'),
('Eva Lima',       'eva@email.com',     '2025-03-05'),
('Felipe Rocha',   'felipe@email.com',  '2025-04-01'),
('Gabi Nunes',     'gabi@email.com',    '2025-04-10'),
('Hugo Ferreira',  'hugo@email.com',    '2025-04-18'),
('Iris Campos',    'iris@email.com',    '2025-11-30'),
('João Alves',     'joao@email.com',    '2026-02-01');

-- Planos
INSERT INTO planos (nome_plano, tipo, valor_mensal) VALUES
('Plano Basic',    'Mensal',    99.90),
('Plano Premium',  'Mensal',   159.90),
('Plano Anual',    'Anual',     89.90),
('Plano Família',  'Mensal',   199.90);

-- Matrículas
INSERT INTO matriculas (cliente_id, plano_id, data_inicio, data_fim, status) VALUES
(1,  2, '2025-01-01', NULL,         'ativo'),
(2,  1, '2025-01-15', NULL,         'ativo'),
(3,  1, '2025-02-01', NULL,         'ativo'),
(4,  2, '2025-02-10', NULL,         'ativo'),
(5,  1, '2025-03-01', NULL,         'ativo'),
(6,  1, '2025-03-15', NULL,         'ativo'),
(7,  2, '2025-04-01', NULL,         'ativo'),
(8,  3, '2025-04-10', '2025-10-10', 'inativo'),
(9,  1, '2025-04-18', NULL,         'ativo'),
(10, 2, '2026-02-01', NULL,         'ativo'),
(1,  3, '2024-01-01', '2024-12-31', 'inativo'),
(2,  2, '2026-03-01', NULL,         'ativo');
```

---

## Questão 1 — SELECT com JOIN e ORDER BY

**Enunciado:** Liste o nome do cliente, nome do plano e data de início da matrícula, ordenado pelo nome do cliente.

### Conceito: JOIN
O `JOIN` é usado para **combinar linhas de duas ou mais tabelas** com base em uma coluna relacionada entre elas.

```
clientes ──JOIN── matriculas ──JOIN── planos
   (id)      (cliente_id)    (plano_id)   (id)
```

### Solução

```sql
SELECT
    c.nome        AS nome_cliente,
    p.nome_plano  AS nome_plano,
    m.data_inicio AS data_inicio
FROM clientes c
JOIN matriculas m ON m.cliente_id = c.id
JOIN planos p     ON p.id = m.plano_id
ORDER BY c.nome;
```

### Passo a passo

| Passo | O que acontece |
|-------|---------------|
| `FROM clientes c` | Define `clientes` como tabela base, com alias `c` |
| `JOIN matriculas m ON m.cliente_id = c.id` | Liga cada matrícula ao seu respectivo cliente |
| `JOIN planos p ON p.id = m.plano_id` | Liga cada matrícula ao seu plano |
| `SELECT c.nome, p.nome_plano, m.data_inicio` | Seleciona apenas as colunas pedidas |
| `ORDER BY c.nome` | Ordena o resultado alfabeticamente pelo nome |

### Resultado esperado

| nome_cliente | nome_plano    | data_inicio |
|---|---|---|
| Ana Silva    | Plano Premium | 2025-01-01  |
| Ana Silva    | Plano Anual   | 2024-01-01  |
| Bruno Costa  | Plano Basic   | 2025-01-15  |
| ...          | ...           | ...         |

---

## Questão 2 — GROUP BY, HAVING e Filtragem

**Enunciado:** Mostre, para cada plano, a quantidade de clientes ativos. Exiba apenas planos com mais de 5 clientes ativos.

### Conceitos: GROUP BY e HAVING

- `GROUP BY` → **agrupa** linhas com o mesmo valor em uma coluna.
- `HAVING` → filtra **após o agrupamento** (ao contrário do `WHERE`, que filtra antes).
- `COUNT()` → **conta** o número de linhas em cada grupo.

```
WHERE  → filtra linhas ANTES de agrupar
HAVING → filtra grupos DEPOIS de agrupar
```

### Solução

```sql
SELECT
    p.nome_plano,
    COUNT(m.id) AS clientes_ativos
FROM matriculas m
JOIN planos p ON p.id = m.plano_id
WHERE m.status = 'ativo'
GROUP BY p.nome_plano
HAVING COUNT(m.id) > 5;
```

### Passo a passo

| Passo | O que acontece |
|-------|---------------|
| `WHERE m.status = 'ativo'` | Filtra apenas matrículas ativas **antes** de agrupar |
| `GROUP BY p.nome_plano` | Agrupa os resultados por nome do plano |
| `COUNT(m.id)` | Conta quantas matrículas (ativas) cada plano tem |
| `HAVING COUNT(m.id) > 5` | Mantém apenas planos com **mais de 5** ativos |

### Por que não usar WHERE no lugar de HAVING?

```sql
-- ❌ ERRADO — WHERE não pode filtrar funções de agregação
WHERE COUNT(m.id) > 5

-- ✅ CORRETO — HAVING é para filtrar após agregação
HAVING COUNT(m.id) > 5
```

---

## Questão 3 — COALESCE e valores nulos

**Enunciado:** Retorne o nome do cliente e `data_fim`, substituindo valores `NULL` por `'Ativo'`.

### Conceito: COALESCE

`COALESCE(valor, substituto)` retorna o **primeiro valor não-nulo** da lista de argumentos.

```sql
COALESCE(NULL, 'Ativo')   → 'Ativo'
COALESCE('2025-12-31', 'Ativo') → '2025-12-31'
```

### Solução

```sql
SELECT
    c.nome AS nome_cliente,
    COALESCE(CAST(m.data_fim AS VARCHAR), 'Ativo') AS data_fim
FROM matriculas m
JOIN clientes c ON c.id = m.cliente_id;
```

### Passo a passo

| Passo | O que acontece |
|-------|---------------|
| `m.data_fim` | Coluna do tipo `DATE`, pode conter `NULL` |
| `CAST(m.data_fim AS VARCHAR)` | Converte a data para texto para poder comparar com `'Ativo'` |
| `COALESCE(..., 'Ativo')` | Se o resultado do CAST for NULL, retorna `'Ativo'` |

### Por que usar CAST?

O `COALESCE` exige que todos os argumentos sejam do **mesmo tipo**. Como `data_fim` é `DATE` e `'Ativo'` é texto, é necessário converter a data para `VARCHAR`.

### Resultado esperado

| nome_cliente | data_fim   |
|---|---|
| Ana Silva    | Ativo      |
| Bruno Costa  | Ativo      |
| Hugo Ferreira| 2025-10-10 |
| ...          | ...        |

---

## Questão 4 — CREATE VIEW

**Enunciado:** Crie uma VIEW `relatorio_planos` com nome do plano, total de matrículas e valor médio mensal.

### Conceito: VIEW

Uma **VIEW** é uma consulta armazenada no banco de dados que se comporta como uma tabela virtual. Ela não armazena dados fisicamente — apenas a definição da consulta.

**Vantagens:**
- Reutilização de consultas complexas
- Abstração e simplicidade para o usuário final
- Controle de acesso (o usuário vê apenas o que a view expõe)

### Solução

```sql
CREATE OR REPLACE VIEW relatorio_planos AS
SELECT
    p.nome_plano,
    COUNT(m.id)         AS total_matriculas,
    AVG(p.valor_mensal) AS valor_medio_mensal
FROM planos p
LEFT JOIN matriculas m ON m.plano_id = p.id
GROUP BY p.nome_plano, p.valor_mensal;

-- Consultando a view como se fosse uma tabela:
SELECT * FROM relatorio_planos;
```

### Passo a passo

| Passo | O que acontece |
|-------|---------------|
| `CREATE OR REPLACE VIEW` | Cria (ou recria) a view sem erro se já existir |
| `LEFT JOIN` | Inclui planos **mesmo sem matrículas** (COUNT seria 0) |
| `COUNT(m.id)` | Total de matrículas por plano |
| `AVG(p.valor_mensal)` | Média do valor mensal do plano |
| `GROUP BY p.nome_plano, p.valor_mensal` | Agrupa por plano |

### JOIN vs LEFT JOIN

```
INNER JOIN  → retorna apenas linhas que têm correspondência nas duas tabelas
LEFT JOIN   → retorna TODAS as linhas da esquerda, mesmo sem correspondência à direita
```

### Resultado esperado ao consultar a view

| nome_plano    | total_matriculas | valor_medio_mensal |
|---|---|---|
| Plano Basic   | 5                | 99.90              |
| Plano Premium | 5                | 159.90             |
| Plano Anual   | 2                | 89.90              |
| Plano Família | 0                | 199.90             |

---

## Questão 5 — Filtro por data e LIMIT

**Enunciado:** Retorne nome e email dos clientes cadastrados nos últimos 6 meses. Máximo de 10 registros.

### Conceitos: CURRENT_DATE, INTERVAL e LIMIT

- `CURRENT_DATE` → retorna a **data atual** do sistema.
- `INTERVAL '6 months'` → representa um intervalo de tempo.
- `LIMIT n` → restringe o resultado a **n linhas**.

### Solução

```sql
SELECT
    nome,
    email
FROM clientes
WHERE data_cadastro >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY data_cadastro DESC
LIMIT 10;
```

### Passo a passo

| Passo | O que acontece |
|-------|---------------|
| `CURRENT_DATE` | Obtém a data de hoje dinamicamente |
| `- INTERVAL '6 months'` | Subtrai 6 meses da data atual |
| `WHERE data_cadastro >= ...` | Filtra clientes cadastrados a partir desse ponto |
| `ORDER BY data_cadastro DESC` | Mais recentes primeiro |
| `LIMIT 10` | Retorna no máximo 10 registros |

### Exemplo prático

Se hoje é `2026-05-05`, então:
```
CURRENT_DATE - INTERVAL '6 months' = 2025-11-05
```
Serão retornados clientes com `data_cadastro >= 2025-11-05`.

### Outros intervalos úteis no PostgreSQL

```sql
CURRENT_DATE - INTERVAL '1 year'    -- último ano
CURRENT_DATE - INTERVAL '30 days'   -- últimos 30 dias
CURRENT_DATE - INTERVAL '3 months'  -- últimos 3 meses
```

---

## Conceitos Abordados

### DDL — Data Definition Language

Comandos para **definir e estruturar** o banco de dados:

```sql
CREATE TABLE  -- Cria uma nova tabela
CREATE VIEW   -- Cria uma view
ALTER TABLE   -- Modifica estrutura de uma tabela
DROP TABLE    -- Remove uma tabela
```

### DML — Data Manipulation Language

Comandos para **manipular dados**:

```sql
INSERT INTO   -- Insere dados
SELECT        -- Consulta dados
UPDATE        -- Atualiza dados
DELETE        -- Remove dados
```

### Cláusulas de Consulta

| Cláusula | Função |
|---|---|
| `SELECT` | Define quais colunas exibir |
| `FROM` | Define a(s) tabela(s) de origem |
| `JOIN ... ON` | Une tabelas por uma condição |
| `WHERE` | Filtra linhas antes do agrupamento |
| `GROUP BY` | Agrupa linhas por um critério |
| `HAVING` | Filtra grupos após o agrupamento |
| `ORDER BY` | Ordena o resultado |
| `LIMIT` | Restringe o número de linhas retornadas |

### Funções de Agregação

| Função | Descrição |
|---|---|
| `COUNT(coluna)` | Conta linhas não-nulas |
| `SUM(coluna)` | Soma os valores |
| `AVG(coluna)` | Calcula a média |
| `MAX(coluna)` | Retorna o maior valor |
| `MIN(coluna)` | Retorna o menor valor |

### Funções Especiais Usadas

| Função | Uso |
|---|---|
| `COALESCE(a, b)` | Retorna o primeiro valor não-nulo entre `a` e `b` |
| `CAST(valor AS tipo)` | Converte o tipo de um valor |
| `CURRENT_DATE` | Retorna a data atual |
| `INTERVAL 'n unit'` | Define um intervalo de tempo |

### Tipos de JOIN

```
Tabela A    Tabela B
   ┌──┐        ┌──┐
   │  │        │  │

INNER JOIN  → interseção (apenas correspondências)
LEFT JOIN   → tudo de A + correspondências de B
RIGHT JOIN  → correspondências de A + tudo de B
FULL JOIN   → tudo de A e tudo de B
```

---

## Dicas e Erros Comuns

### ❌ Esquecer o alias nas tabelas

```sql
-- ERRADO
FROM clientes
JOIN matriculas ON matriculas.cliente_id = clientes.id

-- CORRETO (mais limpo com aliases)
FROM clientes c
JOIN matriculas m ON m.cliente_id = c.id
```

### ❌ Usar WHERE para filtrar agregações

```sql
-- ERRADO
WHERE COUNT(m.id) > 5

-- CORRETO
HAVING COUNT(m.id) > 5
```

### ❌ Esquecer o CAST no COALESCE com tipos diferentes

```sql
-- ERRADO (tipos incompatíveis: DATE e VARCHAR)
COALESCE(m.data_fim, 'Ativo')

-- CORRETO
COALESCE(CAST(m.data_fim AS VARCHAR), 'Ativo')
```

### ❌ Esquecer a condição ON no JOIN

```sql
-- ERRADO (gera produto cartesiano!)
JOIN matriculas m

-- CORRETO
JOIN matriculas m ON m.cliente_id = c.id
```

### ✅ Boas práticas

- Sempre use **aliases** para tornar o código mais legível.
- Use `OR REPLACE` no `CREATE VIEW` para evitar erros ao recriar.
- Prefira `LEFT JOIN` quando quiser incluir registros sem correspondência.
- Use `ORDER BY` junto com `LIMIT` para resultados previsíveis.
- Teste com `SELECT *` antes de refinar as colunas do `SELECT`.

---

## Script Completo

```sql
-- ================================================
-- BANCO DE DADOS: Sistema de Gerenciamento de Academia
-- Disciplina: Implementação e Operação em Banco de Dados
-- Professor: Igor Avila Pereira
-- ================================================

-- CRIAÇÃO DAS TABELAS
CREATE TABLE clientes (
    id             SERIAL PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    email          VARCHAR(100),
    data_cadastro  DATE NOT NULL
);

CREATE TABLE planos (
    id            SERIAL PRIMARY KEY,
    nome_plano    VARCHAR(100) NOT NULL,
    tipo          VARCHAR(50),
    valor_mensal  NUMERIC(10,2)
);

CREATE TABLE matriculas (
    id          SERIAL PRIMARY KEY,
    cliente_id  INT REFERENCES clientes(id),
    plano_id    INT REFERENCES planos(id),
    data_inicio DATE NOT NULL,
    data_fim    DATE,
    status      VARCHAR(20)
);

-- DADOS DE TESTE
INSERT INTO clientes (nome, email, data_cadastro) VALUES
('Ana Silva',      'ana@email.com',     '2024-11-01'),
('Bruno Costa',    'bruno@email.com',   '2024-12-15'),
('Carla Souza',    'carla@email.com',   '2025-01-10'),
('Diego Martins',  'diego@email.com',   '2025-02-20'),
('Eva Lima',       'eva@email.com',     '2025-03-05'),
('Felipe Rocha',   'felipe@email.com',  '2025-04-01'),
('Gabi Nunes',     'gabi@email.com',    '2025-04-10'),
('Hugo Ferreira',  'hugo@email.com',    '2025-04-18'),
('Iris Campos',    'iris@email.com',    '2025-11-30'),
('João Alves',     'joao@email.com',    '2026-02-01');

INSERT INTO planos (nome_plano, tipo, valor_mensal) VALUES
('Plano Basic',    'Mensal',    99.90),
('Plano Premium',  'Mensal',   159.90),
('Plano Anual',    'Anual',     89.90),
('Plano Família',  'Mensal',   199.90);

INSERT INTO matriculas (cliente_id, plano_id, data_inicio, data_fim, status) VALUES
(1,  2, '2025-01-01', NULL,         'ativo'),
(2,  1, '2025-01-15', NULL,         'ativo'),
(3,  1, '2025-02-01', NULL,         'ativo'),
(4,  2, '2025-02-10', NULL,         'ativo'),
(5,  1, '2025-03-01', NULL,         'ativo'),
(6,  1, '2025-03-15', NULL,         'ativo'),
(7,  2, '2025-04-01', NULL,         'ativo'),
(8,  3, '2025-04-10', '2025-10-10', 'inativo'),
(9,  1, '2025-04-18', NULL,         'ativo'),
(10, 2, '2026-02-01', NULL,         'ativo'),
(1,  3, '2024-01-01', '2024-12-31', 'inativo'),
(2,  2, '2026-03-01', NULL,         'ativo');

-- QUESTÃO 1
SELECT
    c.nome        AS nome_cliente,
    p.nome_plano  AS nome_plano,
    m.data_inicio AS data_inicio
FROM clientes c
JOIN matriculas m ON m.cliente_id = c.id
JOIN planos p     ON p.id = m.plano_id
ORDER BY c.nome;

-- QUESTÃO 2
SELECT
    p.nome_plano,
    COUNT(m.id) AS clientes_ativos
FROM matriculas m
JOIN planos p ON p.id = m.plano_id
WHERE m.status = 'ativo'
GROUP BY p.nome_plano
HAVING COUNT(m.id) > 5;

-- QUESTÃO 3
SELECT
    c.nome AS nome_cliente,
    COALESCE(CAST(m.data_fim AS VARCHAR), 'Ativo') AS data_fim
FROM matriculas m
JOIN clientes c ON c.id = m.cliente_id;

-- QUESTÃO 4
CREATE OR REPLACE VIEW relatorio_planos AS
SELECT
    p.nome_plano,
    COUNT(m.id)         AS total_matriculas,
    AVG(p.valor_mensal) AS valor_medio_mensal
FROM planos p
LEFT JOIN matriculas m ON m.plano_id = p.id
GROUP BY p.nome_plano, p.valor_mensal;

SELECT * FROM relatorio_planos;

-- QUESTÃO 5
SELECT
    nome,
    email
FROM clientes
WHERE data_cadastro >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY data_cadastro DESC
LIMIT 10;
```

---

*Disciplina: Implementação e Operação em Banco de Dados — 1º Bimestre*
*Todas as queries foram escritas e validadas para **PostgreSQL**.*