-- ============================================================
-- Exercícios 86–100 | Implementação e Operação em Banco de Dados
-- Tópicos: SUBSELECT · CTE · VIEWS · SCHEMAS · ALTER TABLE
-- ============================================================


-- ==========================
-- SUBSELECT / EXISTS
-- ==========================

-- 86) Liste alunos que possuem pelo menos um requerimento (EXISTS)
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

-- 87) Liste alunos que NÃO possuem requerimento (NOT EXISTS)
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

-- 88) Liste requerimentos cujo tipo seja "Reingresso"
--     (subselect para buscar o id do tipo)
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


-- ==========================
-- CTE (Common Table Expressions)
-- ==========================

-- 89) CTE: listar requerimentos com nome do aluno,
--     filtrando apenas os com status 'em análise'
WITH requerimentos_detalhados AS (
    SELECT
        u.nome              AS aluno_nome,
        r.id                AS requerimento_id,
        r.status,
        tr.descricao        AS tipo,
        r.data_hora_abertura
    FROM requerimento r
    INNER JOIN aluno a          ON a.matricula  = r.aluno_matricula
    INNER JOIN usuario u        ON u.id         = a.usuario_id
    INNER JOIN tipo_requerimento tr ON tr.id    = r.tipo_requerimento_id
)
SELECT *
FROM requerimentos_detalhados
WHERE status = 'em análise';


-- 90) CTE: calcular quantidade de requerimentos por aluno
--     e listar apenas os que possuem mais de 1
WITH contagem_por_aluno AS (
    SELECT
        a.matricula,
        u.nome              AS aluno_nome,
        COUNT(r.id)         AS total_requerimentos
    FROM aluno a
    INNER JOIN usuario u        ON u.id        = a.usuario_id
    LEFT  JOIN requerimento r   ON r.aluno_matricula = a.matricula
    GROUP BY a.matricula, u.nome
)
SELECT
    matricula,
    aluno_nome,
    total_requerimentos
FROM contagem_por_aluno
WHERE total_requerimentos > 1;


-- ==========================
-- VIEWS
-- ==========================

-- 91) VIEW: vw_requerimentos_detalhados
--     Colunas: nome do aluno, tipo do requerimento e status
CREATE OR REPLACE VIEW vw_requerimentos_detalhados AS
SELECT
    u.nome              AS aluno_nome,
    tr.descricao        AS tipo_requerimento,
    r.status,
    r.data_hora_abertura
FROM requerimento r
INNER JOIN aluno a              ON a.matricula  = r.aluno_matricula
INNER JOIN usuario u            ON u.id         = a.usuario_id
INNER JOIN tipo_requerimento tr ON tr.id        = r.tipo_requerimento_id;

-- Consultando a view
SELECT * FROM vw_requerimentos_detalhados;


-- ==========================
-- SCHEMAS
-- ==========================

-- 92) Criar schema 'administrativo' e mover tipo_requerimento para ele

-- Passo 1 — Criar o schema
CREATE SCHEMA IF NOT EXISTS administrativo;

-- Passo 2 — Mover a tabela para o novo schema
ALTER TABLE tipo_requerimento SET SCHEMA administrativo;

-- Agora a tabela é acessada como:
SELECT * FROM administrativo.tipo_requerimento;

-- OBS: como requerimento.tipo_requerimento_id referencia a tabela,
-- a FK continua válida — o PostgreSQL atualiza a referência automaticamente.


-- ==========================
-- ALTER TABLE
-- ==========================

-- 93) Adicionar coluna telefone (VARCHAR)
ALTER TABLE usuario
    ADD COLUMN telefone VARCHAR(20);

-- 94) Alterar o tipo da coluna telefone para CHAR(11)
ALTER TABLE usuario
    ALTER COLUMN telefone TYPE CHAR(11);

-- 95) Definir NOT NULL na coluna telefone
ALTER TABLE usuario
    ALTER COLUMN telefone SET NOT NULL;

-- 96) Remover NOT NULL da coluna telefone
ALTER TABLE usuario
    ALTER COLUMN telefone DROP NOT NULL;

-- 97) Renomear coluna telefone para celular
ALTER TABLE usuario
    RENAME COLUMN telefone TO celular;

-- 98) Adicionar coluna ativo (BOOLEAN com DEFAULT TRUE)
ALTER TABLE usuario
    ADD COLUMN ativo BOOLEAN DEFAULT TRUE;

-- 99) Adicionar constraint CHECK na coluna ativo
--     (garante que o valor nunca seja NULL — reforço extra ao DEFAULT)
ALTER TABLE usuario
    ADD CONSTRAINT chk_usuario_ativo CHECK (ativo IS NOT NULL);

-- 100) Remover a constraint adicionada no exercício 99
ALTER TABLE usuario
    DROP CONSTRAINT chk_usuario_ativo;
