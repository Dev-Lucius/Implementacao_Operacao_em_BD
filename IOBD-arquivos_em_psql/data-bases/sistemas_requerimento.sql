-- =============================================================
-- SISTEMA DE REQUERIMENTOS
-- Banco: sistema_requerimento_aula
-- =============================================================


-- =============================================================
-- 1. CRIAÇÃO DO BANCO E SCHEMAS
-- =============================================================

DROP DATABASE IF EXISTS sistema_requerimento_aula;

CREATE DATABASE sistema_requerimento_aula;

\c sistema_requerimento_aula;


-- =============================================================
-- SCHEMAS
-- =============================================================

CREATE SCHEMA esquema_requerimento;

SET search_path TO public, esquema_requerimento;


-- =============================================================
-- 2. TABELAS DO SCHEMA PUBLIC
-- =============================================================


-- =============================================================
-- 2.1 CURSO
-- =============================================================

CREATE TABLE public.curso (
    id          serial PRIMARY KEY,
    nome        varchar(200) NOT NULL,
    site        varchar(200),

    turno       varchar(20)
        CHECK (turno IN ('NOTURNO', 'DIURNO', 'VESPERTINO')),

    duracao     integer
        CHECK (duracao > 0),

    ativo       boolean DEFAULT true
);


INSERT INTO public.curso
(nome, site, turno, duracao)
VALUES
(
    'TECNOLOGIA EM ANÁLISE E DESENVOLVIMENTO DE SISTEMAS',
    'http://tads.riogrande.ifrs.edu.br',
    'NOTURNO',
    2147
),
(
    'ENGENHARIA MECÂNICA',
    NULL,
    'NOTURNO',
    2000
),
(
    'ARQUITETURA',
    NULL,
    'VESPERTINO',
    2500
);



-- =============================================================
-- 2.2 USUARIO
-- =============================================================

CREATE TABLE public.usuario (
    id                  serial PRIMARY KEY,

    nome                varchar(200) NOT NULL,

    email               varchar(200) UNIQUE,

    cpf                 char(11) UNIQUE,

    data_nascimento     date,

    cep                 char(8),

    rua                 text,

    complemento         text,

    nro                 varchar(10),

    ativo               boolean DEFAULT true
);


INSERT INTO public.usuario
(nome, email, cpf)
VALUES
(
    'IGOR AVILA PEREIRA',
    'igor.pereira@riogrande.ifrs.edu.br',
    '11111111111'
),
(
    'RAFAEL BETITO',
    'rafael.betito@riogrande.ifrs.edu.br',
    '22222222222'
),
(
    'MÁRCIO JOSUÉ RAMOS TORRES',
    'marcio.torres@riogrande.ifrs.edu.br',
    '33333333333'
);



-- =============================================================
-- 2.3 ALUNO
-- =============================================================

CREATE TABLE public.aluno (
    matricula      char(10) PRIMARY KEY,

    usuario_id     integer
        REFERENCES public.usuario(id),

    curso_id       integer
        REFERENCES public.curso(id),

    status         varchar(20)
        CHECK (
            status IN (
                'CURSANDO',
                'ABANDONO',
                'TRANCADO',
                'FORMADO'
            )
        )
        DEFAULT 'CURSANDO'
);


INSERT INTO public.aluno
(matricula, usuario_id, curso_id)
VALUES
('1231231231', 1, 1),
('1231231232', 2, 1),
('1231231131', 3, 1),
('1231231235', 1, 2),
('1231231230', 1, 2);


UPDATE public.aluno
SET status = 'FORMADO'
WHERE matricula = '1231231231';



-- =============================================================
-- 3. SCHEMA ESQUEMA_REQUERIMENTO
-- =============================================================


-- =============================================================
-- 3.1 TIPO_REQUERIMENTO
-- =============================================================

CREATE TABLE esquema_requerimento.tipo_requerimento (
    id              serial PRIMARY KEY,

    descricao       text NOT NULL
);


INSERT INTO esquema_requerimento.tipo_requerimento
(descricao)
VALUES
('Abreviação de Curso Superior ou Antecipação de Colação'),
('Ajuste de Matrícula'),
('Aproveitamento de Estudos'),
('Atestado de Frequência'),
('Certificação de Conhecimentos'),
('Certificação ENEM ou ENCCEJA'),
('Cancelamento de Matrícula'),
('Histórico'),
('Justificativa ou Abono de Faltas e Solicitação de Segunda Chamada'),
('Registro de Nome Social'),
('Quebra de Pré-Requisito'),
('Reingresso'),
('Rematrícula'),
('Revisão de Prova ou Exame'),
('Trancamento de Disciplina'),
('Trancamento de Matrícula'),
('Troca de Turma'),
('Validação de Atividades Complementares');



-- =============================================================
-- 3.2 REQUERIMENTO
-- =============================================================

CREATE TABLE esquema_requerimento.requerimento (
    id                          serial PRIMARY KEY,

    aluno_matricula             char(10)
        REFERENCES public.aluno(matricula),

    tipo_requerimento_id        integer
        REFERENCES esquema_requerimento.tipo_requerimento(id),

    data_hora_abertura          timestamp
        DEFAULT current_timestamp,

    data_hora_encerramento      timestamp,

    status                      varchar(20)
        CHECK (
            status IN (
                'EM ANÁLISE',
                'INDEFERIDO',
                'DEFERIDO'
            )
        )
        DEFAULT 'EM ANÁLISE',

    observacao                  text,

    foto                        bytea,

    material                    bytea,

    material_tipo               varchar(100)
);


-- Requerimentos atuais
INSERT INTO esquema_requerimento.requerimento
(aluno_matricula, tipo_requerimento_id)
VALUES
('1231231231', 12),
('1231231231', 18),
('1231231231', 1),
('1231231232', 1),
('1231231131', 8),
('1231231131', 8);


-- Requerimentos de 1 ano atrás
INSERT INTO esquema_requerimento.requerimento
(aluno_matricula, tipo_requerimento_id, data_hora_abertura)
VALUES
(
    '1231231231',
    8,
    current_timestamp - interval '1 year'
),
(
    '1231231232',
    8,
    current_timestamp - interval '1 year'
);


-- Requerimento de 2 anos atrás
INSERT INTO esquema_requerimento.requerimento
(aluno_matricula, tipo_requerimento_id, data_hora_abertura)
VALUES
(
    '1231231131',
    8,
    current_timestamp - interval '2 years'
);


-- Requerimento de 31 dias atrás
INSERT INTO esquema_requerimento.requerimento
(aluno_matricula, tipo_requerimento_id, data_hora_abertura)
VALUES
(
    '1231231131',
    8,
    current_timestamp - interval '31 days'
);



-- =============================================================
-- 3.3 ANEXO
-- =============================================================

CREATE TABLE esquema_requerimento.anexo (
    id                  serial PRIMARY KEY,

    descricao           text NOT NULL,

    arquivo             bytea,

    requerimento_id     integer
        REFERENCES esquema_requerimento.requerimento(id)
);


INSERT INTO esquema_requerimento.anexo
(descricao, arquivo, requerimento_id)
VALUES
(
    'HISTÓRICO',
    NULL,
    1
);

-- ALTER TABLE
ALTER TABLE esquema_requerimento.requerimento 
ADD COLUMN anexo BYTEA;