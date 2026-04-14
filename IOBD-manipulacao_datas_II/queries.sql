-- 61. Liste requerimentos abertos nos últimos 7 dias.
SELECT * 
FROM requerimento
WHERE data_hora_abertura >= CURRENT_DATE - INTERVAL '7 days';

-- 62. Liste requerimentos abertos no ano atual.
SELECT * 
FROM requerimento
WHERE DATE(data_hora_abertura) >= '2026/01/01' AND DATE(data_hora_abertura) <= '2026/12/25';

-- 63. Liste requerimentos abertos no mês atual.
SELECT * 
FROM requerimento
WHERE DATE(data_hora_abertura) >= '2026/04/01' AND DATE(data_hora_abertura) <= '2026/04/30';

-- 64. Liste requerimentos e mostre apenas a data (sem hora).
SELECT
    id,
    status,
    DATE(data_hora_abertura)
FROM requerimento;

-- 65. Liste requerimentos e calcule o tempo em dias até o encerramento.
-- 1° Passo) Adicionar uma Nova Coluna à Tabela:
ALTER TABLE requerimento 
ADD COLUMN data_hora_fechamento TIMESTAMP;

-- 2° Passo - Opcional) Atualizar Registros
UPDATE requerimento
SET data_hora_fechamento = data_hora_abertura + INTERVAL '3 days'
WHERE id = 1;

UPDATE requerimento
SET data_hora_fechamento = data_hora_abertura + INTERVAL '12 days'
WHERE id = 2;

UPDATE requerimento
SET data_hora_fechamento = data_hora_abertura + INTERVAL '27 days'
WHERE id = 3;

-- 3° Passo) Construíndo a Consulta
-- O tempo até o encerramento é calculado através da seguinte subtração
-- "" data_hora_fechamento - data_hora_abertura ""
SELECT 
    id,
    data_hora_abertura,
    data_hora_fechamento,
    data_hora_fechamento - data_hora_abertura AS tempo_encerramento
FROM requerimento;

-- Versão Mais "Realista"
-- Considerando requerimentos ainda abertos
SELECT 
    id,
    data_hora_abertura,
    data_hora_fechamento,
    data_hora_fechamento - data_hora_abertura AS tempo_dias
FROM requerimento
WHERE data_hora_fechamento IS NOT NULL;

-- 66. Liste requerimentos mostrando dia da semana da abertura.
SELECT 
    id,
    status,
    -- EXTRACT(DAY FROM column) ==> Retorna o Dia do Mês
    EXTRACT(DAY FROM(data_hora_abertura)) AS dia_mes,
    CASE
        WHEN EXTRACT(dow FROM data_hora_abertura) = 0 THEN 'Domingo'
        WHEN EXTRACT(dow FROM data_hora_abertura) = 1 THEN 'Segunda'
        WHEN EXTRACT(dow FROM data_hora_abertura) = 2 THEN 'Terça'
        WHEN EXTRACT(dow FROM data_hora_abertura) = 3 THEN 'Quarta'
        WHEN EXTRACT(dow FROM data_hora_abertura) = 4 THEN 'Quinta'
        WHEN EXTRACT(dow FROM data_hora_abertura) = 5 THEN 'Sexta'
        WHEN EXTRACT(dow FROM data_hora_abertura) = 6 THEN 'Sábado'
    END AS dia_da_semana
FROM requerimento;

-- 67. Liste requerimentos formatando a data no padrão DD/MM/YYYY.
SELECT
    id,
    status,
    DATE(data_hora_abertura) AS data_abertura
FROM requerimento; 

-- 68. Liste usuários mostrando idade em anos completos.
SELECT 
    nome,
    AGE(data_nascimento)
FROM usuario;

-- 69. Liste requerimentos abertos há mais de 30 dias e ainda “EM ANÁLISE”.
SELECT * 
FROM requerimento
-- data_hora_abertura < CURRENT_DATE - INTERVAL '30 days' ==> garante que os requerimentos selecionados serão mais antigos que 30 dias
WHERE data_hora_abertura < CURRENT_DATE - INTERVAL '30 days'
-- Aqui, asseguramos que tais requerimentos só serão selecionados se seus status forem de "em análise" 
AND status LIKE 'em análise';

-- 70. Liste o primeiro e o último requerimento aberto (mais antigo e mais recente).
-- Requerimento Mais Antigo (O Primeiro)
SELECT *
FROM requerimento
ORDER BY data_hora_abertura ASC -- Ordem Crescente
LIMIT 1; -- Pega o Primeiro Requerimento, que no caso é o mais Antigo


-- Requerimento Mais Novo (O último)
SELECT *
FROM requerimento
ORDER BY data_hora_abertura DESC -- Ordem Decrescente
LIMIT 1; -- Pega o Primeiro Requerimento, que no caso é o mais Recente

-- Usando Funções de Agregação
-- MIN() --> Retorna o Menor Valor de um Atributo
-- MAX() --> Retorna o Maior Valor de um Atributo
SELECT
    MAX(data_hora_abertura) AS primeiro_requerimento,
    MIN(data_hora_abertura) AS ultimo_requerimento
FROM requerimento;

