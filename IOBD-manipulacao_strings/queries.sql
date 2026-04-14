-- 71. Buscar nome com ILIKE.
SELECT
    id,
    cpf,
    nome
FROM usuario 
WHERE nome ILIKE '%João%';

-- 72. Uppercase --> 
SELECT
    id,
    cpf,
    UPPER(nome) AS nome_upper
FROM usuario;

-- 73. Lowercase -->
SELECT
    id,
    cpf,
    LOWER(nome) AS nome_lower
FROM usuario;

-- 74. Tamanho do nome -->
-- OBSERVAÇÃO!!
-- Vale lembrar que LENGTH(NULL) retorna NULL — se quiser tratar:
-- LENGTH(COALESCE(nome, '')) AS tamanho_nome
SELECT
    id,
    cpf,
    nome,
    LENGTH(nome) AS tamanho_nome
FROM usuario;

-- 75. Concatenar nome + email -->
SELECT
    id,
    cpf,
    CONCAT(nome, ' --- ', email)
FROM usuario
WHERE nome IS NOT NULL 
AND email IS NOT NULL;

-- 76. SUBSTRING cpf
-- Sintaxe: 
-- SUBSTRING (expressão, início, tamanho).
--  * Expressão: A string ou coluna de texto.Início: 
--  * Posição inicial (inteiro) - Nota: em muitos SQLs, a contagem começa em 1, não 0.
--  * Tamanho: Número de caracteres a retornar.
-- Exemplo:
-- SELECT SUBSTRING('Exemplo', 1, 3) --> retorna 'Exe'.
SELECT 
    id,
    nome,
    -- Retorna uma Substring do CPF
    -- Desde o índice 5 até o índice 11
    SUBSTRING(cpf, 5, 11) AS substring_cpf
FROM usuario;

-- 77. REPLACE no nome -->
-- REPLACE no PostgreSQL substitui todas as ocorrências de uma substring específica (from_text) por uma nova substring (to_text) dentro de uma string de origem (source).
-- REPLACE(string_origem, texto_antigo, texto_novo)
-- Exemplo: 
-- SELECT REPLACE('Ola Mundo', 'Mundo', 'PostgreSQL'); --> Resultado: 'Ola PostgreSQL'
SELECT
    id,
    cpf,
    nome,
    email,
    REPLACE(nome, 'Teste', 'Pedro Silva') AS nome_modificado
FROM usuario;

-- 78. TRIM
-- TRIM é uma ferramenta de manipulação de texto usada para remover espaços em branco ou caracteres específicos do início, do fim, ou de ambos os lados de uma string
-- Variações !!!
-- Remove espaços dos dois lados (uso mais comum)
TRIM(nome)

-- Remove apenas do início
LTRIM(nome)

-- Remove apenas do fim
RTRIM(nome)

-- Remove caractere específico de ambos os lados
TRIM(BOTH 'a' FROM nome)

-- Consulta do Exercício
SELECT 
    id,
    nome,
    TRIM(BOTH 'a' FROM nome) AS nome_sem_a
FROM usuario;
