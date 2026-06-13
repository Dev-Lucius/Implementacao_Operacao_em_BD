-- Com Base no Schema Resolva as Questões Abaixo

/*
1) Clientes sem Compras (EXCEPT) — 1,0 ponto
- Liste os clientes que nunca realizaram pedidos.

Dicas
    Utilize operação de conjunto.
    Evite JOINs se possível.
*/
SELECT
    c.nome AS cliente_nome,
    p.status AS status_pedido
FROM cliente c
LEFT JOIN pedidos p
    ON c.id = p.cliente_id
WHERE p.id = NULL;

/*
2) Ranking de Clientes (CTE) — 1,5 pontos

Liste:
    nome do cliente
    total gasto
    quantidade de pedidos

- Ordene do maior para o menor gasto.

Dicas
    Utilize CTE.
    Será necessário combinar múltiplas tabelas.
*/
WITH ranking_clientes AS (
    SELECT 
        c.nome AS nome_cliente,
        p.status AS pedido_status, 
        SUM(pr.preco * ip.quantidade) AS total_gasto,
        COUNT(p.id) AS quantidade_de_pedidos
    FROM cliente c
    LEFT JOIN pedidos p  
        ON c.id = p.cliente_id
    LEFT JOIN itens_pedido ip
        ON p.id = ip.pedido_id  
    LEFT JOIN produtos pr  
        ON pr.id = ip.produto_id
    WHERE p.cliente_id IS NOT NULL 
    GROUP BY c.nome, p.status
    HAVING SUM(pr.preco * ip.quantidade) IS NOT NULL AND COUNT(p.id) >= 1 
)
-- Chamando a CTE correta
SELECT *
FROM ranking_clientes
ORDER BY total_gasto DESC; 

/*
3) Produtos Acima da Média — 1,0 ponto

- Liste os produtos cujo preço é superior à média de preços.
*/
SELECT
    p.nome AS produto_nome,
    p.preco AS produto_preco_acima_media
FROM produtos p
WHERE p.preco > (
    SELECT
        AVG(p.preco) AS media_precos_produtos
    FROM produtos p
);

/*
4) Pedidos com Valor Total — 1,0 ponto

Liste:
    UUID do pedido
    valor total
*/
SELECT
    pd.id AS identificador_pedido,
    pd.status AS pedido_status,
    pr.preco AS preco_produto,
    ip.quantidade AS quantidade_itens,
    SUM(ip.quantidade * pr.preco) AS valor_total
FROM pedidos pd
LEFT JOIN itens_pedido ip
    ON pd.id = ip.pedido_id
LEFT JOIN produtos pr
    ON pr.id = ip.produto_id
GROUP BY pd.id, pd.status, pr.preco, ip.quantidade
ORDER BY SUM(ip.quantidade * pr.preco) ASC;

/*
5) Pedidos com Mais de um Produto — 0,5 ponto
- Liste os pedidos que possuem mais de um produto diferente.
*/
SELECT
    pr.nome AS nome_produto,
    pr.preco AS produto_preco,
    pd.status AS status_pedido,
    pd.data_pedido AS data,
    ip.quantidade AS quantidade_itens
FROM pedidos pd
LEFT JOIN itens_pedido ip
    ON pd.id = ip.pedido_id
LEFT JOIN produtos pr
    ON pr.id = ip.produto_id
GROUP BY pr.nome, pr.preco, pd.status, pd.data_pedido, ip.quantidade
ORDER BY ip.quantidade ASC;
