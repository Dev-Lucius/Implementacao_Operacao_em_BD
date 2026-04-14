# 🔤 Funções de Manipulação de Strings no PostgreSQL

> **Apostila Digital** — Guia completo sobre funções de manipulação de texto no PostgreSQL, com exemplos práticos, casos de uso reais e exercícios resolvidos.

---

## 📚 Sumário

1. [Tipos de Dados de Texto](#-tipos-de-dados-de-texto)
2. [Busca e Comparação](#-busca-e-comparação)
3. [Transformação de Caso](#-transformação-de-caso)
4. [Tamanho e Comprimento](#-tamanho-e-comprimento)
5. [Concatenação](#-concatenação)
6. [Extração de Substrings](#-extração-de-substrings)
7. [Substituição e Remoção](#-substituição-e-remoção)
8. [Remoção de Espaços — TRIM](#-remoção-de-espaços--trim)
9. [Preenchimento — PADDING](#-preenchimento--padding)
10. [Posição e Busca dentro da String](#-posição-e-busca-dentro-da-string)
11. [Divisão e Junção](#-divisão-e-junção)
12. [Expressões Regulares (REGEX)](#-expressões-regulares-regex)
13. [Funções de Formatação](#-funções-de-formatação)
14. [Tratamento de NULLs em Strings](#-tratamento-de-nulls-em-strings)
15. [Exercícios Resolvidos](#-exercícios-resolvidos)
16. [Cheatsheet Rápido](#-cheatsheet-rápido)

---

## 🗂️ Tipos de Dados de Texto

O PostgreSQL oferece três tipos principais para armazenar texto:

| Tipo | Descrição | Quando usar |
|------|-----------|-------------|
| `CHAR(n)` | Tamanho fixo, preenchido com espaços | Códigos de tamanho fixo (ex: CEP, UF) |
| `VARCHAR(n)` | Tamanho variável com limite | Campos com tamanho máximo conhecido |
| `TEXT` | Tamanho ilimitado | Descrições, conteúdos longos |

```sql
CREATE TABLE usuarios (
    id        SERIAL       PRIMARY KEY,
    cpf       CHAR(14),           -- Sempre 14 chars: 000.000.000-00
    uf        CHAR(2),            -- Sempre 2 chars: SP, RJ...
    nome      VARCHAR(100),       -- Até 100 caracteres
    email     VARCHAR(255),       -- Até 255 caracteres
    bio       TEXT                -- Sem limite de tamanho
);
```

> 💡 **Boas Práticas:** No PostgreSQL, `TEXT` e `VARCHAR` têm performance idêntica. Prefira `TEXT` quando não houver um limite de negócio definido — evita erros desnecessários de truncamento.

---

## 🔍 Busca e Comparação

### LIKE e ILIKE

`LIKE` busca por padrão **sensível** a maiúsculas. `ILIKE` é **insensível**.

**Curingas:**
- `%` → qualquer sequência de caracteres (inclusive vazia)
- `_` → exatamente um caractere qualquer

```sql
-- Nomes que começam com "Ana"
SELECT * FROM usuarios WHERE nome LIKE 'Ana%';

-- Nomes que terminam com "Silva"
SELECT * FROM usuarios WHERE nome LIKE '%Silva';

-- Nomes que contêm "João" (qualquer capitalização)
SELECT * FROM usuarios WHERE nome ILIKE '%joão%';

-- CPFs que começam com "123"
SELECT * FROM usuarios WHERE cpf LIKE '123%';

-- Nomes com exatamente 5 letras
SELECT * FROM usuarios WHERE nome LIKE '_____';

-- Emails do domínio gmail
SELECT * FROM usuarios WHERE email ILIKE '%@gmail.com';
```

### NOT LIKE / NOT ILIKE

```sql
-- Usuários cujo nome NÃO contém "Teste"
SELECT * FROM usuarios WHERE nome NOT ILIKE '%teste%';

-- Emails que não são do domínio interno
SELECT * FROM usuarios WHERE email NOT ILIKE '%@empresa.com.br';
```

### Diferença entre LIKE e ILIKE

```sql
SELECT 'João' LIKE '%joão%';   -- FALSE (case sensitive)
SELECT 'João' ILIKE '%joão%';  -- TRUE  (case insensitive)
```

> ⚠️ `ILIKE` é uma extensão do PostgreSQL e não existe em todos os bancos. Em SQL padrão, usaria `LOWER(coluna) LIKE '%valor%'`.

---

## 🔠 Transformação de Caso

### UPPER() e LOWER()

```sql
-- Converter para maiúsculas
SELECT UPPER('PostgreSQL');   -- POSTGRESQL
SELECT UPPER(nome) AS nome_upper FROM usuarios;

-- Converter para minúsculas
SELECT LOWER('PostgreSQL');   -- postgresql
SELECT LOWER(email) AS email_lower FROM usuarios;
```

### INITCAP()

Converte a primeira letra de cada palavra para maiúscula.

```sql
SELECT INITCAP('maria silva santos');   -- Maria Silva Santos
SELECT INITCAP('PEDRO HENRIQUE');       -- Pedro Henrique
SELECT INITCAP(nome) AS nome_formatado FROM usuarios;
```

### Casos de uso reais

```sql
-- Normalizar nomes para comparação (evitar duplicatas por capitalização)
SELECT * FROM usuarios
WHERE LOWER(nome) = LOWER('maria silva');

-- Padronizar e-mails (sempre salvar em minúsculas)
UPDATE usuarios SET email = LOWER(email);

-- Exibir nomes sempre formatados (INITCAP)
SELECT
    id,
    INITCAP(LOWER(nome)) AS nome_formatado
FROM usuarios;
```

---

## 📏 Tamanho e Comprimento

### LENGTH() e CHAR_LENGTH()

```sql
-- Número de caracteres
SELECT LENGTH('PostgreSQL');        -- 10
SELECT CHAR_LENGTH('PostgreSQL');   -- 10 (equivalente ao LENGTH)

-- Em uma coluna
SELECT nome, LENGTH(nome) AS tamanho FROM usuarios;

-- Tratando NULL (LENGTH(NULL) retorna NULL)
SELECT nome, LENGTH(COALESCE(nome, '')) AS tamanho FROM usuarios;
```

### OCTET_LENGTH()

Retorna o número de **bytes** (útil para caracteres multi-byte como acentos).

```sql
SELECT LENGTH('ção');         -- 3 caracteres
SELECT OCTET_LENGTH('ção');   -- 5 bytes (UTF-8: ç=2bytes, ã=2bytes, o=1byte)
```

### BIT_LENGTH()

Retorna o número de **bits** da string.

```sql
SELECT BIT_LENGTH('abc');   -- 24 (3 bytes × 8 bits)
```

### Casos de uso reais

```sql
-- Validar CPF com 14 caracteres (com formatação: 000.000.000-00)
SELECT * FROM usuarios WHERE LENGTH(cpf) <> 14;

-- Encontrar emails suspeitos (muito curtos)
SELECT * FROM usuarios WHERE LENGTH(email) < 6;

-- Classificar por tamanho do nome
SELECT nome, LENGTH(nome) AS tamanho
FROM usuarios
ORDER BY tamanho DESC;

-- Filtrar por tamanho
SELECT * FROM usuarios WHERE LENGTH(nome) BETWEEN 3 AND 50;
```

---

## 🔗 Concatenação

### Operador `||`

```sql
SELECT 'Olá, ' || 'Mundo!';                  -- Olá, Mundo!
SELECT nome || ' - ' || email FROM usuarios;  -- Maria - maria@email.com

-- ATENÇÃO: NULL contamina o resultado com ||
SELECT 'Nome: ' || NULL;   -- NULL (resultado inteiro é NULL)
```

### CONCAT()

Ignora valores `NULL` automaticamente.

```sql
SELECT CONCAT('Olá, ', 'Mundo!');              -- Olá, Mundo!
SELECT CONCAT(nome, ' --- ', email) AS info FROM usuarios;

-- NULL é ignorado silenciosamente
SELECT CONCAT('Nome: ', NULL, ' Sobrenome');   -- Nome:  Sobrenome
```

### CONCAT_WS() — Concatenar com Separador

`CONCAT_WS(separador, valor1, valor2, ...)` — ignora NULLs e aplica o separador entre os valores.

```sql
-- Separador: ' | '
SELECT CONCAT_WS(' | ', nome, email, cpf) FROM usuarios;
-- Resultado: Maria Silva | maria@email.com | 123.456.789-00

-- Montar endereço completo
SELECT CONCAT_WS(', ', logradouro, numero, bairro, cidade, uf) AS endereco
FROM enderecos;
-- Resultado: Rua das Flores, 123, Centro, São Paulo, SP

-- NULLs são pulados automaticamente
SELECT CONCAT_WS(' - ', 'A', NULL, 'C');   -- A - C
```

### Comparativo

| Método | Trata NULL? | Separador automático? |
|--------|-------------|----------------------|
| `\|\|` | ❌ contamina | ❌ |
| `CONCAT()` | ✅ ignora | ❌ |
| `CONCAT_WS()` | ✅ ignora | ✅ |

---

## ✂️ Extração de Substrings

### SUBSTRING()

**Sintaxe:** `SUBSTRING(string, início, tamanho)`

> ⚠️ O segundo parâmetro é o **tamanho** (número de caracteres a retornar), **não** o índice final.

```sql
-- SUBSTRING(string, posição_inicial, quantidade_de_caracteres)
SELECT SUBSTRING('PostgreSQL', 1, 4);    -- Post
SELECT SUBSTRING('PostgreSQL', 5, 3);   -- gre
SELECT SUBSTRING('PostgreSQL', 8);      -- SQL (até o fim)

-- Em CPF formatado (000.000.000-00):
SELECT SUBSTRING(cpf, 1, 3)  AS bloco1  FROM usuarios;   -- 000
SELECT SUBSTRING(cpf, 5, 3)  AS bloco2  FROM usuarios;   -- 000
SELECT SUBSTRING(cpf, 9, 3)  AS bloco3  FROM usuarios;   -- 000
SELECT SUBSTRING(cpf, 13, 2) AS digitos FROM usuarios;   -- 00
```

### LEFT() e RIGHT()

Retornam os N primeiros ou últimos caracteres.

```sql
SELECT LEFT('PostgreSQL', 4);    -- Post
SELECT RIGHT('PostgreSQL', 3);   -- SQL

-- Mascarar CPF (exibir apenas os últimos 2 dígitos)
SELECT
    nome,
    '***.***.***-' || RIGHT(cpf, 2) AS cpf_mascarado
FROM usuarios;
-- Resultado: Maria Silva | ***.***.***-00

-- Domínio do email
SELECT
    email,
    RIGHT(email, LENGTH(email) - POSITION('@' IN email)) AS dominio
FROM usuarios;
```

### SUBSTR() — Alias de SUBSTRING()

```sql
SELECT SUBSTR('PostgreSQL', 1, 4);   -- Post (idêntico ao SUBSTRING)
```

---

## 🔄 Substituição e Remoção

### REPLACE()

Substitui **todas** as ocorrências de uma substring.

**Sintaxe:** `REPLACE(string, texto_antigo, texto_novo)`

```sql
SELECT REPLACE('Olá Mundo', 'Mundo', 'PostgreSQL');
-- Resultado: Olá PostgreSQL

SELECT REPLACE('aabbcc', 'b', 'X');
-- Resultado: aaXXcc (substitui TODAS as ocorrências)

-- Remover formatação do CPF (tirar pontos e traço)
SELECT REPLACE(REPLACE(cpf, '.', ''), '-', '') AS cpf_numerico
FROM usuarios;
-- 123.456.789-00 → 12345678900

-- Substituir caracteres acentuados
SELECT REPLACE(REPLACE(REPLACE(nome, 'ã', 'a'), 'é', 'e'), 'ç', 'c') AS nome_sem_acento
FROM usuarios;
```

### OVERLAY()

Substitui uma parte da string por posição.

**Sintaxe:** `OVERLAY(string PLACING novo FROM posição [FOR tamanho])`

```sql
SELECT OVERLAY('PostgreSQL' PLACING 'DATABASE' FROM 1 FOR 10);
-- Resultado: DATABASE

-- Mascarar dígitos do meio do CPF
SELECT OVERLAY(cpf PLACING '***.***' FROM 5 FOR 7) AS cpf_mascarado
FROM usuarios;
-- 123.456.789-00 → 123.***.***-00
```

### TRANSLATE()

Substitui caracteres **individualmente** (mapeamento 1-a-1).

**Sintaxe:** `TRANSLATE(string, de, para)`

```sql
SELECT TRANSLATE('Hello World', 'lo', 'LO');
-- Resultado: HeLLO WOrLd

-- Remover acentos (substituição caractere a caractere)
SELECT TRANSLATE(
    nome,
    'áàãâäéèêëíìîïóòõôöúùûüçñÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑ',
    'aaaaaaeeeeiiiiooooouuuucnAAAAEEEEIIIIOOOOUUUUCN'
) AS nome_sem_acento
FROM usuarios;

-- Remover caracteres (sem par no destino, são deletados)
SELECT TRANSLATE('R$ 1.234,56', '$. ,', '');   -- R1234_56
```

---

## 🧹 Remoção de Espaços — TRIM

### TRIM()

Remove espaços (ou caracteres específicos) do início, fim ou ambos.

**Sintaxe:** `TRIM([LEADING | TRAILING | BOTH] [caracteres] FROM string)`

```sql
-- Remover espaços dos dois lados (padrão = BOTH)
SELECT TRIM('   PostgreSQL   ');          -- 'PostgreSQL'
SELECT TRIM(BOTH FROM '   PostgreSQL   '); -- 'PostgreSQL'

-- Remover apenas do início
SELECT TRIM(LEADING FROM '   PostgreSQL   ');   -- 'PostgreSQL   '

-- Remover apenas do fim
SELECT TRIM(TRAILING FROM '   PostgreSQL   ');  -- '   PostgreSQL'

-- Remover caractere específico
SELECT TRIM(BOTH 'x' FROM 'xxPostgreSQLxx');    -- 'PostgreSQL'
SELECT TRIM(BOTH '0' FROM '00012300');           -- '123'
SELECT TRIM(BOTH 'a' FROM 'aabanaaa');           -- 'ban'
```

### LTRIM() e RTRIM()

Atalhos para remoção apenas de espaços.

```sql
SELECT LTRIM('   PostgreSQL');    -- 'PostgreSQL'  (remove à esquerda)
SELECT RTRIM('PostgreSQL   ');    -- 'PostgreSQL'  (remove à direita)
SELECT LTRIM(RTRIM('  texto  ')); -- 'texto'       (equivale ao TRIM)
```

### Casos de uso reais

```sql
-- Limpar dados importados com espaços extras
UPDATE usuarios SET nome = TRIM(nome) WHERE nome <> TRIM(nome);

-- Remover zeros à esquerda de códigos
SELECT TRIM(LEADING '0' FROM codigo) FROM produtos;
-- '000123' → '123'

-- Normalizar CPF removendo formatação e espaços
SELECT TRIM(REPLACE(REPLACE(cpf, '.', ''), '-', '')) AS cpf_limpo
FROM usuarios;
```

---

## 📐 Preenchimento — PADDING

### LPAD() e RPAD()

Preenchem uma string até um comprimento desejado.

**Sintaxe:** `LPAD(string, comprimento, [caractere_de_preenchimento])`

```sql
-- LPAD: preenche à ESQUERDA
SELECT LPAD('42', 5, '0');       -- '00042'
SELECT LPAD('SQL', 10, '-');     -- '-------SQL'
SELECT LPAD('SQL', 10);          -- '       SQL' (padrão: espaço)

-- RPAD: preenche à DIREITA
SELECT RPAD('42', 5, '0');       -- '42000'
SELECT RPAD('SQL', 10, '-');     -- 'SQL-------'
SELECT RPAD('SQL', 10);          -- 'SQL       '

-- Se a string for maior que o comprimento, ela é TRUNCADA
SELECT LPAD('PostgreSQL', 5);    -- 'Postg'
```

### Casos de uso reais

```sql
-- Formatar código de produto com zeros à esquerda
SELECT LPAD(id::TEXT, 6, '0') AS codigo_formatado FROM produtos;
-- 42 → '000042'

-- Formatar CEP com zeros à esquerda
SELECT LPAD(cep, 8, '0') AS cep_formatado FROM enderecos;

-- Gerar linha de relatório com separação visual
SELECT
    RPAD(nome, 30, ' ') || LPAD(valor::TEXT, 10, ' ') AS linha_relatorio
FROM produtos;
```

---

## 🔎 Posição e Busca dentro da String

### POSITION() e STRPOS()

Retornam a posição da primeira ocorrência de uma substring.

```sql
-- POSITION(substring IN string)
SELECT POSITION('@' IN 'usuario@email.com');   -- 8
SELECT POSITION('SQL' IN 'PostgreSQL');         -- 8

-- STRPOS(string, substring) — equivalente
SELECT STRPOS('usuario@email.com', '@');        -- 8
SELECT STRPOS('PostgreSQL', 'SQL');             -- 8

-- Retorna 0 se não encontrar
SELECT POSITION('xyz' IN 'PostgreSQL');   -- 0
```

### CHARINDEX() — não existe no PostgreSQL

> ⚠️ `CHARINDEX()` existe no SQL Server, mas **não no PostgreSQL**. Use `POSITION()` ou `STRPOS()`.

### Casos de uso reais

```sql
-- Extrair domínio do email usando POSITION + SUBSTRING
SELECT
    email,
    SUBSTRING(email, POSITION('@' IN email) + 1) AS dominio
FROM usuarios;
-- usuario@gmail.com → gmail.com

-- Verificar se o email tem '@'
SELECT * FROM usuarios WHERE POSITION('@' IN email) = 0;

-- Extrair a parte local do email (antes do @)
SELECT
    email,
    SUBSTRING(email, 1, POSITION('@' IN email) - 1) AS usuario_email
FROM usuarios;
-- usuario@gmail.com → usuario
```

---

## 🔀 Divisão e Junção

### SPLIT_PART()

Divide uma string por um delimitador e retorna a parte indicada.

**Sintaxe:** `SPLIT_PART(string, delimitador, posição)`

```sql
-- Dividir por '.'
SELECT SPLIT_PART('192.168.0.1', '.', 1);   -- 192
SELECT SPLIT_PART('192.168.0.1', '.', 2);   -- 168
SELECT SPLIT_PART('192.168.0.1', '.', 3);   -- 0
SELECT SPLIT_PART('192.168.0.1', '.', 4);   -- 1

-- Extrair partes do CPF formatado (000.000.000-00)
SELECT
    SPLIT_PART(cpf, '.', 1) AS parte1,   -- 000
    SPLIT_PART(cpf, '.', 2) AS parte2,   -- 000
    SPLIT_PART(
        SPLIT_PART(cpf, '.', 3), '-', 1
    )                        AS parte3,   -- 000
    SPLIT_PART(cpf, '-', 2)  AS digitos  -- 00
FROM usuarios;

-- Extrair primeiro nome
SELECT SPLIT_PART(nome, ' ', 1) AS primeiro_nome FROM usuarios;

-- Extrair sobrenome (último fragmento)
-- Atenção: SPLIT_PART não tem índice negativo; use outras funções para o último
```

### STRING_TO_ARRAY() e ARRAY_TO_STRING()

```sql
-- String para array
SELECT STRING_TO_ARRAY('a,b,c,d', ',');        -- {a,b,c,d}
SELECT STRING_TO_ARRAY('SP;RJ;MG', ';');       -- {SP,RJ,MG}

-- Array para string
SELECT ARRAY_TO_STRING(ARRAY['a','b','c'], '-'); -- a-b-c
SELECT ARRAY_TO_STRING(ARRAY['SP','RJ','MG'], ', '); -- SP, RJ, MG

-- Combinação útil: remover espaços de uma lista separada por vírgulas
SELECT ARRAY_TO_STRING(
    ARRAY(
        SELECT TRIM(unnest(STRING_TO_ARRAY('SP , RJ , MG', ',')))
    ), ', '
);
-- Resultado: SP, RJ, MG
```

---

## 🧩 Expressões Regulares (REGEX)

O PostgreSQL tem suporte nativo a expressões regulares.

### Operadores de REGEX

| Operador | Descrição | Case Sensitive |
|----------|-----------|----------------|
| `~` | Corresponde ao padrão POSIX | ✅ |
| `~*` | Corresponde ao padrão POSIX | ❌ |
| `!~` | NÃO corresponde ao padrão | ✅ |
| `!~*` | NÃO corresponde ao padrão | ❌ |

```sql
-- Nomes que começam com letra maiúscula
SELECT * FROM usuarios WHERE nome ~ '^[A-Z]';

-- CPFs válidos (formato 000.000.000-00)
SELECT * FROM usuarios
WHERE cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$';

-- Emails com formato básico válido
SELECT * FROM usuarios
WHERE email ~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$';

-- Nomes que NÃO contêm números
SELECT * FROM usuarios WHERE nome !~ '[0-9]';
```

### REGEXP_REPLACE()

Substitui baseado em expressão regular.

```sql
-- Remover todos os dígitos
SELECT REGEXP_REPLACE('abc123def456', '[0-9]', '', 'g');
-- Resultado: abcdef

-- Remover todos os não-dígitos (extrair apenas números)
SELECT REGEXP_REPLACE('123.456.789-00', '[^0-9]', '', 'g');
-- Resultado: 12345678900

-- Substituir múltiplos espaços por um único
SELECT REGEXP_REPLACE('texto   com   espaços', '\s+', ' ', 'g');
-- Resultado: texto com espaços
```

### REGEXP_MATCHES() e REGEXP_SUBSTR()

```sql
-- REGEXP_MATCHES: retorna todas as correspondências como array
SELECT REGEXP_MATCHES('PostgreSQL 14.2', '\d+', 'g');
-- Resultado: {14} e {2} (uma linha para cada match)

-- REGEXP_SUBSTR: retorna a primeira correspondência como texto
SELECT REGEXP_SUBSTR('PostgreSQL 14.2', '\d+\.\d+');
-- Resultado: 14.2
```

### Flags disponíveis

| Flag | Descrição |
|------|-----------|
| `g` | Global (todas as ocorrências) |
| `i` | Case insensitive |
| `n` | Ponto corresponde a newline também |

---

## 🎨 Funções de Formatação

### FORMAT()

Formata strings com placeholders, similar ao `printf`.

```sql
-- %s → string, %I → identificador, %L → literal SQL
SELECT FORMAT('Olá, %s! Você tem %s anos.', 'Maria', 25);
-- Resultado: Olá, Maria! Você tem 25 anos.

SELECT FORMAT('Bem-vindo, %s (%s)', nome, email)
FROM usuarios;

-- Útil para gerar SQL dinâmico com segurança
SELECT FORMAT('SELECT * FROM %I WHERE id = %L', 'usuarios', 42);
-- Resultado: SELECT * FROM usuarios WHERE id = '42'
```

### REPEAT()

Repete uma string N vezes.

```sql
SELECT REPEAT('AB', 3);        -- ABABAB
SELECT REPEAT('-', 30);        -- ------------------------------
SELECT REPEAT('* ', 5);        -- * * * * *

-- Gerar separadores visuais em relatórios
SELECT REPEAT('=', 50) AS separador;
```

### REVERSE()

Inverte a ordem dos caracteres.

```sql
SELECT REVERSE('PostgreSQL');   -- LQSergotsoP
SELECT REVERSE('abcde');        -- edcba

-- Verificar palíndromo
SELECT nome FROM palavras WHERE nome = REVERSE(nome);
```

### ASCII() e CHR()

```sql
-- ASCII: caractere → código numérico
SELECT ASCII('A');   -- 65
SELECT ASCII('a');   -- 97
SELECT ASCII('0');   -- 48

-- CHR: código numérico → caractere
SELECT CHR(65);    -- A
SELECT CHR(10);    -- (newline)
SELECT CHR(9);     -- (tab)

-- Gerar caracteres especiais
SELECT 'Linha 1' || CHR(10) || 'Linha 2';   -- com quebra de linha real
```

### MD5()

Gera hash MD5 de uma string.

```sql
SELECT MD5('minha_senha');
-- Resultado: hash de 32 caracteres hexadecimais

-- Comparar senhas hasheadas
SELECT * FROM usuarios
WHERE MD5(senha_digitada) = senha_hash;
```

---

## 🛡️ Tratamento de NULLs em Strings

```sql
-- COALESCE: retorna o primeiro valor não-nulo
SELECT COALESCE(apelido, nome, 'Anônimo') AS nome_exibicao
FROM usuarios;

-- NULLIF: retorna NULL se os dois valores forem iguais
SELECT NULLIF(nome, '') AS nome  -- '' vira NULL
FROM usuarios;

-- Evitar NULL em concatenações
SELECT COALESCE(nome, '') || ' ' || COALESCE(sobrenome, '') AS nome_completo
FROM usuarios;

-- Ou simplesmente usar CONCAT (já ignora NULLs)
SELECT CONCAT(nome, ' ', sobrenome) AS nome_completo
FROM usuarios;

-- Verificar strings vazias ou nulas
SELECT * FROM usuarios
WHERE nome IS NULL OR TRIM(nome) = '';

-- Converter string vazia para NULL
UPDATE usuarios SET apelido = NULLIF(TRIM(apelido), '');
```

---

## 📝 Exercícios Resolvidos

### 71. Buscar nome com ILIKE

```sql
-- Busca insensível a maiúsculas/minúsculas
SELECT
    id,
    cpf,
    nome
FROM usuario
WHERE nome ILIKE '%João%';

-- Variações úteis
SELECT * FROM usuario WHERE nome ILIKE 'joão%';    -- começa com João
SELECT * FROM usuario WHERE nome ILIKE '%santos';   -- termina com Santos
SELECT * FROM usuario WHERE nome ILIKE '%ana%';     -- contém Ana em qualquer posição
```

---

### 72. Uppercase

```sql
SELECT
    id,
    cpf,
    UPPER(nome) AS nome_upper
FROM usuario;
```

> ⚠️ Sempre use `AS` para nomear colunas com funções aplicadas. Sem ele, o PostgreSQL nomeia a coluna como `upper`, o que pode causar confusão.

---

### 73. Lowercase

```sql
SELECT
    id,
    cpf,
    LOWER(nome) AS nome_lower
FROM usuario;

-- Caso de uso: padronizar e-mails antes de salvar
UPDATE usuario SET email = LOWER(TRIM(email));
```

---

### 74. Tamanho do nome

```sql
SELECT
    id,
    cpf,
    nome,
    LENGTH(nome) AS tamanho_nome
FROM usuario;

-- Tratando possíveis NULLs
SELECT
    id,
    nome,
    LENGTH(COALESCE(nome, '')) AS tamanho_nome
FROM usuario;

-- Ordenar pelo tamanho do nome
SELECT id, nome, LENGTH(nome) AS tamanho
FROM usuario
ORDER BY tamanho DESC;
```

---

### 75. Concatenar nome + email

```sql
-- Com CONCAT (recomendado: ignora NULLs)
SELECT
    id,
    cpf,
    CONCAT(nome, ' --- ', email) AS nome_email
FROM usuario
WHERE nome IS NOT NULL
  AND email IS NOT NULL;

-- Com CONCAT_WS (mais elegante para múltiplos campos)
SELECT
    id,
    CONCAT_WS(' --- ', nome, email) AS nome_email
FROM usuario;

-- Com operador || (atenção: NULL contamina o resultado)
SELECT
    id,
    nome || ' --- ' || email AS nome_email
FROM usuario
WHERE nome IS NOT NULL
  AND email IS NOT NULL;
```

---

### 76. SUBSTRING no CPF

```sql
-- Retorna 7 caracteres a partir da posição 5
SELECT
    id,
    nome,
    SUBSTRING(cpf, 5, 7) AS parte_cpf   -- posição 5, tamanho 7
FROM usuario;

-- Extraindo todas as partes do CPF (formato 000.000.000-00)
SELECT
    id,
    cpf,
    SUBSTRING(cpf, 1,  3) AS bloco1,    -- 000
    SUBSTRING(cpf, 5,  3) AS bloco2,    -- 000
    SUBSTRING(cpf, 9,  3) AS bloco3,    -- 000
    SUBSTRING(cpf, 13, 2) AS digitos    -- 00
FROM usuario;

-- Mascarar CPF
SELECT
    id,
    '***.' || SUBSTRING(cpf, 5, 3) || '.***-**' AS cpf_mascarado
FROM usuario;
```

> ⚠️ **Atenção:** O segundo parâmetro do `SUBSTRING` é o **tamanho** (quantidade de caracteres), **não** o índice final.

---

### 77. REPLACE no nome

```sql
SELECT
    id,
    cpf,
    nome,
    email,
    REPLACE(nome, 'Teste', 'Pedro Silva') AS nome_modificado
FROM usuario;

-- Encadeando REPLACEs
SELECT
    REPLACE(
        REPLACE(
            REPLACE(cpf, '.', ''),  -- Remove pontos
        '-', ''),                   -- Remove traço
    ' ', '')                        -- Remove espaços
    AS cpf_numerico
FROM usuario;
```

---

### 78. TRIM

```sql
-- Remover 'a' de ambos os lados
SELECT
    id,
    nome,
    TRIM(BOTH 'a' FROM nome) AS nome_sem_a
FROM usuario;

-- Remover espaços (uso mais comum)
SELECT
    id,
    TRIM(nome) AS nome_limpo
FROM usuario;

-- Atualizar registros com espaços desnecessários
UPDATE usuario
SET nome = TRIM(nome)
WHERE nome <> TRIM(nome);
```

---

## 📋 Cheatsheet Rápido

### Referência de Funções

| Função | Descrição | Exemplo |
|--------|-----------|---------|
| `UPPER(s)` | Tudo maiúsculo | `UPPER('sql')` → `SQL` |
| `LOWER(s)` | Tudo minúsculo | `LOWER('SQL')` → `sql` |
| `INITCAP(s)` | Primeira letra de cada palavra maiúscula | `INITCAP('ol mundo')` → `Ol Mundo` |
| `LENGTH(s)` | Número de caracteres | `LENGTH('SQL')` → `3` |
| `CONCAT(...)` | Concatenar (ignora NULL) | `CONCAT('a','b')` → `ab` |
| `CONCAT_WS(sep, ...)` | Concatenar com separador | `CONCAT_WS('-','a','b')` → `a-b` |
| `SUBSTRING(s, i, n)` | Extrair n chars a partir de i | `SUBSTRING('SQL',1,2)` → `SQ` |
| `LEFT(s, n)` | Primeiros n chars | `LEFT('SQL',2)` → `SQ` |
| `RIGHT(s, n)` | Últimos n chars | `RIGHT('SQL',2)` → `QL` |
| `REPLACE(s, de, para)` | Substituir todas ocorrências | `REPLACE('ab','b','c')` → `ac` |
| `TRANSLATE(s, de, para)` | Substituição char a char | — |
| `OVERLAY(s PLACING n FROM i)` | Substituir por posição | — |
| `TRIM(s)` | Remove espaços dos dois lados | `TRIM(' sql ')` → `sql` |
| `LTRIM(s)` | Remove espaços à esquerda | `LTRIM(' sql')` → `sql` |
| `RTRIM(s)` | Remove espaços à direita | `RTRIM('sql ')` → `sql` |
| `LPAD(s, n, c)` | Preenche à esquerda | `LPAD('5',3,'0')` → `005` |
| `RPAD(s, n, c)` | Preenche à direita | `RPAD('5',3,'0')` → `500` |
| `POSITION(s IN t)` | Posição da substring | `POSITION('@' IN 'a@b')` → `2` |
| `STRPOS(t, s)` | Posição da substring (alt.) | `STRPOS('a@b','@')` → `2` |
| `SPLIT_PART(s, del, n)` | Parte N após divisão | `SPLIT_PART('a.b.c','.',2)` → `b` |
| `REVERSE(s)` | Inverte a string | `REVERSE('abc')` → `cba` |
| `REPEAT(s, n)` | Repete N vezes | `REPEAT('ab',3)` → `ababab` |
| `LIKE` | Padrão (case sensitive) | `nome LIKE '%Silva'` |
| `ILIKE` | Padrão (case insensitive) | `nome ILIKE '%silva'` |
| `REGEXP_REPLACE(s,p,r,f)` | Substituição com regex | — |

### Padrões de consulta mais comuns

```sql
-- Busca parcial insensível a maiúsculas
WHERE nome ILIKE '%valor%'

-- Normalizar para comparação
WHERE LOWER(TRIM(nome)) = LOWER(TRIM('busca'))

-- Verificar string vazia ou nula
WHERE nome IS NULL OR TRIM(nome) = ''

-- Remover formatação de CPF
REPLACE(REPLACE(cpf, '.', ''), '-', '')

-- Mascarar dado sensível
'***.' || SUBSTRING(cpf, 5, 3) || '.***-**'

-- Extrair domínio do email
SUBSTRING(email, POSITION('@' IN email) + 1)

-- Primeiro nome
SPLIT_PART(nome, ' ', 1)

-- Preencher com zeros à esquerda
LPAD(id::TEXT, 6, '0')

-- Validar CPF com regex
cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'
```

---

## 🔗 Referências

- [Documentação Oficial do PostgreSQL — String Functions](https://www.postgresql.org/docs/current/functions-string.html)
- [Documentação Oficial — Pattern Matching](https://www.postgresql.org/docs/current/functions-matching.html)
- [Documentação Oficial — Data Types: Character](https://www.postgresql.org/docs/current/datatype-character.html)
- [Documentação Oficial — Format Strings](https://www.postgresql.org/docs/current/functions-string.html#FUNCTIONS-STRING-FORMAT)

---

> **Lucas dos Santos de Oliveira**  
