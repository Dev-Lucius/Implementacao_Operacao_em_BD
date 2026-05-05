-- Questão 1 — SELECT com JOIN e ORDER BY
-- Enunciado: Liste o nome do cliente, nome do plano e data de início da matrícula, ordenado pelo nome do cliente.
SELECT
    c.nome AS nome_cliente,
    p.nome_plano AS nome_do_plano,
    m.data_inicio AS data_inicio_matricula
FROM clientes c
LEFT JOIN matriculas m 
    ON c.id = m.cliente_id
LEFT JOIN planos p
    ON p.id = m.plano_id
ORDER BY c.nome;


-- Questão 2: GROUP BY, HAVING e Filtragem
-- Enunciado: Mostre, para cada plano, a quantidade de clientes ativos. Exiba apenas planos com mais de 5 clientes ativos.
SELECT
    p.nome_plano AS nome_plano,
    COUNT(m.id) AS matriculados
FROM matriculas m
LEFT JOIN planos p
    ON p.id = m.plano_id
WHERE m.status = 'ativo'
GROUP by p.nome_plano
HAVING COUNT(m.id) > 5;


-- Questão 3: COALESCE e valores nulos
-- Enunciado: Retorne o nome do cliente e data_fim, substituindo valores NULL por 'Ativo'.
SELECT
    c.nome AS nome_cliente,
    COALESCE(CAST(m.data_fim AS VARCHAR), 'Ativo') AS data_fim
FROM matriculas m
LEFT JOIN clientes c
    ON c.id = m.cliente_id;

-- Questão 4: CREATE VIEW
-- Enunciado: Crie uma VIEW relatorio_planos com nome do plano, total de matrículas e valor médio mensal.
CREATE OR REPLACE VIEW relatorio_planos AS
SELECT
    p.nome_plano AS nome_do_plano,
    COUNT(m.id) AS matriculados,
    AVG(p.valor_mensal) AS valor_medio_mensal
FROM planos p 
LEFT JOIN matriculas m
    ON p.id = m.plano_id
GROUP BY p.nome_plano, p.valor_mensal;

-- Chamando a View como se ela fosse uma tabela
SELECT *
FROM relatorio_planos;


-- Questão 5 — Filtro por data e LIMIT
-- Enunciado: Retorne nome e email dos clientes cadastrados nos últimos 6 meses. Máximo de 10 registros
SELECT
    nome,
    email
FROM clientes
-- CURRENT_DATE → retorna a data atual do sistema.
-- INTERVAL '6 months' → representa um intervalo de tempo.
-- LIMIT n → restringe o resultado a n linhas.
WHERE data_cadastro >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY data_cadastro DESC
LIMIT 10; 