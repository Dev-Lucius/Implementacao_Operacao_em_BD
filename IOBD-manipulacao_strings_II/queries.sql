-- 79. Formate nome em INITCAP.
-- INITCAP(variavel) --> Primeira letra das palavras em maiúscula
SELECT
    id,
    cpf,
    email,
    INITCAP(nome) 
from usuario;

-- 80. Localize posição da letra “A” no nome.
-- STRPOS(variavel, termo) --> Primeira Ocorrência de um termo dentro da variável 
SELECT
    nome,
    STRPOS(UPPER(nome), 'A')                        
FROM usuario;

-- 81. Divida email antes do “@”.
SELECT 
    email,
    SUBSTRING(email, 1, STRPOS(email, '@')-1) AS email_antes_do_arroba
FROM usuario;

-- Alternativa
-- SPLIT_PART(variavel, lugar_onde_a_string_separada, primeira_parte)
SELECT 
    email,
    SPLIT_PART(email, '@', 1)
FROM usuario;    

-- 82. Preencha CPF com zeros à esquerda (LPAD).
-- LPAD é uma função de string utilizada para preencher o lado esquerdo de uma string com um conjunto específico 
-- de caracteres até que a string atinja um comprimento especificado.
-- LPAD(string, length, fill_string)
SELECT
    nome,
    cpf,
    LPAD(cpf, 11, '0') AS cpf_esquerda
FROM usuario;

-- 83. Complete nome com 30 caracteres (RPAD).
-- RPAD é uma função de cadeia de caracteres utilizada para preencher à direita uma cadeia de 
-- caracteres com um conjunto especificado de caracteres até um determinado comprimento.
-- RPAD(source_string, length, padding_string)
SELECT
    nome,
    cpf,
    LPAD(nome, 30, ' - ') AS nome_direita
FROM usuario;

-- 84. Substitua espaços por underline.
-- REPLACE
SELECT
    id, 
    nome,
    REPLACE(nome, ' ', '_') AS nome_sem_espaco
FROM usuario;

-- 85. Liste apenas os 3 primeiros caracteres do nome
SELECT 
    nome,
    SUBSTRING(nome, 1, 3) AS tres_primeiros
FROM usuario;

