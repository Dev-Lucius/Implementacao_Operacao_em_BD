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
