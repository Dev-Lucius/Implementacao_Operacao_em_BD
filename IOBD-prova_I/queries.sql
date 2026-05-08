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
)
-- chamando a CTE ranking_cliente
SELECT * 
FROM ranking_clientes
ORDER BY SUM(pr.preco * ip.quantidade) DESC;


-- 3. Produtos Acima da Média
SELECT
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
GROUP BY pd.id, pd.status
ORDER BY SUM(pr.preco * ip.quantidade) ASC;


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
GROUP BY pd.id, pd.status
HAVING COUNT(pr.id) > 1
ORDER BY COUNT(pr.id) ASC;
