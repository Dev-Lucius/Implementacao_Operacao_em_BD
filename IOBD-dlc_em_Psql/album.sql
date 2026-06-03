DROP DATABASE IF EXISTS albumdb; 
CREATE DATABASE albumdb;

\c albumdb;

CREATE TABLE album (
    id serial primary key,
    dono varchar(200) not null,
    data_hora_compra timestamp default current_timestamp
);
INSERT INTO album(dono) VALUES
('ROGERIO'),
('RAFAEL'),
('ANDREI');

CREATE TABLE figurinha (
    id serial primary key,
    descricao text not null,
    selecao text
);
INSERT INTO figurinha (descricao, selecao) VALUES
('SIMBOLO DA FIFA',  NULL);

CREATE TABLE album_figurinha (
    figurinha_id integer references figurinha (id),
    album_id integer references album(id),
    primary key (album_id, figurinha_id)
);
INSERT INTO album_figurinha(album_id, figurinha_id) VALUES(1, 1);

CREATE OR REPLACE FUNCTION figurinhas_faltantes(album_id_aux integer) RETURNS TABLE (figurinha_aux integer) AS
$$
BEGIN
    IF (EXISTS(SELECT * FROM album WHERE id = album_id_aux)) THEN
        RETURN QUERY (WITH tabela_aux AS (select generate_series(1, 200) as figura_faltante EXCEPT (SELECT figurinha_id FROM album_figurinha WHERE album_id = album_id_aux))
select figura_faltante from tabela_aux order by figura_faltante);
    ELSE
         CREATE TEMPORARY TABLE IF NOT EXISTS fig_faltantes (
       figurinha_aux INTEGER
    ) ON COMMIT DROP;
        RAISE NOTICE 'album inexistente';
        RETURN QUERY SELECT * FROM fig_faltantes ;
    END IF;
END;
$$ LANGUAGE 'plpgsql'; 


-- super user
DROP ROLE figurinha_master;
CREATE ROLE figurinha_master LOGIN PASSWORD '111' SUPERUSER;


-- usuario que faz tudo - DELETE e tb n mexe nas funcoes
DROP ROLE figurinha_admin;
CREATE ROLE figurinha_admin LOGIN PASSWORD '222';
GRANT CONNECT ON DATABASE albumdb TO figurinha_admin;
GRANT USAGE ON SCHEMA public TO figurinha_admin;
-- faz tudo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO figurinha_admin;
-- mexe nas sequencias
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO figurinha_admin;
-- n faz delete
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM figurinha_admin;
-- ninguem mexe nas funcoes
REVOKE EXECUTE ON FUNCTION figurinhas_faltantes(INTEGER) FROM PUBLIC;


-- usuaruio que soh faz select e o unico (fora os superusers) que usa a funcao
DROP ROLE figurinha_user;
CREATE ROLE figurinha_user LOGIN PASSWORD '333';
GRANT CONNECT ON DATABASE albumdb TO figurinha_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO figurinha_user;
-- para o admin - liberamos exclusivamente (alem dos superusers) o acesso a function
GRANT EXECUTE ON FUNCTION figurinhas_faltantes(album_id_aux integer) TO figurinha_user;


-- tudo - UPDATE e premissa que tb nao possa as funcoes
DROP ROLE figurinha_data;
-- define o nro maximo de 2 conexoes simultaneas para este role
CREATE ROLE figurinha_data LOGIN PASSWORD '444' CONNECTION LIMIT 2;

DROP ROLE figurinha_criador_db;
CREATE ROLE figurinha_criador_db LOGIN PASSWORD 'pass' CREATEDB;


