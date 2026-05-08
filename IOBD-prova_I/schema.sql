-- Banco
DROP DATABASE IF EXISTS sistema_ecommerce;

CREATE DATABASE sistema_ecommerce;

\c sistema_ecommerce;

CREATE TABLE cliente(
    id serial PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE pedido(
    id serial PRIMARY KEY,
    cliente_id INTEGER REFERENCES cliente(id),
    data_pedido DATE,
    status TEXT
);

CREATE TABLE produto(
    id serial PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    preco NUMERIC(10,2) NOT NULL
);

CREATE TABLE item_pedido(
    pedido_id INTEGER REFERENCES pedido(id),
    produto_id INTEGER REFERENCES produto(id),
    quantidade INTEGER 
);

-- INSERTS
INSERT INTO cliente(nome) VALUES
('Lucas Oliveira'), -- id cliente = 1 
('Maria Rodrigues'), -- id cliente = 2
('Pedro Padilha'), -- id cliente = 3
('Amanda Alves'); -- id cliente = 4

INSERT INTO pedido(cliente_id, data_pedido, status) VALUES
(1, '2024-11-01', 'Em Análise'), -- id pedido = 1
(2, '2024-12-02', 'Aguardando Pagamento'), -- id pedido = 2
(3, '2025-01-03', 'Em Rota de Entrega'); -- id pedido = 3

INSERT INTO produto (nome, preco) VALUES
('Mouse Gamer', 69.90), -- id produto = 1
('Teclado Gamer', 89.99), -- id produto = 2
('Monitor 144Hz', 249.99), -- id produto = 3
('Mousepad Gamer 30cm', 56.79); -- id produto = 4

INSERT INTO item_pedido(pedido_id, produto_id, quantidade) VALUES
(1, 1, 1), -- LUCAS comprou UM MOUSE GAMER (TOTAL R$ 69.99)
(2, 4, 2), -- MARIA comprou DOIS MOUSEPAD GAMER (TOTAL R$ 113,58)
(3, 2, 5); -- PEDRO comprou CINCO TECLADOS GAMER (TOTAL R$ 449,95)


-- Queries (Exercícios)
-- 1. Clientes sem Compras
SELECT
    c.nome AS cliente_nome,
    p.status AS status_pedido
FROM cliente c
LEFT JOIN pedido p
    ON c.id = p.cliente_id
WHERE p.id IS NULL;


-- 2. Ranking de Clientes (CTE)
WITH ranking_clientes AS (
    SELECT 
        c.nome AS nome_cliente,
        pd.status AS pedido_status,
        SUM(pr.preco * ip.quantidade) AS total_gasto,
        COUNT(pd.id) AS qtd_pedidos
    FROM cliente c
    LEFT JOIN pedido pd ON c.id = pd.cliente_id
    LEFT JOIN item_pedido ip ON pd.id = ip.pedido_id
    LEFT JOIN produto pr ON pr.id = ip.produto_id
    WHERE pd.cliente_id IS NOT NULL
    GROUP BY nome_cliente, pedido_status
    HAVING SUM(pr.preco * ip.quantidade) IS NOT NULL AND COUNT(pd.id) >= 1
    ORDER BY SUM(pr.preco * ip.quantidade) DESC
)
-- chamando a CTE ranking_cliente
SELECT * 
FROM ranking_clientes;


-- 3. Produtos Acima da Média
SEDROP DATABASE IF EXISTS sistema_ecommerce;

CREATE DATABASE sistema_ecommerce;

\c sistema_ecommerce;

CREATE TABLE cliente(
    id serial PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE pedido(
    id serial PRIMARY KEY,
    cliente_id INTEGER REFERENCES cliente(id),
    data_pedido DATE,
    status TEXT
);

CREATE TABLE produto(
    id serial PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    preco NUMERIC(10,2) NOT NULL
);

CREATE TABLE item_pedido(
    pedido_id INTEGER REFERENCES pedido(id),
    produto_id INTEGER REFERENCES produto(id),
    quantidade INTEGER 
);

-- INSERTS

INSERT INTO cliente(nome) VALUES
('Lucas Oliveira'), -- id cliente = 1 
('Maria Rodrigues'), -- id cliente = 2
('Pedro Padilha'), -- id cliente = 3
('Amanda Alves'); -- id cliente = 4

INSERT INTO pedido(cliente_id, data_pedido, status) VALUES
(1, '2024-11-01', 'Em Análise'), -- id pedido = 1
(2, '2024-12-02', 'Aguardando Pagamento'), -- id pedido = 2
(3, '2025-01-03', 'Em Rota de Entrega'); -- id pedido = 3

INSERT INTO produto (nome, preco) VALUES
('Mouse Gamer', 69.90), -- id produto = 1
('Teclado Gamer', 89.99), -- id produto = 2
('Monitor 144Hz', 249.99), -- id produto = 3
('Mousepad Gamer 30cm', 56.79); -- id produto = 4

INSERT INTO item_pedido(pedido_id, produto_id, quantidade) VALUES
(1, 1, 1), -- LUCAS comprou UM MOUSE GAMER (TOTAL R$ 69.99)
(2, 4, 2), -- MARIA comprou DOIS MOUSEPAD GAMER (TOTAL R$ 113,58)
(3, 2, 5); -- PEDRO comprou CINCO TECLADOS GAMER (TOTAL R$ 449,95)LECT 
    p.nome AS produto_nome,
    p.preco AS produto_preco
FROM produto p 
WHERE p.preco > (
    SELECT
        -- SUM(p.preco) AS soma_produtos, 
        AVG(p.preco) AS media_precos_produtos
    FROM produto p
);


-- 4. Pedidos com Valor total
SELECT 
    pd.id AS identificador_pedido,
    pd.status AS status_pedido,
    pr.preco AS preco_produto,
    ip.quantidade AS qtd_itens,
    SUM(pr.preco * ip.quantidade) AS total_gasto
FROM pedido pd 
LEFT JOIN item_pedido ip 
    ON pd.id = ip.pedido_id
LEFT JOIN produto pr
    ON pr.id = ip.produto_id
GROUP BY pd.id, pr.preco, ip.quantidade
ORDER BY pr.preco ASC;


-- 5. Pedidos com mais de um Produto
SELECT 
    pd.id AS identificador_pedido,
    pd.status AS status_pedido,
    ip.quantidade AS qtd_itens,
    COUNT(pr.id) AS qtd_produtos
FROM pedido pd
LEFT JOIN item_pedido ip 
    ON pd.id = ip.pedido_id
LEFT JOIN produto pr
    ON pr.id = ip.produto_id
GROUP BY pd.id, pd.status, ip.quantidade
ORDER BY COUNT(pr.id) ASC;