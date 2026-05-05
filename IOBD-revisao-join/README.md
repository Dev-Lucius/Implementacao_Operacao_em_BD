# 📖 Apostila — JOINs em PostgreSQL

### Implementação e Operação em Banco de Dados

> Fundamentos, tipos, estratégias e boas práticas para combinar tabelas com SQL

---

## Sumário

1. [O que são JOINs?](#1-o-que-são-joins)
   - 1.1 [Por que precisamos de JOINs?](#11-por-que-precisamos-de-joins)
   - 1.2 [Como funciona um JOIN?](#12-como-funciona-um-join)
   - 1.3 [Anatomia de um JOIN](#13-anatomia-de-um-join)
2. [INNER JOIN](#2-inner-join)
   - 2.1 [Conceito](#21-conceito)
   - 2.2 [Sintaxe](#22-sintaxe)
   - 2.3 [Exemplos práticos](#23-exemplos-práticos)
3. [LEFT JOIN (LEFT OUTER JOIN)](#3-left-join-left-outer-join)
   - 3.1 [Conceito](#31-conceito)
   - 3.2 [Sintaxe](#32-sintaxe)
   - 3.3 [Exemplos práticos](#33-exemplos-práticos)
4. [RIGHT JOIN (RIGHT OUTER JOIN)](#4-right-join-right-outer-join)
   - 4.1 [Conceito](#41-conceito)
   - 4.2 [Sintaxe](#42-sintaxe)
   - 4.3 [Exemplos práticos](#43-exemplos-práticos)
5. [FULL JOIN (FULL OUTER JOIN)](#5-full-join-full-outer-join)
   - 5.1 [Conceito](#51-conceito)
   - 5.2 [Sintaxe](#52-sintaxe)
   - 5.3 [Exemplos práticos](#53-exemplos-práticos)
6. [CROSS JOIN](#6-cross-join)
   - 6.1 [Conceito](#61-conceito)
   - 6.2 [Sintaxe e exemplo](#62-sintaxe-e-exemplo)
7. [SELF JOIN](#7-self-join)
   - 7.1 [Conceito](#71-conceito)
   - 7.2 [Sintaxe e exemplo](#72-sintaxe-e-exemplo)
8. [JOIN com múltiplas tabelas](#8-join-com-múltiplas-tabelas)
9. [JOIN com condições adicionais](#9-join-com-condições-adicionais)
10. [Comparativo geral dos tipos de JOIN](#10-comparativo-geral-dos-tipos-de-join)
11. [Erros comuns e como evitá-los](#11-erros-comuns-e-como-evitá-los)
12. [Boas práticas](#12-boas-práticas)
13. [Exercícios comentados](#13-exercícios-comentados)
14. [Referências](#14-referências)

---

## Banco de Dados Utilizado

Todos os exemplos desta apostila usam o banco `sistema_requerimento`:

```sql
usuario           (id PK, nome, email, cpf, data_nascimento, cep, complemento, numero)
curso             (id PK, nome, site, turno, duracao)
aluno             (matricula PK, usuario_id FK → usuario, curso_id FK → curso)
tipo_requerimento (id PK, descricao)
requerimento      (id PK, aluno_matricula FK → aluno, data_hora_abertura, status, tipo_requerimento_id FK → tipo_requerimento)
anexo             (id PK, descricao, arquivo BYTEA, requerimento_id FK → requerimento)
```

**Diagrama de relacionamentos:**

```
usuario ────────── aluno ────────── curso
                     │
                     │
               requerimento ──── tipo_requerimento
                     │
                   anexo
```

---

## 1. O que são JOINs?

### 1.1 Por que precisamos de JOINs?

Bancos de dados relacionais organizam informações em **tabelas separadas** seguindo o princípio da normalização — cada tabela armazena dados de uma entidade específica, sem repetição. Isso é eficiente para armazenamento, mas significa que informações relacionadas ficam distribuídas entre várias tabelas.

Considere o seguinte cenário:

```
Tabela usuario:             Tabela aluno:              Tabela requerimento:
┌────┬─────────────┐        ┌────────────┬──────────┐  ┌────┬──────────────┬──────────┐
│ id │ nome        │        │ matricula  │ usuario  │  │ id │ matricula    │ status   │
├────┼─────────────┤        ├────────────┼──────────┤  ├────┼──────────────┼──────────┤
│  1 │ João Silva  │        │ 2024000001 │    1     │  │  1 │ 2024000001   │ em análi │
│  2 │ Maria Souza │        │ 2024000002 │    2     │  │  2 │ 2024000002   │ deferido │
└────┴─────────────┘        └────────────┴──────────┘  └────┴──────────────┴──────────┘
```

Para responder "Quais requerimentos o João abriu?", precisamos **combinar** as três tabelas. É exatamente isso que os JOINs fazem: **reunir linhas de tabelas diferentes com base em uma condição de ligação**, geralmente uma chave estrangeira.

---

### 1.2 Como funciona um JOIN?

Conceitualmente, o banco de dados executa um JOIN em duas etapas:

**Etapa 1 — Produto cartesiano:** combina cada linha da tabela A com cada linha da tabela B, gerando todas as combinações possíveis.

```
tabela A (3 linhas) × tabela B (3 linhas) = 9 combinações
```

**Etapa 2 — Filtragem pela condição ON:** mantém apenas as combinações onde a condição é verdadeira.

```
9 combinações → filtra por ON → 3 linhas correspondentes
```

Diferentes tipos de JOIN definem o que acontece com as linhas que **não encontram correspondência** na outra tabela.

---

### 1.3 Anatomia de um JOIN

```sql
SELECT                              -- 5. Projeta as colunas desejadas
    tabela_a.coluna1,
    tabela_b.coluna2
FROM tabela_a                       -- 1. Tabela principal (esquerda)
TIPO_JOIN tabela_b                  -- 2. Tipo do JOIN + tabela secundária (direita)
    ON tabela_a.chave = tabela_b.chave_estrangeira  -- 3. Condição de ligação
WHERE condicao_adicional            -- 4. Filtro sobre o resultado do JOIN
ORDER BY tabela_a.coluna1;          -- 6. Ordenação
```

**Terminologia:**

| Termo | Significado |
|---|---|
| Tabela esquerda | A tabela mencionada no `FROM` |
| Tabela direita | A tabela mencionada após o tipo de JOIN |
| Condição `ON` | A expressão que define como as linhas se ligam |
| Linha correspondente | Linha que satisfaz a condição `ON` |
| Linha sem correspondência | Linha que não encontra par na outra tabela |

---

## 2. INNER JOIN

### 2.1 Conceito

O **INNER JOIN** é o tipo de JOIN mais comum e o padrão quando se escreve apenas `JOIN`. Ele retorna **somente as linhas que possuem correspondência em ambas as tabelas**. Linhas sem par são descartadas dos dois lados.

```
Tabela A          Tabela B         INNER JOIN (A ∩ B)
┌───┬─────┐       ┌───┬─────┐       ┌───┬─────┬───┬─────┐
│ 1 │ ... │       │ 1 │ ... │       │ 1 │ ... │ 1 │ ... │
│ 2 │ ... │  ──►  │ 3 │ ... │  =    │ 3 │ ... │ 3 │ ... │
│ 3 │ ... │       │ 4 │ ... │       └───┴─────┴───┴─────┘
└───┴─────┘       └───┴─────┘       (2 e 4 descartados)
```

**Quando usar:** quando você quer apenas registros que tenham dados em ambos os lados — situações onde a ausência de correspondência significa que o registro não é relevante para a consulta.

---

### 2.2 Sintaxe

```sql
-- Forma completa (explícita)
SELECT colunas
FROM tabela_a
INNER JOIN tabela_b ON tabela_a.chave = tabela_b.chave_estrangeira;

-- Forma abreviada (JOIN sem o INNER é idêntico)
SELECT colunas
FROM tabela_a
JOIN tabela_b ON tabela_a.chave = tabela_b.chave_estrangeira;
```

---

### 2.3 Exemplos práticos

**Exemplo 1 — Nome do aluno e sua matrícula:**

```sql
-- Problema: a tabela aluno tem a matricula, mas o nome está em usuario
SELECT
    u.nome       AS nome_aluno,
    a.matricula
FROM aluno a
INNER JOIN usuario u ON u.id = a.usuario_id;
```

```
nome_aluno      | matricula
----------------+-----------
João Silva      | 2024000001
Maria Oliveira  | 2024000002
Carlos Souza    | 2024000003
```

> Apenas alunos que têm um `usuario_id` válido aparecem. Se um aluno existisse sem usuário correspondente, seria descartado.

---

**Exemplo 2 — Requerimentos com nome do aluno e status:**

```sql
SELECT
    u.nome              AS aluno_nome,
    r.id                AS requerimento_id,
    r.status,
    r.data_hora_abertura
FROM requerimento r
INNER JOIN aluno a   ON a.matricula  = r.aluno_matricula
INNER JOIN usuario u ON u.id         = a.usuario_id;
```

Neste exemplo, dois INNER JOINs encadeados percorrem o caminho: `requerimento → aluno → usuario`.

---

**Exemplo 3 — Aluno, curso e requerimento (três tabelas):**

```sql
SELECT
    u.nome          AS aluno,
    c.nome          AS curso,
    r.status        AS status_requerimento
FROM requerimento r
INNER JOIN aluno a              ON a.matricula = r.aluno_matricula
INNER JOIN usuario u            ON u.id        = a.usuario_id
INNER JOIN curso c              ON c.id        = a.curso_id;
```

---

## 3. LEFT JOIN (LEFT OUTER JOIN)

### 3.1 Conceito

O **LEFT JOIN** retorna **todas as linhas da tabela esquerda** (a do `FROM`), e as colunas da tabela direita são preenchidas com `NULL` quando não há correspondência.

```
Tabela A (esquerda)   Tabela B (direita)    LEFT JOIN
┌───┬─────┐           ┌───┬─────┐           ┌───┬─────┬──────┬──────┐
│ 1 │ ... │           │ 1 │ ... │           │ 1 │ ... │  1   │ ...  │
│ 2 │ ... │    ──►    │ 3 │ ... │    =      │ 2 │ ... │ NULL │ NULL │  ← sem par
│ 3 │ ... │           │ 4 │ ... │           │ 3 │ ... │  3   │ ...  │
└───┴─────┘           └───┴─────┘           └───┴─────┴──────┴──────┘
                                            (linha 4 de B descartada)
```

**Regra de ouro:** o LEFT JOIN **nunca descarta linhas da tabela esquerda**. Se não há correspondência, as colunas da direita vêm como `NULL`.

**Quando usar:**
- Listar todos os registros de uma tabela, incluindo os que ainda não têm dados associados.
- Verificar quais registros estão "sem vínculo" (filtrando por `IS NULL` depois).
- Relatórios onde ausência de dado também é informação relevante.

---

### 3.2 Sintaxe

```sql
SELECT colunas
FROM tabela_esquerda te
LEFT JOIN tabela_direita td ON td.chave_fk = te.chave_pk;

-- LEFT OUTER JOIN é idêntico ao LEFT JOIN
LEFT OUTER JOIN tabela_direita td ON td.chave_fk = te.chave_pk;
```

---

### 3.3 Exemplos práticos

**Exemplo 1 — Todos os alunos, com ou sem requerimento:**

```sql
SELECT
    u.nome          AS aluno_nome,
    a.matricula,
    r.id            AS requerimento_id,
    r.status
FROM aluno a
INNER JOIN usuario u    ON u.id           = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula;
```

```
aluno_nome      | matricula   | requerimento_id | status
----------------+-------------+-----------------+----------
João Silva      | 2024000001  | 1               | em análise
Maria Oliveira  | 2024000002  | 2               | deferido
Carlos Souza    | 2024000003  | 3               | indeferido
Ana Lima        | 2024000004  | NULL            | NULL       ← sem requerimento
```

> Ana Lima aparece mesmo sem requerimento — isso seria impossível com INNER JOIN.

---

**Exemplo 2 — Identificar alunos que NUNCA abriram requerimento:**

```sql
-- Técnica: LEFT JOIN + filtro IS NULL na coluna da tabela direita
SELECT
    u.nome      AS aluno_sem_requerimento,
    a.matricula
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
WHERE r.id IS NULL;
```

Este padrão — `LEFT JOIN + WHERE coluna_direita IS NULL` — é uma alternativa ao `NOT EXISTS` e serve para encontrar registros "órfãos".

---

**Exemplo 3 — Contagem de requerimentos por aluno (incluindo zero):**

```sql
SELECT
    u.nome          AS aluno_nome,
    COUNT(r.id)     AS total_requerimentos
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
GROUP BY u.nome
ORDER BY total_requerimentos DESC;
```

> `COUNT(r.id)` conta apenas valores não-NULL, então alunos sem requerimento aparecem com `0` — não com `NULL`.

---

## 4. RIGHT JOIN (RIGHT OUTER JOIN)

### 4.1 Conceito

O **RIGHT JOIN** é o espelho do LEFT JOIN. Retorna **todas as linhas da tabela direita** (a mencionada após o `JOIN`), preenchendo com `NULL` as colunas da esquerda quando não há correspondência.

```
Tabela A (esquerda)   Tabela B (direita)    RIGHT JOIN
┌───┬─────┐           ┌───┬─────┐           ┌──────┬──────┬───┬─────┐
│ 1 │ ... │           │ 1 │ ... │           │  1   │ ...  │ 1 │ ... │
│ 2 │ ... │    ──►    │ 3 │ ... │    =      │  3   │ ...  │ 3 │ ... │
│ 3 │ ... │           │ 4 │ ... │           │ NULL │ NULL │ 4 │ ... │  ← sem par
└───┴─────┘           └───┴─────┘           └──────┴──────┴───┴─────┘
                                            (linha 2 de A descartada)
```

**Na prática:** o RIGHT JOIN é raramente necessário, pois qualquer consulta com RIGHT JOIN pode ser reescrita como LEFT JOIN invertendo a ordem das tabelas. A preferência pelo LEFT JOIN é uma questão de legibilidade e convenção.

```sql
-- Estas duas queries são equivalentes:
SELECT * FROM a RIGHT JOIN b ON ...;
SELECT * FROM b LEFT  JOIN a ON ...;
```

---

### 4.2 Sintaxe

```sql
SELECT colunas
FROM tabela_esquerda te
RIGHT JOIN tabela_direita td ON td.chave_fk = te.chave_pk;
```

---

### 4.3 Exemplos práticos

**Exemplo — Todos os tipos de requerimento, mesmo os sem requerimentos associados:**

```sql
SELECT
    tr.descricao        AS tipo_requerimento,
    r.id                AS requerimento_id,
    r.status
FROM requerimento r
RIGHT JOIN tipo_requerimento tr ON tr.id = r.tipo_requerimento_id;
```

```
tipo_requerimento           | requerimento_id | status
----------------------------+-----------------+----------
Declaração de Matrícula     | 1               | em análise
Aproveitamento de Disciplina| 2               | deferido
Trancamento de Curso        | 3               | indeferido
Reingresso                  | NULL            | NULL       ← tipo sem uso ainda
```

**A mesma query reescrita com LEFT JOIN** (forma preferida):

```sql
SELECT
    tr.descricao        AS tipo_requerimento,
    r.id                AS requerimento_id,
    r.status
FROM tipo_requerimento tr
LEFT JOIN requerimento r ON r.tipo_requerimento_id = tr.id;
```

---

## 5. FULL JOIN (FULL OUTER JOIN)

### 5.1 Conceito

O **FULL JOIN** combina o comportamento do LEFT e do RIGHT JOIN. Retorna **todas as linhas de ambas as tabelas** — com correspondência quando existe, e `NULL` nas colunas do lado oposto quando não existe.

```
Tabela A (esquerda)   Tabela B (direita)    FULL JOIN
┌───┬─────┐           ┌───┬─────┐           ┌───┬─────┬──────┬──────┐
│ 1 │ ... │           │ 1 │ ... │           │ 1 │ ... │  1   │ ...  │  ← match
│ 2 │ ... │    ──►    │ 3 │ ... │    =      │ 2 │ ... │ NULL │ NULL │  ← só em A
│ 3 │ ... │           │ 4 │ ... │           │ 3 │ ... │  3   │ ...  │  ← match
└───┴─────┘           └───┴─────┘           │NULL│NULL │  4   │ ...  │  ← só em B
                                            └───┴─────┴──────┴──────┘
```

**Quando usar:**
- Comparar duas tabelas e encontrar registros exclusivos de cada lado.
- Auditorias e reconciliação de dados.
- Detectar inconsistências entre conjuntos de dados.

---

### 5.2 Sintaxe

```sql
SELECT colunas
FROM tabela_a
FULL JOIN tabela_b ON tabela_a.chave = tabela_b.chave;

-- FULL OUTER JOIN é idêntico
FULL OUTER JOIN tabela_b ON ...;
```

---

### 5.3 Exemplos práticos

**Exemplo 1 — Todos os alunos e todos os requerimentos, com ou sem vínculo:**

```sql
SELECT
    u.nome          AS aluno_nome,
    a.matricula,
    r.id            AS requerimento_id,
    r.status
FROM aluno a
FULL JOIN requerimento r  ON r.aluno_matricula = a.matricula
LEFT JOIN usuario u       ON u.id              = a.usuario_id;
```

---

**Exemplo 2 — Reconciliação: detectar inconsistências entre cursos e alunos:**

```sql
SELECT
    c.nome          AS curso,
    a.matricula     AS aluno_matricula
FROM curso c
FULL JOIN aluno a ON a.curso_id = c.id
WHERE c.id IS NULL        -- alunos sem curso válido
   OR a.matricula IS NULL -- cursos sem nenhum aluno
ORDER BY c.nome NULLS LAST;
```

Este padrão — `FULL JOIN + WHERE ... IS NULL` — é poderoso para auditorias de integridade referencial.

---

## 6. CROSS JOIN

### 6.1 Conceito

O **CROSS JOIN** gera o **produto cartesiano** entre duas tabelas — ou seja, combina cada linha da tabela A com cada linha da tabela B, sem nenhuma condição de ligação.

```
Tabela A (3 linhas) × Tabela B (3 linhas) = 9 combinações

A1 × B1,  A1 × B2,  A1 × B3
A2 × B1,  A2 × B2,  A2 × B3
A3 × B1,  A3 × B2,  A3 × B3
```

**Quando usar:** geração de combinações para testes, grades de horários, matrizes de preços, ou qualquer situação onde todas as combinações entre dois conjuntos são necessárias.

> ⚠️ **Cuidado com o volume:** se A tem 1.000 linhas e B tem 1.000 linhas, o resultado tem 1.000.000 de linhas. O CROSS JOIN cresce exponencialmente.

---

### 6.2 Sintaxe e exemplo

```sql
-- Sintaxe explícita
SELECT colunas
FROM tabela_a
CROSS JOIN tabela_b;

-- Sintaxe implícita (virgula no FROM — evite, menos legível)
SELECT colunas
FROM tabela_a, tabela_b;
```

**Exemplo — Todas as combinações possíveis de turno e curso:**

```sql
SELECT
    c.nome          AS curso,
    turnos.turno    AS turno_disponivel
FROM curso c
CROSS JOIN (
    VALUES ('noturno'), ('diurno'), ('vespertino')
) AS turnos(turno)
ORDER BY c.nome, turnos.turno;
```

```
curso                    | turno_disponivel
-------------------------+------------------
Administração            | diurno
Administração            | noturno
Administração            | vespertino
Direito                  | diurno
Direito                  | noturno
...
```

---

## 7. SELF JOIN

### 7.1 Conceito

Um **SELF JOIN** não é um tipo especial de JOIN — é qualquer JOIN onde a tabela se relaciona **consigo mesma**. É necessário usar **aliases** para distinguir as duas "instâncias" da mesma tabela.

**Quando usar:** tabelas com hierarquias (funcionário → gerente), auto-referências (categoria pai → categoria filho), ou comparações entre linhas da mesma tabela.

---

### 7.2 Sintaxe e exemplo

```sql
SELECT
    a.coluna    AS instancia_1,
    b.coluna    AS instancia_2
FROM tabela a        -- primeira instância
JOIN tabela b        -- segunda instância (mesma tabela!)
    ON a.chave_fk = b.chave_pk;
```

**Exemplo — Comparar alunos do mesmo curso (pares de colegas):**

```sql
-- Encontrar todos os pares de alunos que fazem o mesmo curso
SELECT
    u1.nome         AS aluno_1,
    u2.nome         AS aluno_2,
    c.nome          AS curso_compartilhado
FROM aluno a1
INNER JOIN aluno a2     ON  a1.curso_id   = a2.curso_id
                        AND a1.matricula  < a2.matricula  -- evita pares duplicados e auto-comparação
INNER JOIN usuario u1   ON  u1.id         = a1.usuario_id
INNER JOIN usuario u2   ON  u2.id         = a2.usuario_id
INNER JOIN curso c      ON  c.id          = a1.curso_id;
```

> A condição `a1.matricula < a2.matricula` garante que cada par apareça apenas uma vez e que um aluno não seja comparado consigo mesmo.

**Exemplo com hierarquia — tabela de usuários com referência ao supervisor:**

```sql
-- Suponha que usuario tivesse uma coluna supervisor_id FK → usuario.id
SELECT
    u.nome          AS usuario,
    sup.nome        AS supervisor
FROM usuario u
LEFT JOIN usuario sup ON sup.id = u.supervisor_id;
```

---

## 8. JOIN com múltiplas tabelas

É possível encadear quantos JOINs forem necessários. O PostgreSQL executa os JOINs da esquerda para a direita, e cada novo JOIN pode usar colunas de qualquer tabela já incluída até aquele ponto.

**Exemplo — Query completa percorrendo todo o modelo:**

```sql
SELECT
    u.nome              AS aluno_nome,
    u.email             AS email,
    c.nome              AS curso,
    c.turno             AS turno_curso,
    tr.descricao        AS tipo_requerimento,
    r.status            AS status,
    r.data_hora_abertura AS aberto_em,
    an.descricao        AS anexo_descricao
FROM requerimento r
INNER JOIN aluno a              ON a.matricula  = r.aluno_matricula
INNER JOIN usuario u            ON u.id         = a.usuario_id
INNER JOIN curso c              ON c.id         = a.curso_id
INNER JOIN tipo_requerimento tr ON tr.id        = r.tipo_requerimento_id
LEFT  JOIN anexo an             ON an.requerimento_id = r.id
ORDER BY r.data_hora_abertura DESC;
```

**Por que `LEFT JOIN` só no `anexo`?** Porque um requerimento pode não ter anexo — usar INNER JOIN descartaria esses requerimentos do resultado. Para as outras tabelas, a correspondência é garantida pelas chaves estrangeiras.

---

**Estratégia para construir JOINs encadeados:**

```
1. Comece pela tabela central da query (geralmente a que tem as FKs)
2. Adicione um JOIN por vez, na direção das dependências
3. Use INNER JOIN quando a correspondência é obrigatória
4. Use LEFT JOIN quando a ausência de dado é possível e válida
5. Teste cada JOIN isoladamente antes de encadear o próximo
```

---

## 9. JOIN com condições adicionais

A cláusula `ON` aceita qualquer expressão booleana, não apenas igualdade de chaves. É possível adicionar condições extras diretamente no `ON` ou no `WHERE`.

### Condição adicional no ON

Filtra **durante** o JOIN — afeta quais linhas participam da combinação, mas não remove linhas da tabela esquerda em LEFT JOINs:

```sql
-- Traz todos os alunos; para cada um, mostra apenas requerimentos 'deferidos'
-- (alunos sem requerimento deferido ainda aparecem, com NULL nas colunas de r)
SELECT
    u.nome,
    r.id        AS requerimento_deferido,
    r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
                         AND r.status = 'deferido';    -- condição no ON
```

### Condição no WHERE

Filtra **após** o JOIN — remove linhas do resultado final, incluindo as que vieram `NULL` de um LEFT JOIN:

```sql
-- Traz apenas alunos QUE TÊM requerimentos deferidos
-- (alunos sem requerimento deferido são eliminados pelo WHERE)
SELECT
    u.nome,
    r.id        AS requerimento_deferido,
    r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
WHERE r.status = 'deferido';                           -- condição no WHERE
```

**Diferença fundamental:**

| | `ON` (durante o JOIN) | `WHERE` (após o JOIN) |
|---|---|---|
| LEFT JOIN | Mantém linhas sem correspondência (NULL) | Elimina linhas com NULL |
| INNER JOIN | Equivalente ao WHERE para condições simples | Equivalente ao ON |
| Uso típico | Filtrar quais dados da direita participam | Filtrar o resultado final |

---

## 10. Comparativo geral dos tipos de JOIN

```
Conjunto A = linhas da tabela esquerda
Conjunto B = linhas da tabela direita
∩ = interseção (correspondência encontrada)

INNER JOIN          LEFT JOIN           RIGHT JOIN          FULL JOIN
    A ∩ B              A + ∩              ∩ + B             A + ∩ + B

  ┌──┬──┐            ┌──┬──┐            ┌──┬──┐            ┌──┬──┐
  │  │██│            │██│██│            │  │██│            │██│██│
  │  │██│            │██│██│            │  │██│            │██│██│
  └──┴──┘            └──┴──┘            └──┴──┘            └──┴──┘
 Só o que é         Tudo de A          Tudo de B          Tudo de A
 comum              + comum            + comum            e de B
```

| Tipo | Linhas da esquerda sem par | Linhas da direita sem par | Uso principal |
|---|---|---|---|
| `INNER JOIN` | ❌ descartadas | ❌ descartadas | Dados que existem em ambos os lados |
| `LEFT JOIN` | ✅ incluídas (NULL direita) | ❌ descartadas | Todos da esquerda + o que existe na direita |
| `RIGHT JOIN` | ❌ descartadas | ✅ incluídas (NULL esquerda) | Todos da direita + o que existe na esquerda |
| `FULL JOIN` | ✅ incluídas (NULL direita) | ✅ incluídas (NULL esquerda) | Todos de ambos os lados |
| `CROSS JOIN` | — (sem condição ON) | — (sem condição ON) | Produto cartesiano, todas as combinações |
| `SELF JOIN` | Depende do tipo usado | Depende do tipo usado | Auto-referência dentro da mesma tabela |

---

## 11. Erros comuns e como evitá-los

### Erro 1 — Colunas ambíguas (sem alias de tabela)

```sql
-- ❌ ERRADO: qual tabela tem a coluna "id"?
SELECT id, nome, status
FROM requerimento
INNER JOIN usuario ON usuario.id = aluno.usuario_id;
-- ERROR: column reference "id" is ambiguous

-- ✅ CORRETO: prefixar com o alias da tabela
SELECT r.id, u.nome, r.status
FROM requerimento r
INNER JOIN aluno a   ON a.matricula  = r.aluno_matricula
INNER JOIN usuario u ON u.id         = a.usuario_id;
```

**Regra:** sempre use aliases de tabela (`r`, `u`, `a`) e prefixe todas as colunas quando há mais de uma tabela.

---

### Erro 2 — Confundir ON com WHERE em LEFT JOINs

```sql
-- ❌ Intenção: todos os alunos, mostrando apenas requerimentos deferidos
-- Resultado real: só alunos COM requerimento deferido (LEFT JOIN virou INNER JOIN)
SELECT u.nome, r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
WHERE r.status = 'deferido';    -- filtra APÓS o JOIN, remove NULLs

-- ✅ CORRETO: condição no ON preserva todos os alunos
SELECT u.nome, r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
                         AND r.status = 'deferido';
```

---

### Erro 3 — Multiplicação de linhas (JOIN sem chave única)

```sql
-- Se um aluno tem 3 requerimentos e 2 anexos cada,
-- o resultado pode ter 3×2 = 6 linhas por aluno sem perceber
SELECT u.nome, r.id, an.descricao
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
INNER JOIN requerimento r ON r.aluno_matricula = a.matricula
INNER JOIN anexo an       ON an.requerimento_id = r.id;
-- Isso é correto APENAS se você quer uma linha por combinação requerimento+anexo
```

> Sempre verifique a cardinalidade dos relacionamentos antes de construir JOINs encadeados.

---

### Erro 4 — CROSS JOIN acidental

```sql
-- ❌ Esquecer a condição ON gera produto cartesiano silencioso
SELECT u.nome, c.nome
FROM usuario u
JOIN curso c;   -- sem ON → CROSS JOIN implícito em algumas versões
-- ERROR no PostgreSQL: JOIN sem ON exige CROSS JOIN explícito

-- ✅ CORRETO: sempre especifique a condição
SELECT u.nome, c.nome
FROM aluno a
JOIN usuario u ON u.id  = a.usuario_id
JOIN curso c   ON c.id  = a.curso_id;
```

---

### Erro 5 — Usar `COUNT(*)` ao invés de `COUNT(coluna)` após LEFT JOIN

```sql
-- ❌ COUNT(*) conta a linha NULL como 1
SELECT u.nome, COUNT(*) AS total_requerimentos
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
GROUP BY u.nome;
-- Aluno sem requerimento aparece com total = 1 (incorreto!)

-- ✅ COUNT(r.id) ignora NULLs
SELECT u.nome, COUNT(r.id) AS total_requerimentos
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
GROUP BY u.nome;
-- Aluno sem requerimento aparece com total = 0 (correto!)
```

---

## 12. Boas práticas

### Sempre use aliases de tabela

```sql
-- ❌ Sem alias — difícil de ler, propenso a ambiguidades
SELECT usuario.nome, requerimento.status
FROM requerimento
INNER JOIN aluno ON aluno.matricula = requerimento.aluno_matricula
INNER JOIN usuario ON usuario.id = aluno.usuario_id;

-- ✅ Com aliases — limpo e sem ambiguidade
SELECT u.nome, r.status
FROM requerimento r
INNER JOIN aluno a   ON a.matricula = r.aluno_matricula
INNER JOIN usuario u ON u.id        = a.usuario_id;
```

---

### Nomeie colunas com AS quando necessário

```sql
-- ❌ Colunas com nomes genéricos ou colisões
SELECT u.nome, c.nome, r.id
FROM ...

-- ✅ Colunas nomeadas com clareza
SELECT
    u.nome   AS nome_aluno,
    c.nome   AS nome_curso,
    r.id     AS requerimento_id
FROM ...
```

---

### Ordene os JOINs da tabela central para as dependências

```sql
-- ✅ Começa pela tabela principal (requerimento) e expande para as dependências
FROM requerimento r
INNER JOIN aluno a              ON a.matricula = r.aluno_matricula   -- aluno do req
INNER JOIN usuario u            ON u.id        = a.usuario_id        -- dados do aluno
INNER JOIN curso c              ON c.id        = a.curso_id          -- curso do aluno
INNER JOIN tipo_requerimento tr ON tr.id       = r.tipo_requerimento_id -- tipo do req
LEFT  JOIN anexo an             ON an.requerimento_id = r.id         -- anexos (opcional)
```

---

### Use INNER ou LEFT com intenção consciente

```sql
-- Pergunte para cada JOIN:
-- "É possível que não exista correspondência?"
--   └─ Não (FK obrigatória) → INNER JOIN
--   └─ Sim (dado opcional)  → LEFT JOIN
```

---

### Prefira LEFT JOIN a RIGHT JOIN

RIGHT JOIN é equivalente a LEFT JOIN com as tabelas invertidas. LEFT JOIN é a convenção mais legível e amplamente usada:

```sql
-- Prefira isto:
FROM tipo_requerimento tr
LEFT JOIN requerimento r ON r.tipo_requerimento_id = tr.id

-- Em vez de:
FROM requerimento r
RIGHT JOIN tipo_requerimento tr ON tr.id = r.tipo_requerimento_id
```

---

## 13. Exercícios comentados

### Exercício A — INNER JOIN simples

**Problema:** listar todos os requerimentos com o nome do aluno e a descrição do tipo.

```sql
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

**Por que INNER JOIN em todos?** Cada relacionamento é obrigatório: todo requerimento tem aluno, todo aluno tem usuário, todo requerimento tem tipo.

---

### Exercício B — LEFT JOIN para incluir dados ausentes

**Problema:** listar todos os alunos e seus requerimentos. Alunos sem requerimento devem aparecer com a coluna de requerimento como NULL.

```sql
SELECT
    u.nome              AS aluno_nome,
    a.matricula,
    r.id                AS requerimento_id,
    r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
ORDER BY u.nome;
```

**Por que LEFT JOIN no requerimento?** Um aluno pode não ter requerimento. Com INNER JOIN, esses alunos desapareceriam do resultado.

---

### Exercício C — LEFT JOIN para encontrar ausências

**Problema:** listar apenas os alunos que ainda não abriram nenhum requerimento.

```sql
SELECT
    u.nome      AS aluno_sem_requerimento,
    a.matricula,
    a.curso_id
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
WHERE r.id IS NULL;
```

**Técnica:** LEFT JOIN traz todos os alunos; `WHERE r.id IS NULL` filtra apenas os que não têm correspondência — ou seja, os sem requerimento.

---

### Exercício D — FULL JOIN para auditoria

**Problema:** verificar se há tipos de requerimento nunca utilizados OU requerimentos sem tipo associado.

```sql
SELECT
    tr.id           AS tipo_id,
    tr.descricao    AS tipo_descricao,
    r.id            AS requerimento_id,
    r.status
FROM tipo_requerimento tr
FULL JOIN requerimento r ON r.tipo_requerimento_id = tr.id
WHERE tr.id IS NULL      -- requerimento sem tipo
   OR r.id IS NULL       -- tipo nunca usado
ORDER BY tr.descricao NULLS LAST;
```

---

### Exercício E — JOIN encadeado com agrupamento

**Problema:** contar quantos requerimentos cada curso possui, ordenando do maior para o menor.

```sql
SELECT
    c.nome          AS curso,
    COUNT(r.id)     AS total_requerimentos
FROM curso c
LEFT  JOIN aluno a              ON a.curso_id      = c.id
LEFT  JOIN requerimento r       ON r.aluno_matricula = a.matricula
GROUP BY c.nome
ORDER BY total_requerimentos DESC;
```

**Por que dois LEFT JOINs?** Um curso pode não ter alunos; um aluno pode não ter requerimentos. Usar INNER JOIN descartaria cursos sem requerimentos.

---

### Exercício F — Condição extra no ON vs WHERE

**Problema A:** para cada aluno, mostrar seus requerimentos deferidos. Alunos sem requerimento deferido ainda devem aparecer.

```sql
-- Condição no ON: alunos sem requerimento deferido aparecem com NULL
SELECT
    u.nome,
    r.id     AS req_deferido,
    r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
LEFT  JOIN requerimento r ON r.aluno_matricula = a.matricula
                         AND r.status = 'deferido';
```

**Problema B:** mostrar apenas alunos que têm pelo menos um requerimento deferido.

```sql
-- Condição no WHERE: só aparece quem tem requerimento deferido
SELECT
    u.nome,
    r.id     AS req_deferido,
    r.status
FROM aluno a
INNER JOIN usuario u      ON u.id              = a.usuario_id
INNER JOIN requerimento r ON r.aluno_matricula = a.matricula
WHERE r.status = 'deferido';
```

---

## 14. Referências

- [PostgreSQL — Documentação oficial: Table Expressions (JOINs)](https://www.postgresql.org/docs/current/queries-table-expressions.html)
- [PostgreSQL — Documentação oficial: FROM Clause](https://www.postgresql.org/docs/current/sql-select.html#SQL-FROM)
- **SILBERSCHATZ, A.; KORTH, H. F.; SUDARSHAN, S.** *Sistema de Banco de Dados*. 7. ed. GEN LTC, 2020. Cap. 4 — SQL Avançado.
- **ELMASRI, R.; NAVATHE, S. B.** *Sistemas de Banco de Dados*. 6. ed. Pearson, 2011. Cap. 8 — SQL.
- **DATE, C. J.** *Introdução a Sistemas de Banco de Dados*. 8. ed. Campus, 2004.

---

## 📁 Arquivos desta Aula

```
📁 aula-joins/
├── 📄 README.md      # Esta apostila
└── 📄 exemplos.sql   # Todos os exemplos e exercícios em SQL
```

---

<div align="center">
  <sub>🏫 JOINs em PostgreSQL &nbsp;|&nbsp; Implementação e Operação em Banco de Dados</sub>
</div>