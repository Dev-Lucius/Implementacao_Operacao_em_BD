-- 43. Conte quantidade distinta de alunos que abriram requerimento
-- DISTINCT evita contar o mesmo aluno várias vezes.
SELECT COUNT(DISTINCT aluno_matricula) AS total_alunos
FROM requerimento;


-- 44. Liste o aluno com maior número de requerimentos
SELECT
    usuario.nome,
    COUNT(requerimento.id) AS total_requerimentos
FROM usuario
JOIN aluno
    ON usuario.id = aluno.usuario_id
JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
GROUP BY usuario.nome
ORDER BY total_requerimentos DESC -- Ordena do maior para o menor
LIMIT 1;


-- 45. Liste quantidade de requerimentos por ano
SELECT
    EXTRACT(YEAR FROM data_hora_abertura) AS ano,
    COUNT(*) AS total
FROM requerimento
GROUP BY ano
ORDER BY ano;


-- 46. Liste quantidade por mês do ano atual
SELECT
    EXTRACT(MONTH FROM data_hora_abertura) AS mes,
    COUNT(*) AS total
FROM requerimento
WHERE EXTRACT(YEAR FROM data_hora_abertura) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY mes
ORDER BY mes;


-- 47. Média de requerimentos por aluno
SELECT
    AVG(total) AS media_requerimentos -- AVG calcula a média
FROM (
    -- Subconsulta faz o cálculo por aluno
    SELECT COUNT(*) AS total
    FROM requerimento
    GROUP BY aluno_matricula
) sub;


-- 48. Liste tipos ordenados pela quantidade
SELECT
    tipo_requerimento.descricao,
    COUNT(requerimento.id) AS total
FROM tipo_requerimento
JOIN requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
GROUP BY tipo_requerimento.descricao
ORDER BY total DESC;


-- 49. Liste tipos com pelo menos 2 solicitações
SELECT
    tipo_requerimento.descricao,
    COUNT(requerimento.id) AS total
FROM tipo_requerimento
JOIN requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
GROUP BY tipo_requerimento.descricao
-- HAVING filta após a agregação
HAVING COUNT(requerimento.id) >= 2;


-- 50. Quantidade de anexos por requerimento com HAVING > 0
SELECT
    requerimento.id,
    COUNT(anexo.id) AS total_anexos
FROM requerimento
LEFT JOIN anexo
    ON anexo.requerimento_id = requerimento.id
GROUP BY requerimento.id
HAVING COUNT(anexo.id) > 0;


-- 51. Total de requerimentos encerrados por ano
-- Encerrados = Deferido / Indefinido
SELECT
    EXTRACT(YEAR FROM data_hora_abertura) AS ano,
    COUNT(*) AS total
FROM requerimento
WHERE status IN ('deferido','indeferido')
GROUP BY ano
ORDER BY ano;


-- 52. Requerimentos por status ordenados
SELECT
    status,
    COUNT(*) AS total
FROM requerimento
GROUP BY status
ORDER BY total DESC;


-- 53. Liste cursos e total de alunos (JOIN + GROUP)
SELECT
    curso.nome,
    COUNT(aluno.matricula) AS total_alunos
FROM curso
LEFT JOIN aluno
    ON curso.id = aluno.curso_id
GROUP BY curso.nome
ORDER BY total_alunos DESC;


-- 54. Liste cursos com mais de 10 alunos
SELECT
    curso.nome,
    COUNT(aluno.matricula) AS total_alunos
FROM curso
JOIN aluno
    ON curso.id = aluno.curso_id
GROUP BY curso.nome
HAVING COUNT(aluno.matricula) > 10;


-- 55. Liste alunos que abriram requerimento em mais de um ano
SELECT
    aluno_matricula
FROM requerimento
GROUP BY aluno_matricula
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM data_hora_abertura)) > 1;