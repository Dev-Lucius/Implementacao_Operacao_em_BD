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
('Carlos Souza', 'carlos@email.com', '45678912300', '2001-01-15', '11223344', 'Bloco B', '300');


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

-- ===================
-- Exercícios da Lista
-- ===================
-- 1. Liste matrícula e nome do aluno
SELECT 
    usuario.nome AS user,
    aluno.matricula
FROM usuario 
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id;

-- 2. Mesmo exercício usando USING. -> (considerando ajuste estrutural para chave compatível)
-- Para isso, é necessário renomear aluno.usuario_id para id (não recomendado semanticamente), poderia usar:
ALTER TABLE aluno 
RENAME COLUMN usuario_id TO id;
-- ==================
-- Em seguida usamos:
-- ==================
SELECT 
    usuario.nome AS user,
    aluno.matricula
FROM usuario
INNER JOIN aluno
USING (id);

-- 3.  Liste alunos e curso.
SELECT
    usuario.nome AS user,
    aluno.matricula,
    curso.nome AS nome_curso
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN curso
    ON curso.id = aluno.curso_id;

-- 4. Liste requerimentos com tipo (INNER JOIN).
SELECT
    tipo_requerimento.descricao,
    requerimento.status
FROM tipo_requerimento
INNER JOIN requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;

-- 5. LEFT JOIN -> alunos e requerimentos.
SELECT 
    usuario.nome,
    requerimento.data_hora_abertura,
    tipo_requerimento.descricao
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;

-- 6. Liste alunos sem requerimento -> (LEFT + IS NULL).
SELECT 
    usuario.nome,
    requerimento.data_hora_abertura,
    tipo_requerimento.descricao
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
WHERE requerimento.aluno_matricula IS NULL;

-- 7. RIGHT JOIN -> requerimentos e anexos
-- Case Funciona como um IF dentro do SQL
/*
    CASE
        WHEN anexo.descricao IS NULL THEN 'sem descricao'
        ELSE anexo.descricao
    END

    --//--

    if descricao == NULL:
        return "sem descricao"
    else:
        return descricao
*/
SELECT requerimento_id,
    CASE
        WHEN anexo.descricao is NULL THEN 'sem descricao'
    ELSE anexo.descricao 
END as descricao -- Aqui Definimos o nome da Coluna do Resultado
FROM 
    requerimento LEFT JOIN anexo on (requerimento.id = anexo.requerimento_id);

-- Versão alternativa com COALESCE()
-- COALESCE(valor, substituto)
-- ==> se valor for NULL usa-se substituto
SELECT
    anexo.requerimento_id,
    COALESCE(anexo.descricao, 'sem descricao') AS descricao
FROM requerimento
LEFT JOIN anexo
    ON requerimento_id = anexo.requerimento_id; 

-- 8. FULL JOIN aluno e requerimento.
SELECT
    aluno.matricula,
    usuario.nome,
    usuario.cpf
FROM aluno
INNER JOIN usuario
    ON usuario.id = aluno.usuario_id
FULL JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
     
-- 9. Tipos nunca solicitados (LEFT).
SELECT * 
    FROM tipo_requerimento
WHERE id NOT IN (
    -- Criação de um subconsulta que retorna todas FK de requerimento
    SELECT tipo_requerimento_id FROM requerimento
);

-- Versão com Join
SELECT 
    tipo_requerimento.descricao
FROM tipo_requerimento
LEFT JOIN requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
WHERE requerimento.tipo_requerimento_id IS NULL

-- 10. Requerimentos com nome do aluno e tipo.
SELECT
    usuario.nome,
    usuario.cpf,
    usuario.email,
    requerimento.data_hora_abertura,
    tipo_requerimento.descricao
FROM usuario 
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno.matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id;

-- 11. Liste requerimentos deferidos com nome do aluno (INNER JOIN + WHERE).
SELECT
    aluno.matricula,
    usuario.nome,
    usuario.cpf,
    tipo_requerimento.descricao,
FROM usuario 
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
INNER JOIN requerimento 
    ON aluno.matricula = requerimento.aluno_matricula
INNER JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
WHERE requerimento.status = 'DEFERIDO';

-- Versão Com View
-- Pense em VIEW como uma consulta salva no Banco
-- Ela funciona como uma tabela visual
-- Depois de Criada, é possível usar...
-- SELECT * FROM qtde_requerimento_por_tipo;
-- Porém, o banco não vai armazenar os dados da VIEW, apenas a sua Query
-- Ou seja ===> sempre que a view for consultada, o banco executa essa consulta novamente.
CREATE VIEW AS qtde_requerimento_por_tipo AS
SELECT 
    tipo_requerimento.id,
    tipo_requerimento.descricao,
    COUNT(requerimento.tipo_requerimento_id)
FROM requerimento
-- Com o INNER JOIN estamos relacionando: requerimento.tipo_requerimento_id --> tipo_requerimento.id
-- Isso significa que ... > Cada requerimento pertence a um tipo
INNER JOIN tipo_requerimento
    ON (requerimento.tipo_requerimento_id = tipo_requerimento.id)
-- O GROUP BY agrupa os registros para que o COUNT funcione
GROUP BY 
    tipo_requerimento.id,
    tipo_requerimento.descricao,
    requerimento.tipo_requerimento_id;

-- 13. Liste alunos e quantidade de requerimentos (LEFT JOIN + GROUP BY).
SELECT
    usuario.nome,
    usuario.cpf,
    aluno.matricula,
    COUNT(requerimento.id) AS quantidade_requerimento
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno_matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
GROUP BY
    usuario.nome,
    usuario.cpf,
    aluno.matricula;

-- 14. Liste apenas alunos com mais de 1 requerimento (HAVING).
SELECT
    usuario.nome,
    usuario.cpf,
    aluno.matricula,
    COUNT(requerimento.id) AS quantidade_requerimento
FROM usuario
INNER JOIN aluno
    ON usuario.id = aluno.usuario_id
LEFT JOIN requerimento
    ON aluno_matricula = requerimento.aluno_matricula
LEFT JOIN tipo_requerimento
    ON tipo_requerimento.id = requerimento.tipo_requerimento_id
GROUP BY
    usuario.nome,
    usuario.cpf,
    aluno.matricula
HAVING COUNT(requerimento.id) > 1;

-- 15. 
SELECT requerimento.id, 
count(requerimento_id) as qtde 
FROM requerimento 
left join anexo 
    on (requerimento.id = anexo.requerimento_id) 
group by 
    requerimento.id, requerimento_id;

-- x. Quantidade de requerimentos por status.
SELECT
    status,
    COUNT(status) AS qtde
FROM requerimento
GROUP BY
    status;

-- x. Tipos com mais de 1 ocorrência.
SELECT
    COUNT(status) AS qtd,
    status
FROM requerimento 
GROUP BY
    status
HAVING COUNT(status) >= 1;

-- x. Requerimentos por aluno.
SELECT
    aluno.matricula,
    COUNT(requerimento.aluno_matricula)
FROM requerimento
RIGHT JOIN aluno
    ON aluno.matricula = requerimento.aluno_matricula
GROUP BY
    aluno.matricula;

-- x. Ano de abertura + contagem.
-- (quantos requerimentos por ano)
SELECT
    EXTRACT(YEAR FROM data_hora_abertura) AS ano,
    EXTRACT(MONTH FROM data_hora_abertura) AS mes,
    COUNT(*) AS quantidade
FROM requerimento
GROUP BY 
    ano,
    mes;

-- x. Mês atual.
SELECT
    EXTRACT(YEAR FROM data_hora_abertura) AS ano,
    EXTRACT(MONTH FROM data_hora_abertura) AS mes,
    CASE
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 1 THEN 'Janeiro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 2 THEN 'Fevereiro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 3 THEN 'Março'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 4 THEN 'Abril'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 5 THEN 'Maio'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 6 THEN 'Junho'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 7 THEN 'Julho'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 8 THEN 'Agosto'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 9 THEN 'Setembro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 10 THEN 'Outubro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 11 THEN 'Novembro'
        WHEN EXTRACT(YEAR FROM data_hora_abertura) = 12 THEN 'Dezembro'
    COUNT(*) AS quantidade
FROM requerimento
GROUP BY 
    ano,
    mes;

-- x. Média duração cursos.
SELECT 
    AVG(duracao)::float 
WHERE duracao > 
(
    SELECT 
        CAST(AVG(duracao) as float) AS media_horas_duracao 
    FROM curso
)

-- x. Cursos acima da média.
SELECT * 
FROM curso
WHERE duracao > 
(
    SELECT 
        CAST(AVG(duracao) as float) AS media_horas_duracao 
    FROM curso
)







