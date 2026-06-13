-- BANCO
DROP DATABASE IF EXISTS ecommerce_uuid;

CREATE DATABASE ecommerce_uuid;

\c ecommerce_uuid;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tabelas
CREATE TABLE cliente(
    id UUID DEFAULT gen_random_uuid(),
    nome VARCHAR(100),
    email VARCHAR(100),

    CONSTRAINT pk_cliente PRIMARY KEY (id)
);
-- Inserts
INSERT INTO cliente(nome, email) VALUES
('Lucas Oliveira', 'lucas.oliveira@email.com'),
('Mariana Costa', 'mariana.costa@email.com'),
('João Silva', 'joao.silva@email.com'),
('Ana Souza', 'ana.souza@email.com'),
('Carlos Pereira', 'carlos.pereira@email.com'),
('Fernanda Lima', 'fernanda.lima@email.com'),
('Ricardo Santos', 'ricardo.santos@email.com'),
('Juliana Rocha', 'juliana.rocha@email.com'),
('Gabriel Alves', 'gabriel.alves@email.com'),
('Patrícia Mendes', 'patricia.mendes@email.com');

CREATE TABLE pedidos(
    id UUID DEFAULT gen_random_uuid(),
    cliente_id UUID,
    data_pedido DATE NOT NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_pedidos PRIMARY KEY (id),
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);
-- Inserts
INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-01', 'Pendente'
FROM cliente
WHERE email = 'lucas.oliveira@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-02', 'Pago'
FROM cliente
WHERE email = 'mariana.costa@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-03', 'Enviado'
FROM cliente
WHERE email = 'joao.silva@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-04', 'Entregue'
FROM cliente
WHERE email = 'ana.souza@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-05', 'Cancelado'
FROM cliente
WHERE email = 'carlos.pereira@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-06', 'Pago'
FROM cliente
WHERE email = 'fernanda.lima@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-07', 'Enviado'
FROM cliente
WHERE email = 'ricardo.santos@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-08', 'Entregue'
FROM cliente
WHERE email = 'juliana.rocha@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-09', 'Pendente'
FROM cliente
WHERE email = 'gabriel.alves@email.com';

INSERT INTO pedidos(cliente_id, data_pedido, status)
SELECT id, '2026-06-10', 'Pago'
FROM cliente
WHERE email = 'patricia.mendes@email.com';

CREATE TABLE produtos(
    id UUID DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL,

    CONSTRAINT pk_produtos PRIMARY KEY (id)
);
-- Inserts
INSERT INTO produtos(nome, preco) VALUES
('Notebook Dell Inspiron', 4599.90),
('Mouse Gamer Redragon', 149.90),
('Teclado Mecânico HyperX', 399.90),
('Monitor LG 24"', 899.90),
('Headset Logitech G435', 349.90),
('SSD Kingston 1TB', 499.90),
('Cadeira Gamer XT Racer', 1299.90),
('Webcam Logitech C920', 429.90),
('Smartphone Samsung A55', 2399.90),
('Tablet Lenovo M10', 1199.90);

CREATE TABLE itens_pedido(
    pedido_id UUID,
    produto_id UUID,
    quantidade INTEGER NOT NULL,

    CONSTRAINT pk_itens_pedido PRIMARY KEY (pedido_id, produto_id),
    CONSTRAINT fk_itens_pedido_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    CONSTRAINT fk_itens_pedido_produto FOREIGN KEY (produto_id) REFERENCES produtos(id)
);
-- Inserts
INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Notebook Dell Inspiron'),
    1;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 1 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Mouse Gamer Redragon'),
    2;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 2 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Teclado Mecânico HyperX'),
    1;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 3 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Monitor LG 24"'),
    1;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 4 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Headset Logitech G435'),
    1;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 5 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'SSD Kingston 1TB'),
    2;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 6 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Cadeira Gamer XT Racer'),
    1;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 7 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Webcam Logitech C920'),
    3;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 8 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Smartphone Samsung A55'),
    1;

INSERT INTO itens_pedido(pedido_id, produto_id, quantidade)
SELECT 
    (SELECT id FROM pedidos ORDER BY data_pedido OFFSET 9 LIMIT 1),
    (SELECT id FROM produtos WHERE nome = 'Tablet Lenovo M10'),
    2;