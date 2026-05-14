# 📚 Apostila: Manipulação e Anexação de Arquivos no PostgreSQL

> **Nível:** Intermediário / Avançado  
> **Pré-requisitos:** Conhecimento básico de SQL e PostgreSQL  
> **Versão de referência:** PostgreSQL 14+

---

## Sumário

1. [Introdução](#1-introdução)
2. [Arquitetura de Armazenamento do PostgreSQL](#2-arquitetura-de-armazenamento-do-postgresql)
3. [Tipo BYTEA](#3-tipo-bytea)
4. [Large Objects (Objetos Grandes)](#4-large-objects-objetos-grandes)
5. [Acesso ao Sistema de Arquivos do Servidor](#5-acesso-ao-sistema-de-arquivos-do-servidor)
6. [Comando COPY e file_fdw](#6-comando-copy-e-file_fdw)
7. [Segurança e Controle de Acesso](#7-segurança-e-controle-de-acesso)
8. [Performance e Boas Práticas](#8-performance-e-boas-práticas)
9. [Integração com Aplicações](#9-integração-com-aplicações)
10. [Casos de Uso e Padrões de Projeto](#10-casos-de-uso-e-padrões-de-projeto)
11. [Exercícios Práticos](#11-exercícios-práticos)
12. [Referências e Leitura Complementar](#12-referências-e-leitura-complementar)

---

## 1. Introdução

O PostgreSQL oferece múltiplas estratégias para persistir e manipular arquivos binários. Diferente de simplesmente guardar um caminho de arquivo em um campo `TEXT`, armazenar o arquivo diretamente no banco garante **integridade transacional**, **backup unificado** e **controle de acesso centralizado**.

### Por que armazenar arquivos no banco?

| Abordagem | Vantagens | Desvantagens |
|---|---|---|
| **Arquivo no sistema de arquivos** | Alta performance de I/O, fácil integração com CDN | Sem atomicidade, backup separado, problemas de sincronização |
| **Arquivo no banco (BYTEA / LO)** | Transacional, backup unificado, controle de acesso via SQL | Aumenta o tamanho do banco, overhead de I/O para arquivos grandes |
| **Híbrido (referência + objeto storage)** | Escalável, melhor performance | Complexidade de implementação, dois sistemas para manter |

### Quando usar cada estratégia

```
Arquivo < 1 MB e acesso simples?           → BYTEA
Arquivo > 1 MB ou acesso parcial/streaming? → Large Object (OID)
Dados tabulares externos?                  → COPY / file_fdw
Acesso a configs e logs do servidor?       → pg_read_file / pg_ls_dir
Escala massiva de arquivos?                → Object Storage externo (S3, MinIO) + referência no banco
```

---

## 2. Arquitetura de Armazenamento do PostgreSQL

Antes de manipular arquivos, é essencial entender como o PostgreSQL organiza seus dados internamente.

### 2.1 Estrutura de Diretórios (PGDATA)

```
$PGDATA/
├── base/                  # Diretório dos bancos de dados
│   └── 16384/             # Diretório de um banco específico (OID do banco)
│       ├── 1259           # Arquivo de dados de uma tabela (pg_class)
│       ├── 1259_fsm       # Free Space Map
│       └── 1259_vm        # Visibility Map
├── global/                # Tabelas compartilhadas entre todos os bancos
├── pg_wal/                # Write-Ahead Log (WAL)
├── pg_largeobject/        # Armazenamento interno dos Large Objects
└── postgresql.conf        # Arquivo de configuração principal
```

### 2.2 Estrutura TOAST (The Oversized-Attribute Storage Technique)

Quando um valor de coluna ultrapassa **~2 KB**, o PostgreSQL automaticamente aciona o mecanismo **TOAST**, que pode:

- **Comprimir** os dados in-line (estratégia `EXTENDED`)
- **Mover** os dados para uma tabela TOAST separada (estratégia `EXTERNAL`)
- **Comprimir e mover** (estratégia padrão `MAIN`)
- **Nunca comprimir nem mover** (estratégia `PLAIN`)

```sql
-- Verificar a estratégia TOAST de cada coluna
SELECT attname, attstorage
FROM pg_attribute
WHERE attrelid = 'minha_tabela'::regclass
  AND attnum > 0;

-- Alterar a estratégia de armazenamento de uma coluna BYTEA
ALTER TABLE documentos ALTER COLUMN conteudo SET STORAGE EXTERNAL;
-- EXTERNAL: não comprime, mas armazena fora da linha (acesso parcial eficiente)
```

| Estratégia | Compressão | Fora da linha | Indicado para |
|---|---|---|---|
| `PLAIN` | Não | Não | Dados pequenos e fixos |
| `MAIN` | Sim | Somente se necessário | Padrão geral |
| `EXTENDED` | Sim | Sim | Texto/binário grande compressível |
| `EXTERNAL` | Não | Sim | BYTEA com acesso parcial frequente |

---

## 3. Tipo BYTEA

O tipo `BYTEA` (Binary DATA) armazena sequências de bytes **diretamente na linha da tabela** (ou via TOAST se muito grande). É a forma mais simples de guardar conteúdo binário no PostgreSQL.

### 3.1 Criação e Estrutura Básica

```sql
CREATE TABLE documentos (
    id          SERIAL PRIMARY KEY,
    nome        TEXT NOT NULL,
    mime_type   TEXT NOT NULL,
    tamanho     INTEGER,
    conteudo    BYTEA NOT NULL,
    criado_em   TIMESTAMPTZ DEFAULT now(),
    atualizado_em TIMESTAMPTZ DEFAULT now()
);
```

### 3.2 Inserção de Dados Binários

**Via SQL puro (representação hexadecimal):**

```sql
-- Inserindo bytes em formato hexadecimal (prefixo \x)
INSERT INTO documentos (nome, mime_type, tamanho, conteudo)
VALUES (
    'exemplo.png',
    'image/png',
    4,
    '\x89504e47'  -- Primeiros 4 bytes do header PNG
);
```

**Via função `decode`:**

```sql
-- Decodificando base64
INSERT INTO documentos (nome, mime_type, conteudo)
VALUES (
    'relatorio.pdf',
    'application/pdf',
    decode('JVBERi0xLjQK...', 'base64')  -- conteúdo em base64
);

-- Decodificando hexadecimal
INSERT INTO documentos (nome, mime_type, conteudo)
VALUES (
    'dados.bin',
    'application/octet-stream',
    decode('DEADBEEF', 'hex')
);
```

### 3.3 Leitura e Exportação

```sql
-- Leitura simples
SELECT nome, mime_type, length(conteudo) AS tamanho_bytes
FROM documentos;

-- Convertendo para base64 (útil para APIs)
SELECT nome, encode(conteudo, 'base64') AS conteudo_base64
FROM documentos
WHERE id = 1;

-- Convertendo para hexadecimal
SELECT nome, encode(conteudo, 'hex') AS conteudo_hex
FROM documentos
WHERE id = 1;
```

### 3.4 Funções de Manipulação de BYTEA

```sql
-- Comprimento em bytes
SELECT length('\x89504e47AABBCC'::bytea);  -- Retorna 7

-- Concatenação de sequências de bytes
SELECT '\x0102'::bytea || '\x0304'::bytea;  -- \x01020304

-- Extraindo uma subsequência (offset começa em 1)
SELECT substring('\x0102030405'::bytea FROM 2 FOR 3);  -- \x020304

-- Posição de uma subsequência dentro de outra
SELECT position('\x0203'::bytea IN '\x010203040506'::bytea);  -- Retorna 2

-- Substituição de bytes
SELECT overlay('\x010203040506'::bytea
               PLACING '\xFFFF'::bytea
               FROM 3 FOR 2);  -- \x0102FFFF0506

-- Obtendo um byte específico como inteiro
SELECT get_byte('\x010203'::bytea, 1);  -- Retorna 2 (índice base 0)

-- Definindo um byte específico
SELECT set_byte('\x010203'::bytea, 1, 255);  -- \x01FF03
```

### 3.5 Formatos de Saída

O PostgreSQL pode exibir `BYTEA` em dois formatos, controlado pelo parâmetro `bytea_output`:

```sql
-- Formato hexadecimal (padrão desde PostgreSQL 9.0)
SET bytea_output = 'hex';
SELECT '\x41424344'::bytea;  -- Resultado: \x41424344

-- Formato escape (legado)
SET bytea_output = 'escape';
SELECT '\x41424344'::bytea;  -- Resultado: ABCD (bytes ASCII imprimíveis)
```

### 3.6 Limitações do BYTEA

- Limite teórico: **1 GB** por valor (limitação do tipo `varlena`)
- Na prática: desempenho degrada significativamente acima de **~10 MB**
- Não há suporte a acesso parcial/streaming no nível SQL
- Cada leitura carrega o valor inteiro para a memória

---

## 4. Large Objects (Objetos Grandes)

O sistema de **Large Objects** (LO) do PostgreSQL foi projetado especificamente para armazenar e manipular arquivos grandes. Cada objeto é identificado por um **OID** (Object Identifier) e armazenado internamente na tabela de sistema `pg_largeobject`.

### 4.1 Como Funciona Internamente

```
Tabela: pg_largeobject
┌──────────┬────────────┬──────────────────────────┐
│  loid    │  pageno    │  data                    │
│  (OID)   │  (int4)    │  (bytea, até 2 KB/página) │
├──────────┼────────────┼──────────────────────────┤
│  16432   │  0         │  [bytes 0–2047]          │
│  16432   │  1         │  [bytes 2048–4095]       │
│  16432   │  2         │  [bytes 4096–6143]       │
│  ...     │  ...       │  ...                     │
└──────────┴────────────┴──────────────────────────┘
```

Um arquivo de 6 MB é dividido em aproximadamente **3072 páginas** de 2 KB.

### 4.2 Operações de Alto Nível

```sql
-- Importar arquivo do sistema de arquivos do servidor para o banco
SELECT lo_import('/tmp/relatorio.pdf');
-- Retorna: 16432 (OID gerado automaticamente)

-- Importar especificando o OID manualmente
SELECT lo_import('/tmp/relatorio.pdf', 99999);

-- Exportar do banco para o sistema de arquivos do servidor
SELECT lo_export(16432, '/tmp/saida_relatorio.pdf');

-- Criar um Large Object vazio (retorna o OID)
SELECT lo_create(0);     -- OID automático
SELECT lo_create(12345); -- OID específico (falha se já existe)

-- Excluir um Large Object
SELECT lo_unlink(16432);

-- Verificar o tamanho de um Large Object
SELECT lo_lseek64(fd, 0, 2)  -- Seek para o fim (SEEK_END)
-- (Veja operações de baixo nível abaixo)
```

### 4.3 Operações de Baixo Nível (File Descriptor)

O acesso de baixo nível usa um descritor de arquivo (`fd`) similar ao de sistemas Unix.

**Modos de abertura:**

| Constante | Valor | Descrição |
|---|---|---|
| `INV_READ`  | 262144 | Somente leitura |
| `INV_WRITE` | 131072 | Somente escrita |
| `INV_READ \| INV_WRITE` | 393216 | Leitura e escrita |

**Modos de `lo_lseek` (seek):**

| Constante | Valor | Descrição |
|---|---|---|
| `SEEK_SET` | 0 | Relativo ao início |
| `SEEK_CUR` | 1 | Relativo à posição atual |
| `SEEK_END` | 2 | Relativo ao fim |

```sql
DO $$
DECLARE
    v_oid   OID     := 16432;
    v_fd    INTEGER;
    v_dados BYTEA;
    v_pos   BIGINT;
    v_tam   BIGINT;
BEGIN
    -- Abre para leitura (INV_READ = 262144)
    v_fd := lo_open(v_oid, 262144);

    -- Obtém o tamanho total (seek para o fim, captura posição)
    v_tam := lo_lseek64(v_fd, 0, 2);
    RAISE NOTICE 'Tamanho do arquivo: % bytes', v_tam;

    -- Volta ao início (SEEK_SET = 0)
    PERFORM lo_lseek(v_fd, 0, 0);

    -- Lê os primeiros 4096 bytes
    v_dados := loread(v_fd, 4096);
    RAISE NOTICE 'Bytes lidos: %', length(v_dados);

    -- Posição atual após a leitura
    v_pos := lo_tell64(v_fd);
    RAISE NOTICE 'Posição atual: %', v_pos;

    -- Fecha o descritor
    PERFORM lo_close(v_fd);
END;
$$;
```

### 4.4 Escrita em Large Objects

```sql
DO $$
DECLARE
    v_oid  OID;
    v_fd   INTEGER;
    v_novo BYTEA := '\x48656c6c6f20576f726c6421'; -- "Hello World!" em hex
BEGIN
    -- Cria um novo Large Object
    v_oid := lo_create(0);

    -- Abre para escrita (INV_WRITE = 131072)
    v_fd := lo_open(v_oid, 131072);

    -- Escreve os dados
    PERFORM lowrite(v_fd, v_novo);

    -- Fecha
    PERFORM lo_close(v_fd);

    RAISE NOTICE 'Large Object criado com OID: %', v_oid;
END;
$$;
```

### 4.5 Truncar um Large Object

```sql
DO $$
DECLARE
    v_fd INTEGER;
BEGIN
    v_fd := lo_open(16432, 131072); -- INV_WRITE
    -- Trunca o arquivo para 1024 bytes
    PERFORM lo_truncate(v_fd, 1024);
    PERFORM lo_close(v_fd);
END;
$$;
```

### 4.6 Integrando Large Objects a Tabelas

```sql
CREATE TABLE arquivos (
    id          SERIAL PRIMARY KEY,
    nome        TEXT        NOT NULL,
    mime_type   TEXT        NOT NULL,
    oid_arquivo OID,                       -- Referência ao Large Object
    hash_sha256 TEXT,                      -- Para verificação de integridade
    criado_em   TIMESTAMPTZ DEFAULT now()
);

-- Inserindo com lo_import
INSERT INTO arquivos (nome, mime_type, oid_arquivo)
VALUES (
    'contrato_2024.pdf',
    'application/pdf',
    lo_import('/tmp/contrato_2024.pdf')
);
```

### 4.7 Trigger de Limpeza Automática (CRITICAL)

> ⚠️ **Atenção:** Excluir uma linha da tabela **NÃO** exclui automaticamente o Large Object referenciado. É necessário criar uma trigger ou chamar `lo_unlink()` manualmente para evitar acúmulo de dados órfãos.

```sql
-- Trigger de exclusão
CREATE OR REPLACE FUNCTION fn_limpar_large_object()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.oid_arquivo IS NOT NULL THEN
        PERFORM lo_unlink(OLD.oid_arquivo);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limpar_lo_delete
    BEFORE DELETE ON arquivos
    FOR EACH ROW
    EXECUTE FUNCTION fn_limpar_large_object();

-- Trigger de atualização (quando o OID muda)
CREATE OR REPLACE FUNCTION fn_limpar_large_object_update()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.oid_arquivo IS NOT NULL AND OLD.oid_arquivo IS DISTINCT FROM NEW.oid_arquivo THEN
        PERFORM lo_unlink(OLD.oid_arquivo);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limpar_lo_update
    BEFORE UPDATE OF oid_arquivo ON arquivos
    FOR EACH ROW
    EXECUTE FUNCTION fn_limpar_large_object_update();
```

### 4.8 Identificando Large Objects Órfãos

```sql
-- Lista Large Objects sem referência em nenhuma tabela
-- (requer a extensão lo ou consulta manual)

-- Via extensão lo (recomendado)
CREATE EXTENSION lo;
-- A extensão adiciona a função lo_manage() e a view lo_refs

-- Manualmente: Large Objects que não aparecem em pg_largeobject_metadata
-- com correspondência na sua tabela de arquivos
SELECT loid
FROM pg_largeobject_metadata
WHERE loid NOT IN (
    SELECT oid_arquivo FROM arquivos WHERE oid_arquivo IS NOT NULL
);
```

### 4.9 Comparativo: BYTEA vs Large Object

| Característica | BYTEA | Large Object |
|---|---|---|
| Tamanho máximo prático | ~10 MB | Vários GB |
| Acesso parcial (seek) | ❌ | ✅ |
| Streaming | ❌ | ✅ |
| Transacional | ✅ | ✅ |
| Exclusão automática com a linha | ✅ | ❌ (manual) |
| Simplicidade de uso | ✅ Alta | ⚠️ Média |
| Performance para arquivos pequenos | ✅ Melhor | ⚠️ Pior |
| Suporte nativo em ORMs | ✅ Amplo | ⚠️ Limitado |
| Compressão automática (TOAST) | ✅ | ❌ |

---

## 5. Acesso ao Sistema de Arquivos do Servidor

O PostgreSQL fornece funções de administração que permitem ler arquivos diretamente do sistema de arquivos do servidor (não do cliente).

> 🔒 **Restrição de segurança:** Essas funções acessam apenas arquivos dentro do diretório `PGDATA` ou listados em `pg_file_settings`. Requerem permissão de superusuário ou papel `pg_monitor`.

### 5.1 Funções de Leitura de Arquivos

```sql
-- Ler um arquivo de texto completo
SELECT pg_read_file('postgresql.conf');

-- Ler com offset e limite (em bytes)
SELECT pg_read_file('postgresql.conf', 0, 512);

-- Ler arquivo binário como bytea
SELECT pg_read_binary_file('PG_VERSION');

-- Ler com offset
SELECT pg_read_binary_file('pg_wal/000000010000000000000001', 0, 8192);
```

### 5.2 Funções de Listagem de Diretórios

```sql
-- Listar arquivos em um diretório (relativo ao PGDATA)
SELECT * FROM pg_ls_dir('pg_wal');

-- Listagem com metadados (PostgreSQL 10+)
SELECT name, size, modification
FROM pg_ls_dir('pg_wal', false, false) AS t(name TEXT);

-- Listar com tamanho e data de modificação
SELECT *
FROM pg_stat_file('postgresql.conf');
-- Retorna: size, access, modification, change, creation, isdir
```

### 5.3 Funções de Log e WAL

```sql
-- Listar arquivos WAL
SELECT * FROM pg_ls_waldir()
ORDER BY modification DESC;

-- Listar arquivos de log do PostgreSQL
SELECT * FROM pg_ls_logdir()
ORDER BY modification DESC;

-- Ler as últimas linhas do log atual
SELECT pg_read_file(
    'log/' || (
        SELECT name FROM pg_ls_logdir() ORDER BY modification DESC LIMIT 1
    ),
    pg_stat_file(
        'log/' || (
            SELECT name FROM pg_ls_logdir() ORDER BY modification DESC LIMIT 1
        )
    ).size - 4096,  -- lê os últimos 4KB
    4096
);
```

---

## 6. Comando COPY e file_fdw

### 6.1 O Comando COPY

O `COPY` é o mecanismo nativo do PostgreSQL para importar e exportar dados tabulares em larga escala, muito mais eficiente que `INSERT` linha a linha.

**Diferença entre COPY e \copy:**

| | `COPY` (servidor) | `\copy` (cliente/psql) |
|---|---|---|
| Executa em | Servidor PostgreSQL | Processo psql do cliente |
| Requer superusuário | Sim | Não |
| Acessa arquivos de | Sistema de arquivos do servidor | Sistema de arquivos do cliente |
| Performance | Alta | Ligeiramente menor |

```sql
-- Importar CSV do servidor
COPY vendas (id, produto, quantidade, valor)
FROM '/var/data/vendas_2024.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE '\\',
    NULL 'NULL',
    ENCODING 'UTF8'
);

-- Exportar tabela para CSV
COPY vendas
TO '/var/data/export_vendas.csv'
WITH (FORMAT csv, HEADER true);

-- Exportar resultado de query
COPY (
    SELECT produto, SUM(quantidade) AS total
    FROM vendas
    GROUP BY produto
    ORDER BY total DESC
)
TO '/var/data/resumo_vendas.csv'
WITH (FORMAT csv, HEADER true);

-- Importar JSON Lines
COPY logs (dados_json)
FROM '/var/data/logs.jsonl'
WITH (FORMAT text);

-- Importar dados binários (formato nativo PostgreSQL)
COPY tabela FROM '/var/data/backup.bin' WITH (FORMAT binary);
```

**Via psql (arquivo no cliente):**

```sql
-- No prompt do psql
\copy vendas FROM 'C:/dados/vendas.csv' WITH (FORMAT csv, HEADER true)
\copy vendas TO '/home/usuario/export.csv' WITH (FORMAT csv, HEADER true)
```

### 6.2 COPY com Transformações via Programa Externo

```sql
-- Importar arquivo comprimido diretamente
COPY tabela FROM PROGRAM 'zcat /var/data/arquivo.csv.gz'
WITH (FORMAT csv, HEADER true);

-- Importar com pré-processamento via sed/awk
COPY tabela FROM PROGRAM 'sed ''s/\r//'' /var/data/windows_file.csv'
WITH (FORMAT csv);

-- Exportar comprimido
COPY tabela TO PROGRAM 'gzip > /var/data/export.csv.gz'
WITH (FORMAT csv, HEADER true);
```

> ⚠️ **Segurança:** `COPY ... FROM PROGRAM` executa comandos shell no servidor. Requer superusuário e deve ser usado com extrema cautela.

### 6.3 Foreign Data Wrapper: file_fdw

O `file_fdw` permite tratar arquivos externos como **tabelas virtuais** do PostgreSQL, consultando-os com SQL padrão sem importar os dados.

```sql
-- 1. Instalar a extensão
CREATE EXTENSION file_fdw;

-- 2. Criar o servidor foreign
CREATE SERVER servidor_arquivos
FOREIGN DATA WRAPPER file_fdw;

-- 3. Criar a tabela foreign (aponta para um arquivo CSV)
CREATE FOREIGN TABLE vendas_externas (
    id        INTEGER,
    produto   TEXT,
    quantidade INTEGER,
    valor     NUMERIC(10,2),
    data_venda DATE
)
SERVER servidor_arquivos
OPTIONS (
    filename '/var/data/vendas.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    null 'NULL'
);

-- 4. Consultar como uma tabela normal
SELECT produto, SUM(quantidade) AS total_vendido
FROM vendas_externas
WHERE data_venda >= '2024-01-01'
GROUP BY produto
ORDER BY total_vendido DESC;

-- Apontar para múltiplos arquivos (usando PROGRAM)
CREATE FOREIGN TABLE logs_externos (
    linha TEXT
)
SERVER servidor_arquivos
OPTIONS (
    program 'cat /var/log/app/*.log',
    format 'text'
);
```

---

## 7. Segurança e Controle de Acesso

### 7.1 Permissões em Large Objects

```sql
-- Large Objects têm seu próprio sistema de ACL
-- Por padrão, apenas o criador e superusuários têm acesso

-- Conceder leitura a um usuário
GRANT SELECT ON LARGE OBJECT 16432 TO usuario_leitura;

-- Conceder escrita a um usuário
GRANT UPDATE ON LARGE OBJECT 16432 TO usuario_escrita;

-- Conceder acesso a todos os Large Objects (requer superusuário)
-- Não existe um GRANT ALL ON ALL LARGE OBJECTS diretamente
-- Use uma função wrapper:

CREATE OR REPLACE FUNCTION fn_conceder_acesso_lo(p_oid OID, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('GRANT SELECT ON LARGE OBJECT %s TO %I', p_oid, p_usuario);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 7.2 Row-Level Security com BYTEA

```sql
-- Habilitar RLS na tabela de documentos
ALTER TABLE documentos ENABLE ROW LEVEL SECURITY;

-- Política: usuários só veem seus próprios documentos
CREATE POLICY pol_usuario_proprio ON documentos
    FOR ALL
    USING (proprietario = current_user);

-- Política: administradores veem tudo
CREATE POLICY pol_admin ON documentos
    FOR ALL
    TO admin_role
    USING (true);
```

### 7.3 Criptografia de Dados Binários

```sql
-- Instalar extensão pgcrypto
CREATE EXTENSION pgcrypto;

-- Criptografar arquivo antes de armazenar (AES)
INSERT INTO documentos_criptografados (nome, conteudo_enc)
VALUES (
    'contrato_secreto.pdf',
    pgp_sym_encrypt(
        decode('...base64_do_arquivo...', 'base64'),
        'senha_super_secreta_256bits',
        'cipher-algo=aes256'
    )
);

-- Descriptografar na leitura
SELECT
    nome,
    pgp_sym_decrypt(conteudo_enc, 'senha_super_secreta_256bits') AS conteudo
FROM documentos_criptografados
WHERE id = 1;

-- Hash para verificação de integridade
INSERT INTO documentos (nome, conteudo, hash_sha256)
VALUES (
    'arquivo.pdf',
    '\x...'::bytea,
    encode(digest('\x...'::bytea, 'sha256'), 'hex')
);

-- Verificar integridade
SELECT
    nome,
    hash_sha256 = encode(digest(conteudo, 'sha256'), 'hex') AS integro
FROM documentos;
```

### 7.4 Auditoria de Acesso a Arquivos

```sql
-- Tabela de auditoria
CREATE TABLE auditoria_arquivos (
    id          BIGSERIAL PRIMARY KEY,
    arquivo_id  INTEGER,
    operacao    TEXT,       -- 'INSERT', 'SELECT', 'DELETE', 'EXPORT'
    usuario     TEXT DEFAULT current_user,
    ip_cliente  INET DEFAULT inet_client_addr(),
    data_hora   TIMESTAMPTZ DEFAULT now(),
    detalhes    JSONB
);

-- Trigger de auditoria para INSERT/DELETE
CREATE OR REPLACE FUNCTION fn_auditar_arquivo()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria_arquivos (arquivo_id, operacao, detalhes)
    VALUES (
        CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END,
        TG_OP,
        jsonb_build_object(
            'nome', CASE WHEN TG_OP = 'DELETE' THEN OLD.nome ELSE NEW.nome END,
            'tamanho', CASE WHEN TG_OP = 'DELETE' THEN length(OLD.conteudo) ELSE length(NEW.conteudo) END
        )
    );
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_arquivos
    AFTER INSERT OR DELETE ON documentos
    FOR EACH ROW EXECUTE FUNCTION fn_auditar_arquivo();
```

---

## 8. Performance e Boas Práticas

### 8.1 Indexação e Busca

```sql
-- Índice no nome do arquivo (busca textual)
CREATE INDEX idx_documentos_nome ON documentos USING btree (nome);

-- Índice de texto completo no nome (buscas parciais)
CREATE INDEX idx_documentos_nome_trgm ON documentos
    USING gin (nome gin_trgm_ops);

-- Requer: CREATE EXTENSION pg_trgm;
SELECT * FROM documentos
WHERE nome ILIKE '%relatorio%';

-- Índice no hash para verificação de integridade rápida
CREATE INDEX idx_documentos_hash ON documentos (hash_sha256);

-- Verificar duplicatas por hash
SELECT hash_sha256, COUNT(*) AS qtd, array_agg(nome) AS arquivos
FROM documentos
GROUP BY hash_sha256
HAVING COUNT(*) > 1;
```

### 8.2 Particionamento para Grandes Volumes

```sql
-- Tabela particionada por data (útil para logs e uploads)
CREATE TABLE uploads (
    id          BIGSERIAL,
    nome        TEXT NOT NULL,
    conteudo    BYTEA,
    criado_em   TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (criado_em);

-- Criar partições por mês
CREATE TABLE uploads_2024_01
    PARTITION OF uploads
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE uploads_2024_02
    PARTITION OF uploads
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Particionar Large Objects por categoria (via tabela de metadados)
CREATE TABLE metadados_arquivos (
    id          BIGSERIAL,
    categoria   TEXT NOT NULL,  -- 'contratos', 'imagens', 'relatorios'
    oid_arquivo OID NOT NULL,
    nome        TEXT NOT NULL,
    criado_em   TIMESTAMPTZ DEFAULT now()
) PARTITION BY LIST (categoria);

CREATE TABLE metadados_contratos
    PARTITION OF metadados_arquivos
    FOR VALUES IN ('contratos');
```

### 8.3 Configurações de Memória e I/O

```sql
-- Verificar configurações relevantes
SHOW work_mem;           -- Memória por operação de sort/hash
SHOW shared_buffers;     -- Cache compartilhado
SHOW effective_cache_size; -- Estimativa do cache do OS

-- Para operações com muitos arquivos grandes, aumentar temporariamente:
SET work_mem = '256MB';

-- Configuração recomendada no postgresql.conf para workloads com arquivos:
-- shared_buffers = 25% da RAM
-- effective_cache_size = 75% da RAM
-- work_mem = 64MB (ajustar conforme conexões simultâneas)
-- maintenance_work_mem = 256MB
```

### 8.4 VACUUM e Manutenção

```sql
-- Large Objects excluídos deixam páginas mortas em pg_largeobject
-- O VACUUM limpa essas páginas

-- Verificar inchaço (bloat) em pg_largeobject
SELECT
    pg_size_pretty(pg_total_relation_size('pg_largeobject')) AS tamanho_total,
    pg_size_pretty(pg_relation_size('pg_largeobject')) AS tamanho_dados;

-- Executar VACUUM manualmente se necessário
VACUUM pg_largeobject;
VACUUM ANALYZE pg_largeobject;

-- Verificar Large Objects presentes no banco
SELECT count(*), pg_size_pretty(SUM(length(data))) AS tamanho_total
FROM pg_largeobject;
```

### 8.5 Estratégias de Chunking para Uploads Grandes

```sql
-- Para uploads muito grandes, usar Large Objects com chunking manual
-- garante que o processo pode ser retomado em caso de falha

CREATE TABLE uploads_em_andamento (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome_arquivo    TEXT NOT NULL,
    mime_type       TEXT NOT NULL,
    oid_destino     OID,
    total_bytes     BIGINT,
    bytes_recebidos BIGINT DEFAULT 0,
    status          TEXT DEFAULT 'iniciado',  -- iniciado, em_andamento, concluido, erro
    criado_em       TIMESTAMPTZ DEFAULT now(),
    atualizado_em   TIMESTAMPTZ DEFAULT now()
);

-- Função para iniciar um upload chunked
CREATE OR REPLACE FUNCTION fn_iniciar_upload(
    p_nome      TEXT,
    p_mime_type TEXT,
    p_total     BIGINT
)
RETURNS UUID AS $$
DECLARE
    v_id    UUID;
    v_oid   OID;
BEGIN
    v_oid := lo_create(0);

    INSERT INTO uploads_em_andamento (nome_arquivo, mime_type, oid_destino, total_bytes)
    VALUES (p_nome, p_mime_type, v_oid, p_total)
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Função para adicionar um chunk
CREATE OR REPLACE FUNCTION fn_adicionar_chunk(
    p_upload_id UUID,
    p_dados     BYTEA
)
RETURNS BIGINT AS $$
DECLARE
    v_rec   uploads_em_andamento%ROWTYPE;
    v_fd    INTEGER;
BEGIN
    SELECT * INTO v_rec FROM uploads_em_andamento WHERE id = p_upload_id FOR UPDATE;

    IF v_rec.status NOT IN ('iniciado', 'em_andamento') THEN
        RAISE EXCEPTION 'Upload % não está em andamento', p_upload_id;
    END IF;

    -- Abre o LO para escrita e posiciona no fim
    v_fd := lo_open(v_rec.oid_destino, 131072);  -- INV_WRITE
    PERFORM lo_lseek64(v_fd, 0, 2);              -- SEEK_END
    PERFORM lowrite(v_fd, p_dados);
    PERFORM lo_close(v_fd);

    -- Atualiza o progresso
    UPDATE uploads_em_andamento
    SET bytes_recebidos = bytes_recebidos + length(p_dados),
        status          = 'em_andamento',
        atualizado_em   = now()
    WHERE id = p_upload_id;

    RETURN (SELECT bytes_recebidos FROM uploads_em_andamento WHERE id = p_upload_id);
END;
$$ LANGUAGE plpgsql;
```

---

## 9. Integração com Aplicações

### 9.1 Python (psycopg2)

```python
import psycopg2
import psycopg2.extras

conn = psycopg2.connect("host=localhost dbname=meu_banco user=postgres")

# ----- BYTEA -----

# Upload de arquivo como BYTEA
with open("relatorio.pdf", "rb") as f:
    dados = f.read()

with conn.cursor() as cur:
    cur.execute(
        "INSERT INTO documentos (nome, mime_type, conteudo) VALUES (%s, %s, %s) RETURNING id",
        ("relatorio.pdf", "application/pdf", psycopg2.Binary(dados))
    )
    doc_id = cur.fetchone()[0]
    conn.commit()

# Download de arquivo BYTEA
with conn.cursor() as cur:
    cur.execute("SELECT nome, conteudo FROM documentos WHERE id = %s", (doc_id,))
    nome, conteudo = cur.fetchone()

with open(f"download_{nome}", "wb") as f:
    f.write(bytes(conteudo))

# ----- LARGE OBJECTS -----

# Upload usando Large Object (streaming)
lobj = conn.lobject(0, 'wb')  # Cria novo LO no modo escrita binária
oid = lobj.oid

with open("video_grande.mp4", "rb") as f:
    while chunk := f.read(65536):  # 64 KB por vez
        lobj.write(chunk)

lobj.close()

# Salvar referência na tabela
with conn.cursor() as cur:
    cur.execute(
        "INSERT INTO arquivos (nome, mime_type, oid_arquivo) VALUES (%s, %s, %s)",
        ("video_grande.mp4", "video/mp4", oid)
    )
    conn.commit()

# Download usando Large Object (streaming)
with conn.cursor() as cur:
    cur.execute("SELECT oid_arquivo FROM arquivos WHERE id = %s", (1,))
    oid = cur.fetchone()[0]

lobj = conn.lobject(oid, 'rb')

with open("download_video.mp4", "wb") as f:
    while chunk := lobj.read(65536):
        f.write(chunk)

lobj.close()
conn.close()
```

### 9.2 Node.js (pg / node-postgres)

```javascript
const { Pool } = require('pg');
const fs = require('fs');

const pool = new Pool({ connectionString: 'postgresql://postgres@localhost/meu_banco' });

// ----- BYTEA -----

async function uploadBytea(filePath, mimeType) {
    const dados = fs.readFileSync(filePath);
    const nome = filePath.split('/').pop();

    const { rows } = await pool.query(
        'INSERT INTO documentos (nome, mime_type, conteudo) VALUES ($1, $2, $3) RETURNING id',
        [nome, mimeType, dados]
    );
    return rows[0].id;
}

async function downloadBytea(id, destino) {
    const { rows } = await pool.query(
        'SELECT nome, conteudo FROM documentos WHERE id = $1',
        [id]
    );
    if (rows.length === 0) throw new Error('Arquivo não encontrado');
    fs.writeFileSync(destino, rows[0].conteudo);
    return rows[0].nome;
}

// ----- LARGE OBJECTS -----

async function uploadLargeObject(filePath, mimeType) {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Cria Large Object
        const { rows: [{ lo_create: oid }] } = await client.query('SELECT lo_create(0)');

        // Importa arquivo (funciona apenas no servidor)
        // Para importar do cliente, use lowrite em chunks
        const fd = (await client.query(`SELECT lo_open(${oid}, 131072)`)).rows[0].lo_open;

        const stream = fs.createReadStream(filePath, { highWaterMark: 65536 });
        for await (const chunk of stream) {
            await client.query('SELECT lowrite($1, $2)', [fd, chunk]);
        }

        await client.query('SELECT lo_close($1)', [fd]);

        const nome = filePath.split('/').pop();
        await client.query(
            'INSERT INTO arquivos (nome, mime_type, oid_arquivo) VALUES ($1, $2, $3)',
            [nome, mimeType, oid]
        );

        await client.query('COMMIT');
        return oid;
    } catch (err) {
        await client.query('ROLLBACK');
        throw err;
    } finally {
        client.release();
    }
}

// Servir arquivo via HTTP com streaming
async function servirArquivo(id, res) {
    const client = await pool.connect();
    try {
        const { rows } = await client.query(
            'SELECT nome, mime_type, oid_arquivo FROM arquivos WHERE id = $1',
            [id]
        );
        if (rows.length === 0) { res.status(404).end(); return; }

        const { nome, mime_type, oid_arquivo } = rows[0];

        await client.query('BEGIN');
        const fd = (await client.query(`SELECT lo_open(${oid_arquivo}, 262144)`)).rows[0].lo_open;

        res.setHeader('Content-Type', mime_type);
        res.setHeader('Content-Disposition', `attachment; filename="${nome}"`);

        let chunk;
        do {
            chunk = (await client.query('SELECT loread($1, 65536)', [fd])).rows[0].loread;
            if (chunk && chunk.length > 0) res.write(chunk);
        } while (chunk && chunk.length > 0);

        await client.query('SELECT lo_close($1)', [fd]);
        await client.query('COMMIT');
        res.end();
    } finally {
        client.release();
    }
}
```

### 9.3 Java (JDBC)

```java
import java.sql.*;
import java.io.*;
import org.postgresql.PGConnection;
import org.postgresql.largeobject.*;

// Upload de Large Object
public long uploadLargeObject(Connection conn, String filePath) throws Exception {
    conn.setAutoCommit(false); // LO requer transação

    PGConnection pgConn = conn.unwrap(PGConnection.class);
    LargeObjectManager lom = pgConn.getLargeObjectAPI();

    // Cria o LO
    long oid = lom.createLO(LargeObjectManager.WRITE);
    LargeObject lo = lom.open(oid, LargeObjectManager.WRITE);

    // Escreve em chunks
    try (FileInputStream fis = new FileInputStream(filePath)) {
        byte[] buffer = new byte[65536];
        int bytesRead;
        while ((bytesRead = fis.read(buffer)) != -1) {
            lo.write(buffer, 0, bytesRead);
        }
    }
    lo.close();
    conn.commit();
    return oid;
}

// Download de Large Object
public void downloadLargeObject(Connection conn, long oid, String destPath) throws Exception {
    conn.setAutoCommit(false);

    PGConnection pgConn = conn.unwrap(PGConnection.class);
    LargeObjectManager lom = pgConn.getLargeObjectAPI();

    LargeObject lo = lom.open(oid, LargeObjectManager.READ);

    try (FileOutputStream fos = new FileOutputStream(destPath)) {
        byte[] buffer = new byte[65536];
        int bytesRead;
        while ((bytesRead = lo.read(buffer, 0, buffer.length)) > 0) {
            fos.write(buffer, 0, bytesRead);
        }
    }
    lo.close();
    conn.commit();
}
```

---

## 10. Casos de Uso e Padrões de Projeto

### 10.1 Sistema de Gestão de Documentos (DMS)

```sql
-- Esquema completo para um DMS simples
CREATE TABLE categorias (
    id     SERIAL PRIMARY KEY,
    nome   TEXT NOT NULL UNIQUE,
    pai_id INTEGER REFERENCES categorias(id)
);

CREATE TABLE documentos_dms (
    id              BIGSERIAL PRIMARY KEY,
    titulo          TEXT NOT NULL,
    descricao       TEXT,
    categoria_id    INTEGER REFERENCES categorias(id),
    oid_conteudo    OID NOT NULL,
    mime_type       TEXT NOT NULL,
    tamanho_bytes   BIGINT,
    hash_sha256     TEXT,
    versao          INTEGER DEFAULT 1,
    documento_pai   BIGINT REFERENCES documentos_dms(id),  -- Para versionamento
    tags            TEXT[],
    metadados       JSONB,
    criado_por      TEXT DEFAULT current_user,
    criado_em       TIMESTAMPTZ DEFAULT now(),
    ativo           BOOLEAN DEFAULT true
);

-- View para busca full-text
CREATE INDEX idx_dms_titulo_fts ON documentos_dms
    USING gin (to_tsvector('portuguese', titulo || ' ' || coalesce(descricao, '')));

-- Buscar documentos
SELECT id, titulo, mime_type, tamanho_bytes, criado_em
FROM documentos_dms
WHERE to_tsvector('portuguese', titulo || ' ' || coalesce(descricao, ''))
      @@ plainto_tsquery('portuguese', 'relatório financeiro')
  AND ativo = true
ORDER BY criado_em DESC;
```

### 10.2 Sistema de Backup de Configurações

```sql
-- Versionar configurações de aplicação como arquivos
CREATE TABLE configuracoes_backup (
    id          BIGSERIAL PRIMARY KEY,
    aplicacao   TEXT NOT NULL,
    ambiente    TEXT NOT NULL,  -- 'prod', 'staging', 'dev'
    versao      TEXT NOT NULL,
    conteudo    BYTEA NOT NULL,  -- YAML/JSON/TOML da config
    autor       TEXT DEFAULT current_user,
    criado_em   TIMESTAMPTZ DEFAULT now(),
    ativo       BOOLEAN DEFAULT false
);

-- Ativar uma versão (desativa as outras do mesmo ambiente)
CREATE OR REPLACE FUNCTION fn_ativar_config(p_id BIGINT)
RETURNS VOID AS $$
DECLARE
    v_app  TEXT;
    v_env  TEXT;
BEGIN
    SELECT aplicacao, ambiente INTO v_app, v_env
    FROM configuracoes_backup WHERE id = p_id;

    UPDATE configuracoes_backup
    SET ativo = false
    WHERE aplicacao = v_app AND ambiente = v_env;

    UPDATE configuracoes_backup
    SET ativo = true
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
```

### 10.3 Padrão Híbrido: Banco + Object Storage

```sql
-- Tabela de metadados (banco) + referência a objeto externo (S3/MinIO)
CREATE TABLE arquivos_hibrido (
    id              BIGSERIAL PRIMARY KEY,
    nome            TEXT NOT NULL,
    mime_type       TEXT NOT NULL,
    tamanho_bytes   BIGINT,
    hash_sha256     TEXT,
    -- Referência ao objeto externo
    storage_bucket  TEXT,
    storage_key     TEXT,       -- Caminho no S3/MinIO
    storage_url     TEXT,       -- URL pré-assinada (temporária)
    url_expira_em   TIMESTAMPTZ,
    -- Fallback: arquivo pequeno inline
    conteudo_inline BYTEA,      -- Preenchido apenas se tamanho < 100KB
    criado_em       TIMESTAMPTZ DEFAULT now()
);

-- Função para obter URL de acesso (renovando se expirada)
CREATE OR REPLACE FUNCTION fn_url_arquivo(p_id BIGINT)
RETURNS TEXT AS $$
DECLARE
    v_rec arquivos_hibrido%ROWTYPE;
BEGIN
    SELECT * INTO v_rec FROM arquivos_hibrido WHERE id = p_id;

    -- Arquivo pequeno: retorna como data URL
    IF v_rec.conteudo_inline IS NOT NULL THEN
        RETURN 'data:' || v_rec.mime_type || ';base64,' ||
               encode(v_rec.conteudo_inline, 'base64');
    END IF;

    -- URL ainda válida: retorna diretamente
    IF v_rec.url_expira_em > now() + interval '5 minutes' THEN
        RETURN v_rec.storage_url;
    END IF;

    -- URL expirada: sinalizar para renovação na aplicação
    RETURN NULL;  -- Aplicação deve gerar nova URL pré-assinada
END;
$$ LANGUAGE plpgsql;
```

---

## 11. Exercícios Práticos

### Exercício 1 — BYTEA básico

Crie uma tabela `imagens_perfil` com colunas `id`, `usuario_id`, `dados` (BYTEA) e `mime_type`. Insira um arquivo PNG fictício usando representação hexadecimal e consulte seu tamanho em bytes.

<details>
<summary>Ver solução</summary>

```sql
CREATE TABLE imagens_perfil (
    id         SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    dados      BYTEA NOT NULL,
    mime_type  TEXT NOT NULL DEFAULT 'image/png'
);

-- Inserir PNG mínimo válido (header + IHDR + IEND)
INSERT INTO imagens_perfil (usuario_id, dados)
VALUES (1, '\x89504e470d0a1a0a0000000d4948445200000001000000010802000000907753de0000000c494441540893628001000000020001e221bc330000000049454e44ae426082'::bytea);

SELECT id, usuario_id, mime_type, length(dados) AS tamanho_bytes
FROM imagens_perfil;
```

</details>

---

### Exercício 2 — Large Object com Trigger

Crie uma tabela `contratos` que armazene contratos via Large Object. Implemente:
1. Trigger de limpeza ao deletar um contrato
2. Trigger de limpeza ao atualizar o OID do contrato
3. Query para listar todos os Large Objects órfãos

<details>
<summary>Ver solução</summary>

```sql
CREATE TABLE contratos (
    id          SERIAL PRIMARY KEY,
    titulo      TEXT NOT NULL,
    oid_arquivo OID,
    criado_em   TIMESTAMPTZ DEFAULT now()
);

CREATE OR REPLACE FUNCTION fn_limpar_lo_contrato()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' AND OLD.oid_arquivo IS NOT NULL THEN
        PERFORM lo_unlink(OLD.oid_arquivo);
    ELSIF TG_OP = 'UPDATE'
        AND OLD.oid_arquivo IS NOT NULL
        AND OLD.oid_arquivo IS DISTINCT FROM NEW.oid_arquivo THEN
        PERFORM lo_unlink(OLD.oid_arquivo);
    END IF;
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lo_contrato
    BEFORE DELETE OR UPDATE OF oid_arquivo ON contratos
    FOR EACH ROW EXECUTE FUNCTION fn_limpar_lo_contrato();

-- Large Objects órfãos
SELECT loid
FROM pg_largeobject_metadata
WHERE loid NOT IN (
    SELECT oid_arquivo FROM contratos WHERE oid_arquivo IS NOT NULL
);
```

</details>

---

### Exercício 3 — COPY e file_fdw

Configure o `file_fdw` para ler um arquivo CSV de produtos e crie uma view que une os dados externos com uma tabela local de categorias.

<details>
<summary>Ver solução</summary>

```sql
-- Arquivo: /var/data/produtos.csv
-- id,nome,preco,categoria_id
-- 1,Notebook,3500.00,1
-- 2,Mouse,120.00,1

CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER srv_arquivos FOREIGN DATA WRAPPER file_fdw;

CREATE FOREIGN TABLE produtos_externos (
    id           INTEGER,
    nome         TEXT,
    preco        NUMERIC(10,2),
    categoria_id INTEGER
)
SERVER srv_arquivos
OPTIONS (filename '/var/data/produtos.csv', format 'csv', header 'true');

CREATE TABLE categorias_local (
    id   SERIAL PRIMARY KEY,
    nome TEXT NOT NULL
);

INSERT INTO categorias_local VALUES (1, 'Informática'), (2, 'Periféricos');

CREATE VIEW v_produtos_completos AS
SELECT
    p.id,
    p.nome,
    p.preco,
    c.nome AS categoria
FROM produtos_externos p
LEFT JOIN categorias_local c ON c.id = p.categoria_id;

SELECT * FROM v_produtos_completos;
```

</details>

---

### Exercício 4 — Criptografia com pgcrypto

Armazene um documento PDF criptografado com AES-256 e implemente funções para salvar e recuperar o conteúdo de forma transparente.

<details>
<summary>Ver solução</summary>

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE documentos_seguros (
    id          SERIAL PRIMARY KEY,
    nome        TEXT NOT NULL,
    conteudo    BYTEA NOT NULL,  -- Sempre criptografado
    criado_em   TIMESTAMPTZ DEFAULT now()
);

CREATE OR REPLACE FUNCTION fn_salvar_documento_seguro(
    p_nome    TEXT,
    p_dados   BYTEA,
    p_senha   TEXT
)
RETURNS INTEGER AS $$
DECLARE v_id INTEGER;
BEGIN
    INSERT INTO documentos_seguros (nome, conteudo)
    VALUES (p_nome, pgp_sym_encrypt_bytea(p_dados, p_senha, 'cipher-algo=aes256'))
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fn_ler_documento_seguro(
    p_id    INTEGER,
    p_senha TEXT
)
RETURNS BYTEA AS $$
BEGIN
    RETURN (
        SELECT pgp_sym_decrypt_bytea(conteudo, p_senha)
        FROM documentos_seguros WHERE id = p_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Uso
SELECT fn_salvar_documento_seguro('secreto.pdf', '\x2550444600'::bytea, 'minha_senha_forte');
SELECT fn_ler_documento_seguro(1, 'minha_senha_forte');
```

</details>

---

## 12. Referências e Leitura Complementar

### Documentação Oficial

- [PostgreSQL — Binary Data Types (BYTEA)](https://www.postgresql.org/docs/current/datatype-binary.html)
- [PostgreSQL — Large Objects](https://www.postgresql.org/docs/current/largeobjects.html)
- [PostgreSQL — Server File Access Functions](https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADMIN-GENFILE)
- [PostgreSQL — COPY Command](https://www.postgresql.org/docs/current/sql-copy.html)
- [PostgreSQL — file_fdw](https://www.postgresql.org/docs/current/file-fdw.html)
- [PostgreSQL — pgcrypto](https://www.postgresql.org/docs/current/pgcrypto.html)
- [PostgreSQL — TOAST](https://www.postgresql.org/docs/current/storage-toast.html)

### Ferramentas e Extensões Relacionadas

| Ferramenta | Descrição | Link |
|---|---|---|
| `pgcrypto` | Funções criptográficas | Inclusa no contrib |
| `pg_trgm` | Busca por similaridade em texto | Inclusa no contrib |
| `lo` | Gerenciamento de Large Objects | Inclusa no contrib |
| `file_fdw` | Foreign Data Wrapper para arquivos | Inclusa no contrib |
| MinIO | Object Storage S3-compatível | minio.io |
| pgBackRest | Backup com suporte a Large Objects | pgbackrest.org |

### Resumo de Funções por Categoria

```
BYTEA
  length(bytea)                     → tamanho em bytes
  substring(bytea FROM x FOR n)     → extrai subsequência
  overlay(bytea PLACING bytea ...)  → substituição de bytes
  encode(bytea, formato)            → converte para hex/base64/escape
  decode(text, formato)             → converte de hex/base64/escape
  get_byte / set_byte               → leitura/escrita de byte individual

LARGE OBJECTS (alto nível)
  lo_create(oid)   → cria LO
  lo_import(path)  → importa arquivo do servidor
  lo_export(oid, path) → exporta para o servidor
  lo_unlink(oid)   → exclui LO

LARGE OBJECTS (baixo nível)
  lo_open(oid, mode) → abre e retorna fd
  lo_close(fd)       → fecha fd
  loread(fd, n)      → lê n bytes
  lowrite(fd, data)  → escreve bytes
  lo_lseek(fd, offset, whence) → move ponteiro (32-bit)
  lo_lseek64(...)  → move ponteiro (64-bit, arquivos > 2GB)
  lo_tell(fd)      → posição atual
  lo_truncate(fd, n) → trunca para n bytes

SISTEMA DE ARQUIVOS (servidor)
  pg_read_file(path [, offset, len]) → lê arquivo de texto
  pg_read_binary_file(path ...)      → lê arquivo binário
  pg_stat_file(path)                 → metadados do arquivo
  pg_ls_dir(dir)                     → lista diretório
  pg_ls_waldir()                     → lista diretório WAL
  pg_ls_logdir()                     → lista diretório de logs
```

---

> 📝 **Nota Final:** Embora o PostgreSQL ofereça mecanismos robustos para armazenar arquivos, avalie sempre se um **Object Storage externo** (Amazon S3, MinIO, Google Cloud Storage) não seria mais adequado para volumes muito grandes (>100 GB) ou acesso concorrente intenso. O padrão híbrido — metadados no banco, binários no object storage — costuma ser a melhor escolha para sistemas em produção de alta escala.