-- 56. Requerimentos de hoje.
SELECT *
FROM requerimento
-- Aqui DATE() funciona como uma função de conversão de tipo (casting)
-- que extrai apenas a parte de data (AAAA-MM-DD) de um valor de data/hora
-- nesse caso, TIMESTAMP
WHERE DATE(data_hora_abertura) = CURRENT_DATE;

-- 57. Diferença em dias.
-- jump

-- 58. Requerimentos últimos 30 dias.
SELECT * 
FROM requerimento
-- Aqui, INTERVAL '30 days' cria um Intervalo de tempo de 30 dias
-- No Psql, ele é usado para fazer operações com datas e horas
-- WHERE data_hora_abertura CURRENT_DATE - INTERVAL '30 days' ==> traga apenas requerimentos abertos a partir dos últimos 30 dias
-- a Subtração " CURRENT_DATE - INTERVAL '30 days' " garante que essa condição se satisfaça
WHERE data_hora_abertura >= CURRENT_DATE - INTERVAL '30 days';

-- 59. Extrair dia da semana.
SELECT 
    id,
    aluno_matricula,
    status,
    TO_CHAR(data_hora_abertura, 'dd/mm/yyyy HH24:MI'),
    CASE
        WHEN EXTRACT(dow from data_hora_abertura) = 0 THEN 'Domingo'
        WHEN EXTRACT(dow from data_hora_abertura) = 1 THEN 'Segunda'
        WHEN EXTRACT(dow from data_hora_abertura) = 2 THEN 'Terça'
        WHEN EXTRACT(dow from data_hora_abertura) = 3 THEN 'Quarta'
        WHEN EXTRACT(dow from data_hora_abertura) = 4 THEN 'Quinta'
        WHEN EXTRACT(dow from data_hora_abertura) = 5 THEN 'Sexta'
        WHEN EXTRACT(dow from data_hora_abertura) = 6 THEN 'Sábado'
    END AS dia_da_semana
FROM requerimento;

-- 60. Idade do usuário.
SELECT 
    nome,
    cpf,
    AGE(data_nascimento)
FROM usuario; 

