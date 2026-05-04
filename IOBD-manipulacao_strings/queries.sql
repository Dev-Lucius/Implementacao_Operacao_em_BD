-- 71) Buscar nome com ILIKE.
SELECT * 
FROM usuario 
WHERE nome 
ILIKE 'i%';

-- 72)  Uppercase
SELECT * 
FROM usuario 
WHERE UPPER(nome) AS nome_upper
LIKE 'I%';

-- 73) Lowercase
SELECT * 
FROM usuario 
WHERE LOWER(nome) AS nome_lower
LIKE 'I%';

-- 74) Tamanho do nome.
SELECT
    id,
    cpf,
    nome,
    LENGTH(nome) AS tamanho_nome
FROM usuario;

-- 75) Concatenar nome + email.
SELECT nome||' '||email FROM usuario;
SELECT CONCAT(nome,' ',email) FROM usuario;

-- 76) SUBSTRING cpf. 
-- substr(variavel, posicao_partida, qtos_caracteres)
select nome, cpf, substr(cpf,1, 3)||'.'||substr(cpf,4,3)||'.'||substr(cpf,7,3)||'-'||substr(cpf, 10,2) from usuario;

-- 77) REPLACE no nome. 
-- replace(variavel, o que quero encontrar, pelo que vou substituir)
SELECT id, cpf, nome, email,
    REPLACE(nome, 'Teste', 'Pedro Silva') AS nome_modificado
FROM usuario;

-- 78) TRIM
SELECT id, nome,
    TRIM(BOTH 'a' FROM nome) AS nome_sem_a
FROM usuario;