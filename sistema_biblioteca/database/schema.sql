DROP DATABASE IF EXISTS sistema_biblioteca;

CREATE DATABASE sistema_biblioteca;

\c sistema_biblioteca;
psql -h localhost -U postgres -- abrindo o psql via terminal no localhost

/* 
   ===============
   BANCO DE DADOS
   ===============
*/ 
CREATE TABLE livro(
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(30) NOT NULL,
    autor TEXT NOT NULL
);

CREATE TABLE usuario(
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL
);

CREATE TABLE exemplar(
    id SERIAL PRIMARY KEY,
    livro_id INTEGER REFERENCES livro(id),
    codigo INTEGER NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE 
);

CREATE TABLE emprestimo(
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(id),
    exemplar_id INTEGER REFERENCES exemplar(id),
    data_emprestimo DATE,
    data_devolucao DATE
);

/* 
   ================
   Inserts no Banco
   ================
*/ 
INSERT INTO livro (titulo, autor) VALUES
('Dom Casmurro', 'Machado de Assis'), -- id = 1
('Memorias Postumas', 'Machado de Assis'), -- id = 2
('O Hobbit', 'J.R.R. Tolkien'), -- id = 3
('1984', 'George Orwell'), -- id = 4
('Clean Code', 'Robert Martin'), -- id = 5
('Senhor dos Aneis', 'J.R.R. Tolkien'), -- id = 6
('Capitaes da Areia', 'Jorge Amado'), -- id = 7
('Grande Sertao', 'Guimaraes Rosa'), -- id = 8
('O Alquimista', 'Paulo Coelho'), -- id = 9
('Harry Potter', 'J.K. Rowling'), -- id = 10
('Agile Code', 'Robert Martin'); -- id = 11
 
INSERT INTO usuario (nome) VALUES
('Lucas Oliveira'),
('Maria Silva'),
('Joao Pereira'),
('Ana Souza'),
('Carlos Lima'),
('Fernanda Costa'),
('Ricardo Alves'),
('Juliana Martins'),
('Bruno Rocha'),
('Patricia Gomes');

INSERT INTO exemplar (livro_id, codigo, disponivel) VALUES
(1, 1001, true),
(1, 1002, true),
(2, 2001, true),
(3, 3001, true),
(3, 3002, true),
(4, 4001, true),
(5, 5001, true),
(6, 6001, true),
(7, 7001, true),
(8, 8001, true),
(9, 9001, true),
(10, 1001, true),
(11, 1101, false);


INSERT INTO emprestimo (usuario_id, exemplar_id, data_emprestimo, data_devolucao) VALUES
(1, 1, '2026-03-01', '2026-03-10'),
(1, 10, '2026-03-01', '2026-03-10'),
(2, 3, '2026-03-02', '2026-03-12'),
(3, 4, '2026-03-05', '2026-03-15'),
(4, 2, '2026-03-07', '2026-03-17'),
(5, 5, '2026-03-08', '2026-03-18'),
(6, 6, '2026-03-10', '2026-03-20'),
(7, 7, '2026-03-12', '2026-03-22'),
(8, 8, '2026-03-15', '2026-03-25'),
(9, 9, '2026-03-18', '2026-03-28'),
(10, 10, '2026-03-20', '2026-03-30');


