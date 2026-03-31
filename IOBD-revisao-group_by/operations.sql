-- 36. Quantidade de requerimentos por status.
SELECT
    status,
    COUNT(status) AS qtde
FROM requerimento
GROUP BY
    status;


-- 37. Tipos com mais de 1 ocorrência.
SELECT
    COUNT(status) AS qtd,
    status
FROM requerimento 
GROUP BY
    status
HAVING COUNT(status) >= 1;

-- 38. Requerimentos por aluno.
SELECT
    aluno.matricula,
    COUNT(requerimento.aluno_matricula)
FROM requerimento
RIGHT JOIN aluno
    ON aluno.matricula = requerimento.aluno_matricula
GROUP BY
    aluno.matricula;


-- 39. Ano de abertura + contagem.
-- (quantos requerimentos por ano)
SELECT
    EXTRACT(YEAR FROM data_hora_abertura) AS ano,
    EXTRACT(MONTH FROM data_hora_abertura) AS mes,
    COUNT(*) AS quantidade
FROM requerimento
GROUP BY 
    ano,
    mes;


-- 40. Mês atual.
SELECT
    EXTRACT(YEAR FROM data_hora_abertura) AS ano,
    EXTRACT(MONTH FROM data_hora_abertura) AS mes,
    CASE
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 1 THEN 'Janeiro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 2 THEN 'Fevereiro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 3 THEN 'Março'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 4 THEN 'Abril'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 5 THEN 'Maio'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 6 THEN 'Junho'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 7 THEN 'Julho'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 8 THEN 'Agosto'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 9 THEN 'Setembro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 10 THEN 'Outubro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 11 THEN 'Novembro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 12 THEN 'Dezembro'
    END
    COUNT(*) AS quantidade
FROM requerimento
GROUP BY 
    ano,
    mes;


-- 41. Média Duração Cursos
SELECT 
    AVG(duracao)::float 
WHERE duracao > 
(
    SELECT 
        CAST(AVG(duracao) as float) AS media_horas_duracao 
    FROM curso
)


-- 42. Cursos acima da média.
SELECT * 
FROM curso
WHERE duracao > 
(
    SELECT 
        CAST(AVG(duracao) as float) AS media_horas_duracao 
    FROM curso
)
