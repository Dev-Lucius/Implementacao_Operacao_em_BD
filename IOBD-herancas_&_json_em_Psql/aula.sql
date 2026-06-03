--HOJE:
--- UUID -> ok
--- HERANÇA DE TABELAS (PostgreSQL) -> ok
--- JSON -> abordando
--==========================
--1) uuid => 
--SET search_path TO public, esquema_requerimento;
--
--CREATE TABLE log (
--    id serial primary key,
--    valor_uuid UUID DEFAULT uuid_generate_v4() unique,
--    comentario text,
--    data_hora_criacao timestamp default current_timestamp
--);
--
--BEGIN;
--    INSERT INTO log(comentario) values ('testando1');
--    INSERT INTO log(comentario) values ('testando2');
--    INSERT INTO log(comentario) values ('testando3');
--COMMIT;
--2) Herança => 
-- anexo (pai):
--CREATE TABLE esquema_requerimento.anexo (
--    id serial primary key,
--    descricao text not null,
--    arquivo bytea,
--    requerimento_id integer references requerimento (id) -- fk
--);

-- foto (filha)
CREATE TABLE esquema_requerimento.foto (
    metadados jsonb
) INHERITS (esquema_requerimento.anexo); 
-- atraves INHERITS (esquema_requerimento.anexo); herdei as colunas
--oriundas de anexo

-- n herdando as constraints, unique e etc. Por isso, eu crio separamente as constraints aqui:
--criando pk de foto
ALTER TABLE esquema_requerimento.foto ADD CONSTRAINT foto_pk primary key(id);
-- criando fk de foto
ALTER TABLE esquema_requerimento.foto ADD CONSTRAINT foto_fK1 FOREIGN KEY (requerimento_id) REFERENCES esquema_requerimento.requerimento(id);

-- add uma tupla de foto - lembrando que como eh filha de anexo - tb eh tipo de anexo
INSERT INTO foto (descricao, requerimento_id, metadados) values ('descricao', 1, '{"tamanho":100, "largura": 150}');

INSERT INTO foto (descricao, requerimento_id, metadados) values ('descricao', 1, '{"tamanho":100, "largura": 150, "cor_predominante": "vermelho"}');


INSERT INTO foto (descricao, requerimento_id, metadados) values ('descricao', 1, '{"n_existe": "ok"}');

-- PEGA SOMENTE AS TUPLAS LOCAIS/NATIVAS
select * from ONLY anexo;

-- PEGA TODAS (AS LOCAIS DE ANEXO + TODAS DE FOTO)
select * from anexo;

select metadados->'tamanho', metadados->>'cor_predominante' from foto;

--https://popsql.com/learn-sql/postgresql/how-to-query-a-json-column-in-postgresql

UPDATE foto SET metadados = metadados || '{"outra": 10}' where id = 5;
UPDATE foto SET metadados = metadados - 'outra' where id = 5;