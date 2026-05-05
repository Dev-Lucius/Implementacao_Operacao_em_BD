DROP DATABASE IF EXISTS sistema_gerenciamento_academia;

CREATE DATABASE sistema_gerenciamento_academia;

\c sistema_gerenciamento_academia;

CREATE TABLE clientes(
    id serial PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    data_cadastro DATE NOT NULL
);

CREATE TABLE planos(
    id serial PRIMARY KEY,
    nome_plano VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    valor_mensal NUMERIC(10, 2) 
);

CREATE TABLE matriculas(
    id serial PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    plano_id INTEGER REFERENCES planos(id),
    data_inicio DATE NOT NULL,
    data_fim DATE, -- NULL -> Matrícula ainda ativa
    status TEXT 
);

INSERT INTO clientes(nome, email, data_cadastro) VALUES
('Ana Silva',      'ana@email.com',     '2024-11-01'),
('Bruno Costa',    'bruno@email.com',   '2024-12-15'),
('Carla Souza',    'carla@email.com',   '2025-01-10'),
('Diego Martins',  'diego@email.com',   '2025-02-20'),
('Eva Lima',       'eva@email.com',     '2025-03-05'),
('Felipe Rocha',   'felipe@email.com',  '2025-04-01'),
('Gabi Nunes',     'gabi@email.com',    '2025-04-10'),
('Hugo Ferreira',  'hugo@email.com',    '2025-04-18'),
('Iris Campos',    'iris@email.com',    '2025-11-30'),
('João Alves',     'joao@email.com',    '2026-02-01');

INSERT INTO planos(nome_plano, tipo, valor_mensal) VALUES
('Plano Basic',    'Mensal',    99.90),
('Plano Premium',  'Mensal',   159.90),
('Plano Anual',    'Anual',     89.90),
('Plano Família',  'Mensal',   199.90);

INSERT INTO matriculas(cliente_id, plano_id, data_inicio, data_fim, status) VALUES
(1,  2, '2025-01-01', NULL,         'ativo'),
(2,  1, '2025-01-15', NULL,         'ativo'),
(3,  1, '2025-02-01', NULL,         'ativo'),
(4,  2, '2025-02-10', NULL,         'ativo'),
(5,  1, '2025-03-01', NULL,         'ativo'),
(6,  1, '2025-03-15', NULL,         'ativo'),
(7,  2, '2025-04-01', NULL,         'ativo'),
(8,  3, '2025-04-10', '2025-10-10', 'inativo'),
(9,  1, '2025-04-18', NULL,         'ativo'),
(10, 2, '2026-02-01', NULL,         'ativo'),
(1,  3, '2024-01-01', '2024-12-31', 'inativo'),
(2,  2, '2026-03-01', NULL,         'ativo');

