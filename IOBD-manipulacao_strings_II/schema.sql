-- =========================
-- Banco de Dados!!
-- =========================
DROP DATABASE IF EXISTS sistema_requerimento;

CREATE DATABASE sistema_requerimento;

\c sistema_requerimento;
psql -h localhost -U postgres -- Abrir o PSQL no Terminal via LocalHost

CREATE TABLE curso(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    site VARCHAR(200) NOT NULL,
    turno VARCHAR(20) CHECK (turno IN ('noturno', 'diurno', 'vespertino')),
    duracao INTEGER CHECK (duracao > 0) -- Duração em Horas
);

CREATE TABLE usuario(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE,
    cpf CHAR(11) UNIQUE,
    data_nascimento DATE,
    cep CHAR(8),
    complemento TEXT,
    numero VARCHAR(10)
);

CREATE TABLE tipo_requerimento(
    id SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL
);

CREATE TABLE aluno(
    matricula CHAR(10) PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(id),
    curso_id INTEGER REFERENCES curso(id)
);

CREATE TABLE requerimento(
    id SERIAL PRIMARY KEY,
    aluno_matricula CHAR(10) REFERENCES aluno(matricula),
    data_hora_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT CHECK (status IN ('em análise', 'indeferido', 'deferido')) DEFAULT 'em análise',
    tipo_requerimento_id INTEGER REFERENCES tipo_requerimento(id)
);

CREATE TABLE anexo(
    id SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    arquivo BYTEA,
    requerimento_id INTEGER REFERENCES requerimento(id)
);

-- ========================
-- INSERÇÃO NAS TABELAS
-- =========================

-- =========================
-- CURSOS
-- =========================
INSERT INTO curso (nome, site, turno, duracao) VALUES
('Sistemas de Informação', 'https://si.exemplo.edu.br', 'noturno', 3000),
('Administração', 'https://adm.exemplo.edu.br', 'diurno', 2800),
('Direito', 'https://dir.exemplo.edu.br', 'vespertino', 4000);


-- =========================
-- USUÁRIOS
-- =========================
INSERT INTO usuario (nome, email, cpf, data_nascimento, cep, complemento, numero) VALUES
('João Silva', 'joao@email.com', '12345678901', '2000-05-10', '12345678', 'Apto 101', '100'),
('Maria Oliveira', 'maria@email.com', '98765432100', '1999-08-22', '87654321', 'Casa', '200'),
('Carlos Souza', 'carlos@email.com', '45678912300', '2001-01-15', '11223344', 'Bloco B', '300'),
('Teste', 'pedro@email.com', '09876543210', '2004-05-15', '44332211', 'Apartamento', '250');


-- =========================
-- TIPOS DE REQUERIMENTO
-- =========================
INSERT INTO tipo_requerimento (descricao) VALUES
('Declaração de Matrícula'),
('Aproveitamento de Disciplina'),
('Trancamento de Curso');


-- =========================
-- ALUNOS
-- =========================
INSERT INTO aluno (matricula, usuario_id, curso_id) VALUES
('2024000001', 1, 1),
('2024000002', 2, 2),
('2024000003', 3, 1);


-- =========================
-- REQUERIMENTOS
-- =========================
INSERT INTO requerimento (aluno_matricula, status, tipo_requerimento_id) VALUES
('2024000001', 'em análise', 1),
('2024000002', 'deferido', 2),
('2024000003', 'indeferido', 3);


-- =========================
-- ANEXOS
-- =========================
INSERT INTO anexo (descricao, arquivo, requerimento_id) VALUES
('Documento RG', NULL, 1),
('Histórico Escolar', NULL, 2),
('Comprovante de Pagamento', NULL, 3);


-- =========================
-- Atualizações nas Tabelas
-- =========================
ALTER TABLE requerimento 
ADD COLUMN data_hora_fechamento TIMESTAMP;

UPDATE requerimento
SET data_hora_fechamento = data_hora_abertura + INTERVAL '3 days'
WHERE id = 1;

UPDATE requerimento
SET data_hora_fechamento = data_hora_abertura + INTERVAL '12 days'
WHERE id = 2;

UPDATE requerimento
SET data_hora_fechamento = data_hora_abertura + INTERVAL '27 days'
WHERE id = 3;

-- =========================
-- Consultas
-- =========================

-- Listar todos os requerimentos com nome do aluno
SELECT 
    usuario.nome AS aluno_nome,
    requerimento.id AS requerimento_id,
    requerimento.status,
    requerimento.data_hora_abertura
FROM requerimento
INNER JOIN aluno 
    ON aluno.matricula = requerimento.aluno_matricula
INNER JOIN usuario 
    ON usuario.id = aluno.usuario_id;

-- Listar requerimentos com descrição do tipo
SELECT 
    requerimento.id AS requerimento_codigo,
    tipo_requerimento.descricao AS descricao_requerimento
FROM requerimento
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;


-- Listar requerimentos com nome do aluno e tipo
SELECT
    usuario.nome,
    tipo_requerimento.descricao
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
INNER JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;