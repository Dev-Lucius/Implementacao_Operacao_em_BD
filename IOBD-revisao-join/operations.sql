-- 1. Liste matrícula e nome do aluno
SELECT 
    usuario.nome AS user,
    aluno.matricula
FROM usuario 
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id;


-- 2. Mesmo exercício usando USING. -> (considerando ajuste estrutural para chave compatível)
-- Para isso, é necessário renomear aluno.usuario_id para id (não recomendado semanticamente), poderia usar:
ALTER TABLE aluno 
RENAME COLUMN usuario_id TO id;
-- ==================
-- Em seguida usamos:
-- ==================
SELECT 
    usuario.nome AS user,
    aluno.matricula
FROM usuario
INNER JOIN aluno
USING (id);


-- 3.  Liste alunos e curso.
SELECT
    usuario.nome AS user,
    aluno.matricula,
    curso.nome AS nome_curso
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN curso
    ON curso.id = aluno.curso_id;


-- 3.  Liste alunos e curso.
SELECT
    usuario.nome AS user,
    aluno.matricula,
    curso.nome AS nome_curso
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN curso
    ON curso.id = aluno.curso_id;


-- 4. Liste requerimentos com tipo (INNER JOIN).
SELECT
    tipo_requerimento.descricao,
    requerimento.status
FROM tipo_requerimento
INNER JOIN requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;


-- 5. LEFT JOIN -> alunos e requerimentos.
SELECT 
    usuario.nome,
    requerimento.data_hora_abertura,
    tipo_requerimento.descricao
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;


-- 6. Liste alunos sem requerimento -> (LEFT + IS NULL).
SELECT 
    usuario.nome,
    requerimento.data_hora_abertura,
    tipo_requerimento.descricao
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
WHERE requerimento.aluno_matricula IS NULL;


-- 7. RIGHT JOIN -> requerimentos e anexos
-- Case Funciona como um IF dentro do SQL
/*
    CASE
        WHEN anexo.descricao IS NULL THEN 'sem descricao'
        ELSE anexo.descricao
    END

    --//--

    if descricao == NULL:
        return "sem descricao"
    else:
        return descricao
*/
SELECT requerimento_id,
    CASE
        WHEN anexo.descricao is NULL THEN 'sem descricao'
    ELSE anexo.descricao 
END as descricao -- Aqui Definimos o nome da Coluna do Resultado
FROM 
    requerimento LEFT JOIN anexo on (requerimento.id = anexo.requerimento_id);

-- Versão alternativa com COALESCE()
-- COALESCE(valor, substituto)
-- ==> se valor for NULL usa-se substituto
SELECT
    anexo.requerimento_id,
    COALESCE(anexo.descricao, 'sem descricao') AS descricao
FROM requerimento
LEFT JOIN anexo
    ON requerimento_id = anexo.requerimento_id; 


-- 8. FULL JOIN aluno e requerimento.
SELECT
    aluno.matricula,
    usuario.nome,
    usuario.cpf
FROM aluno
INNER JOIN usuario
    ON usuario.id = aluno.usuario_id
FULL JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula;


-- 9. Tipos nunca solicitados (LEFT).
SELECT * 
    FROM tipo_requerimento
WHERE id NOT IN (
    -- Criação de um subconsulta que retorna todas FK de requerimento
    SELECT tipo_requerimento_id FROM requerimento
);
-- Versão com Join
SELECT 
    tipo_requerimento.descricao
FROM tipo_requerimento
LEFT JOIN requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
WHERE requerimento.tipo_requerimento_id IS NULL


-- 10. Requerimentos com nome do aluno e tipo.
SELECT
    usuario.nome,
    usuario.cpf,
    usuario.email,
    requerimento.data_hora_abertura,
    tipo_requerimento.descricao
FROM usuario 
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;


-- 11. Liste requerimentos deferidos com nome do aluno (INNER JOIN + WHERE).
SELECT
    aluno.matricula,
    usuario.nome,
    usuario.cpf,
    tipo_requerimento.descricao,
FROM usuario 
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN requerimento 
    ON aluno.matricula = requerimento.aluno_matricula
INNER JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
WHERE requerimento.status = 'DEFERIDO';

-- Versão Com View
-- Pense em VIEW como uma consulta salva no Banco
-- Ela funciona como uma tabela visual
-- Depois de Criada, é possível usar...
-- SELECT * FROM qtde_requerimento_por_tipo;
-- Porém, o banco não vai armazenar os dados da VIEW, apenas a sua Query
-- Ou seja ===> sempre que a view for consultada, o banco executa essa consulta novamente.
CREATE VIEW AS qtde_requerimento_por_tipo AS
SELECT 
    tipo_requerimento.id,
    tipo_requerimento.descricao,
    COUNT(requerimento.tipo_requerimento_id)
FROM requerimento
-- Com o INNER JOIN estamos relacionando: requerimento.tipo_requerimento_id --> tipo_requerimento.id
-- Isso significa que ... > Cada requerimento pertence a um tipo
INNER JOIN tipo_requerimento
    ON (requerimento.tipo_requerimento_id = tipo_requerimento.id)
-- O GROUP BY agrupa os registros para que o COUNT funcione
GROUP BY 
    tipo_requerimento.id,
    tipo_requerimento.descricao,
    requerimento.tipo_requerimento_id;
-- Usando a VIEW !!!
SELECT * FROM qtde_requerimento_por_tipo;


-- 13. Liste alunos e quantidade de requerimentos (LEFT JOIN + GROUP BY).
SELECT
    usuario.nome,
    usuario.cpf,
    aluno.matricula,
    COUNT(requerimento.id) AS quantidade_requerimento
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno_matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
GROUP BY
    usuario.nome,
    usuario.cpf,
    aluno.matricula;


-- 14. Liste apenas alunos com mais de 1 requerimento (HAVING).
SELECT
    usuario.nome,
    usuario.cpf,
    aluno.matricula,
    COUNT(requerimento.id) AS quantidade_requerimento
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno_matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
GROUP BY
    usuario.nome,
    usuario.cpf,
    aluno.matricula
HAVING COUNT(requerimento.id) > 1;


-- 15. Liste requerimentos com quantidade de anexos (LEFT + COALESCE).
SELECT requerimento.id, 
count(requerimento_id) as qtde 
FROM requerimento 
left join anexo 
    on (requerimento.id = anexo.requerimento_id) 
group by 
    requerimento.id, requerimento_id

-- STRING_AGG
-- a função STRING_AGG é usada para concatenar (juntar) várias strings de diferentes linhas em uma única string, usando um separador definido por você.
-- STRING_AGG(coluna, separador)
-- coluna → campo que contém os textos a serem concatenados
-- separador → caractere ou string usada para separar os valores
SELECT 
    requerimento.id, 
    STRING_AGG(anexo.descricao, ',') as lista_de_anexos 
FROM requerimento 
INNER JOIN anexo 
    ON (requerimento.id = anexo.requerimento_id) 
GROUP BY requerimento.id;


-- 16. Liste todos os usuários e suas possíveis matrículas (LEFT JOIN).
SELECT 
    usuario.id, 
    usuario.nome, 
    STRING_AGG(curso.nome, ','), 
    STRING_AGG(aluno.matricula, ';') 
FROM usuario 
INNER JOIN aluno 
    ON usuario.id = aluno.usuario_id 
INNER join curso 
    on curso.id = aluno.curso_id 
GROUP by usuario.id;


-- 17. Liste cursos e alunos (RIGHT JOIN).
SELECT
    curso.nome AS curso,
    aluno.matricula
FROM aluno
RIGHT JOIN curso
    ON aluno.curso_id = curso.id;


-- 18. Liste requerimentos e anexos apenas quando houver anexo (INNER JOIN)
-- INNER JOIN --> mostra somente registros que possuem correspondência nas duas tabelas.
SELECT
    requerimento.id AS requerimento_id,
    anexo.descricao AS anexo
FROM requerimento
INNER JOIN anexo
    ON anexo.requerimento_id = requerimento.id;


-- 19. Liste todos alunos e requerimentos inclusive sem correspondência (FULL JOIN) 
-- FULL JOIN mostra:
-- registros que possuem correspondência
-- registros somente da esquerda
-- registros somente da direita
SELECT
    aluno.matricula,
    requerimento.id AS requerimento_id
FROM aluno
FULL JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula;


-- 20. Utilize JOIN ... USING para listar requerimentos e tipo
SELECT
    requerimento.id,
    tipo_requerimento.descricao
FROM requerimento
JOIN tipo_requerimento
USING (tipo_requerimento_id);