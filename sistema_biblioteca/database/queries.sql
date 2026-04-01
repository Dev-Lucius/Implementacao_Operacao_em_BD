-- Queries no PostgreSQL

-- ===================
-- NÍVEL 1 – Essencial
-- ===================
-- Exemplares atualmente emprestados
SELECT
    titulo,
    autor,
    codigo,
    CASE
        WHEN disponivel IS TRUE THEN 'Disponível Para Empréstimo'
        WHEN disponivel IS FALSE THEN 'Indisponível Para Empréstimo'
    END
FROM livro
LEFT JOIN exemplar
    ON livro.id = exemplar.livro_id
WHERE disponivel IS FALSE;

-- Usuários que nunca pegaram exemplar
SELECT 
    usuario.nome,
    COUNT(usuario_id) AS exemplares 
FROM usuario
LEFT JOIN emprestimo
    ON usuario.id = emprestimo.usuario_id
GROUP BY 
    usuario.nome
HAVING COUNT(usuario_id) = 0;

-- Quantidade de empréstimos por usuário
SELECT 
    usuario.nome,
    COUNT(usuario_id) AS exemplares 
FROM usuario
LEFT JOIN emprestimo
    ON usuario.id = emprestimo.usuario_id
GROUP BY 
    usuario.nome;

-- Livros e quantidade total de empréstimos
SELECT
    livro.titulo,
    livro.autor,
    exemplar.codigo,
    COUNT(exemplar_id) AS total_emprestimo
FROM livro
INNER JOIN exemplar
    ON livro.id = exemplar.livro_id
RIGHT JOIN emprestimo
    ON exemplar.id = emprestimo.exemplar_id
GROUP BY
    livro.titulo,
    livro.autor,
    exemplar.codigo;

-- Exemplares disponíveis
SELECT
    livro.titulo,
    livro.autor,
    exemplar.codigo,
    exemplar.disponivel
FROM livro
LEFT JOIN exemplar
    ON livro.id = exemplar.livro_id
LEFT JOIN emprestimo
    ON exemplar.id = emprestimo.exemplar_id
WHERE exemplar.disponivel IS TRUE
ORDER BY
    livro.titulo ASC;

-- =======================
-- NÍVEL 2 - Intermediário
-- =======================
-- Ranking de usuários -> Quem mais Realizou Empréstimos
SELECT
    usuario.nome,
    COUNT(emprestimo.usuario_id) AS qtd_emprestimos
FROM usuario
LEFT JOIN emprestimo
    ON usuario.id = emprestimo.usuario_id
GROUP BY
    usuario.nome
ORDER BY 
    COUNT(emprestimo.usuario_id) DESC;

-- Livro mais emprestado
SELECT 
    livro.titulo,
    livro.autor,
    exemplar.codigo,
    COUNT(exemplar_id) AS qtd_emprestimos
FROM livro
LEFT JOIN exemplar
    ON livro.id = exemplar.livro_id
RIGHT JOIN emprestimo
    ON exemplar.id = emprestimo.exemplar_id
GROUP BY 
    livro.titulo,
    livro.autor,
    exemplar.codigo
ORDER BY COUNT(exemplar_id) DESC;

-- Empréstimos em atraso
SELECT
    livro.titulo,
    livro.autor,
    exemplar.codigo,
    emprestimo.data_devolucao
FROM livro
LEFT JOIN exemplar
    ON livro.id = exemplar.livro_id
RIGHT JOIN emprestimo
    ON exemplar.id = emprestimo.exemplar_id
WHERE data_devolucao < NOW();

-- Tempo médio de empréstimo
SELECT
    usuario.nome,
    emprestimo.data_emprestimo,
    emprestimo.data_devolucao,
    CAST(AVG(data_devolucao - data_emprestimo)  as  NUMERIC (10,2)) AS dias
FROM usuario 
INNER JOIN emprestimo
    ON usuario.id = emprestimo.usuario_id
GROUP BY
    usuario.nome,
    emprestimo.data_emprestimo,
    emprestimo.data_devolucao
ORDER BY 
    AVG(data_devolucao - data_emprestimo) DESC;

-- Empréstimos por ano
SELECT
    usuario.nome,
    emprestimo.data_emprestimo,
    emprestimo.data_devolucao,
    EXTRACT(YEAR FROM data_devolucao) AS ano
FROM usuario 
INNER JOIN emprestimo
    ON usuario.id = emprestimo.usuario_id
GROUP BY
    usuario.nome,
    emprestimo.data_emprestimo,
    emprestimo.data_devolucao
ORDER BY 
    EXTRACT(YEAR FROM data_devolucao) DESC;
