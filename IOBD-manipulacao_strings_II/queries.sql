-- 79) Formate nome em INITCAP.
SELECT
    id,
    cpf, 
    initcap(nome) 
FROM usuario;

-- 80) Localize posição da letra “A” no nome.
SELECT 
    nome, 
    strpos(UPPER(nome), 'A') AS primeira_ocorrencia_A
FROM usuario;

-- 81) Divida email antes do “@”.
-- retorna a string (substring) comecando pelo inicio indo ate encontrar o @
SELECT 
    email, 
    substr(email, 1, strpos(email, '@')-1) 
FROM usuario;

-- quebra a string pelo @ e retorna a primeira parte
SELECT 
    split_part(email, '@', 1) 
FROM usuario;

-- 82) Preencha CPF com zeros à esquerda (LPAD).
SELECT 
    lpad(cpf, 11, '0') 
FROM usuario;

-- 83) Complete nome com 30 caracteres (RPAD).
SELECT 
    rpad(nome, 30, ' ') 
FROM usuario;

-- prova real
SELECT 
    length(rpad(nome, 30, ' ')), length(nome) 
FROM usuario;

-- 84) Substitua espaços por underline.
SELECT
    nome
    replace(nome, ' ', '_') AS nome_com_underline
FROM usuario;

-- 85) Liste apenas os 3 primeiros caracteres do nome.
SELECT
    nome,
    substr(nome, 1, 3) 
FROM usuario;


