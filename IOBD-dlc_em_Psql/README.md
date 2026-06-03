# ## ✅ **O que é DCL (Data Control Language)?**

DCL (Data Control Language) é um subconjunto da SQL responsável **por controlar os acessos dos usuários ao banco de dados** — ou seja, quem pode ver, alterar, ou gerenciar quais objetos (tabelas, views, schemas, funções etc.).

No PostgreSQL, os principais comandos DCL são:

* **`GRANT`** – para conceder permissões
* **`REVOKE`** – para remover permissões

---

## 🔑 **Permissões comuns no PostgreSQL**

Essas permissões podem ser aplicadas em diferentes objetos do banco:

| Permissão | Explicação                                                       |
| --------- | ---------------------------------------------------------------- |
| `SELECT`  | Permite ler dados (fazer SELECT)                                 |
| `INSERT`  | Permite inserir dados (fazer INSERT)                             |
| `UPDATE`  | Permite alterar dados existentes                                 |
| `DELETE`  | Permite excluir dados                                            |
| `USAGE`   | Permite usar um schema ou uma função                             |
| `EXECUTE` | Permite executar funções/procedures                              |
| `ALL`     | Atalho para todas as permissões relevantes daquele objeto        |
| `CONNECT` | Permite conectar-se ao banco de dados                            |
| `TEMP`    | Permite criar tabelas temporárias no banco                       |
| `CREATE`  | Permite criar objetos dentro de um schema (ex: tabelas, funções) |

---

### 🛡️ **Comandos DCL no PostgreSQL**

1. **`GRANT`** – Concede permissões a usuários ou roles.
2. **`REVOKE`** – Remove permissões concedidas anteriormente.

---

### 🔐 **Exemplos de uso no PostgreSQL**

#### 1. Criar um usuário

```sql
CREATE USER joao WITH PASSWORD 'senha123';
```

#### 2. Conceder permissões

```sql
-- Concede acesso de leitura a uma tabela
GRANT SELECT ON tabela_exemplo TO joao;

-- Concede acesso total (leitura, escrita e execução)
GRANT ALL PRIVILEGES ON DATABASE minha_base TO joao;
```

#### 3. Revogar permissões

```sql
REVOKE SELECT ON tabela_exemplo FROM joao;
```

#### 4. Conceder uso de schema

```sql
GRANT USAGE ON SCHEMA public TO joao;
```

#### 5. Tornar um usuário um superusuário (com muito cuidado!)

```sql
ALTER USER joao WITH SUPERUSER;
```

---

### 🎯 Dicas Importantes

* Use roles (grupos de permissões) para facilitar a gestão de acessos.
* Verifique permissões com:

```sql
\z tabela_exemplo
```

no terminal `psql`.

* As permissões são acumulativas: o que for concedido a uma role será herdado por todos os usuários pertencentes a ela.

---


## 📚 **Exemplos Práticos**

### 🎯 1. Criar um usuário

```sql
CREATE USER ana WITH PASSWORD 'senha123';
```

> Isso cria um novo usuário chamado `ana`. Por padrão, ele não tem permissão para nada ainda.

---

### 🔓 2. Conceder permissão para ler uma tabela

```sql
GRANT SELECT ON tabela_clientes TO ana;
```

> Agora `ana` pode fazer `SELECT` na tabela `tabela_clientes`.

---

### ✏️ 3. Permitir leitura e escrita

```sql
GRANT SELECT, INSERT, UPDATE ON tabela_clientes TO ana;
```

> Isso permite que `ana` leia, insira e edite dados da tabela.

---

### ❌ 4. Revogar permissão

```sql
REVOKE INSERT ON tabela_clientes FROM ana;
```

> Remove a permissão de inserção.

---

### 📦 5. Permissões em nível de banco

```sql
GRANT CONNECT ON DATABASE vendas TO ana;
```

> Sem isso, `ana` não consegue nem conectar no banco de dados `vendas`.

---

### 🧱 6. Permissões em schemas

```sql
GRANT USAGE ON SCHEMA public TO ana;
```

> Permite que `ana` use objetos dentro do schema `public`.

---

### 🧑‍🤝‍🧑 7. Usando Roles (grupos de permissões)

#### Criar uma role:

```sql
CREATE ROLE somente_leitura;
GRANT CONNECT ON DATABASE vendas TO somente_leitura;
GRANT USAGE ON SCHEMA public TO somente_leitura;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO somente_leitura;
```

#### Atribuir essa role a um usuário:

```sql
GRANT somente_leitura TO ana;
```

> Agora `ana` herda as permissões da role `somente_leitura`.

---

## 🧠 Boas Práticas

* **Use roles para agrupar permissões**: assim você evita conceder uma por uma a cada usuário.
* **Conceda o mínimo necessário**: siga o princípio do menor privilégio.
* **Audite permissões**: veja o que está concedido com:

```sql
\z tabela_clientes
```

ou via consulta:

```sql
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_name = 'tabela_clientes';
```

--- 

### Dica

**Se uma coluna é `SERIAL` (ou `BIGSERIAL`)**, o PostgreSQL **cria automaticamente uma sequência associada** a essa coluna, e o **usuário que for fazer `INSERT` na tabela precisa ter permissão de uso nessa sequência**.

### 🔍 Por quê?

Quando você insere um registro em uma tabela com uma coluna `SERIAL`, o PostgreSQL usa a função `nextval('nome_da_sequencia')` para gerar automaticamente o próximo valor. Para isso, o usuário precisa de:

* `USAGE` na sequência — para poder usá-la;
* `SELECT` na sequência — para ler o valor atual (opcional, mas necessário em alguns casos, como `currval()` ou `nextval()`).

---

### ✅ Exemplo prático

Vamos dizer que você tem esta tabela:

```sql
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome TEXT
);
```

O PostgreSQL cria uma sequência oculta, normalmente com o nome:

```text
clientes_id_seq
```

Se o usuário `joao` for inserir dados nessa tabela, você precisa conceder permissões assim:

```sql
-- Permitir inserir na tabela
GRANT INSERT ON clientes TO joao;

-- Permitir uso da sequência associada
GRANT USAGE, SELECT ON SEQUENCE clientes_id_seq TO joao;
```

---

### ⚠️ Observação

Se você omitir a permissão na sequência, o `INSERT` vai falhar com um erro do tipo:

```text
ERROR: permission denied for sequence clientes_id_seq
```

---

Para descobrir o **nome da sequência criada automaticamente por uma coluna `SERIAL`** no PostgreSQL, você pode usar as seguintes abordagens:

---

### ✅ 1. **Usar `pg_get_serial_sequence()` (forma mais direta)**

Essa função retorna o nome da sequência associada a uma coluna `SERIAL`:

```sql
SELECT pg_get_serial_sequence('clientes', 'id');
```

**Exemplo de saída:**

```text
clientes_id_seq
```

---

### ✅ 2. **Consultar via `information_schema.columns`**

Se quiser procurar em várias tabelas/colunas, pode usar:

```sql
SELECT table_name, column_name, column_default
FROM information_schema.columns
WHERE column_default LIKE 'nextval(%'
  AND table_schema = 'public';
```

Isso mostra todas as colunas que usam `nextval()`, ou seja, associadas a uma sequência.

---

### ✅ 3. **Usar JOIN com `pg_class` e `pg_attrdef` (avançado)**

Se você quiser um SQL mais completo que liga tudo, aqui está:

```sql
SELECT
    t.relname AS tabela,
    a.attname AS coluna,
    d.adsrc   AS default,
    s.relname AS sequencia
FROM pg_class t
JOIN pg_attribute a ON a.attrelid = t.oid
JOIN pg_attrdef d  ON d.adrelid = t.oid AND d.adnum = a.attnum
JOIN pg_class s ON d.adsrc LIKE 'nextval(%' || s.relname || '%)'
WHERE t.relkind = 'r'
  AND d.adsrc LIKE 'nextval(%';
```

---

## 📦 **Cenário: Sistema de Vendas**

### Tabelas principais:

* `clientes`
* `pedidos`
* `produtos`

### Tipos de usuários:

1. **admin\_vendas** – Acesso total ao banco
2. **escritor\_vendas** – Pode inserir e editar dados, mas não pode apagar ou criar objetos
3. **leitor\_vendas** – Pode apenas consultar os dados

---

## 🧑‍🤝‍🧑 **Etapas: Criação de Roles e Permissões**

### 🔹 1. Criar as roles

```sql
-- Acesso completo (para administradores)
CREATE ROLE admin_vendas;

-- Pode ler e escrever, mas não apagar
CREATE ROLE escritor_vendas;

-- Só leitura
CREATE ROLE leitor_vendas;
```

---

### 🔹 2. Criar usuários e atribuir roles

```sql
-- Criando usuários
CREATE USER maria WITH PASSWORD 'senha123';
CREATE USER joao WITH PASSWORD 'senha123';
CREATE USER ana WITH PASSWORD 'senha123';

-- Atribuindo roles
GRANT admin_vendas TO maria;
GRANT escritor_vendas TO joao;
GRANT leitor_vendas TO ana;
```

---

### 🔹 3. Conceder permissões no banco e schema

```sql
-- Permitir conexão ao banco de dados para todos os tipos
GRANT CONNECT ON DATABASE sistema_vendas TO admin_vendas, escritor_vendas, leitor_vendas;

-- Permitir uso do schema
GRANT USAGE ON SCHEMA public TO admin_vendas, escritor_vendas, leitor_vendas;
```

---

### 🔹 4. Conceder permissões nas tabelas

#### Para admin:

```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_vendas;
```

#### Para escritor:

```sql
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO escritor_vendas;
```

#### Para leitor:

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO leitor_vendas;
```

---

### 🔹 5. Permissões em futuras tabelas (IMPORTANTE)

Quando novas tabelas forem criadas, as permissões anteriores **não são herdadas automaticamente**. Use isso para garantir isso no futuro:

```sql
-- Permitir acesso automático a novas tabelas
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO leitor_vendas;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE ON TABLES TO escritor_vendas;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES TO admin_vendas;
```

---

## ✅ Resumo final:

| Usuário | Papel             | Acessos                                    |
| ------- | ----------------- | ------------------------------------------ |
| maria   | `admin_vendas`    | Total: leitura, escrita, exclusão, criação |
| joao    | `escritor_vendas` | Leitura e escrita (sem DELETE ou criação)  |
| ana     | `leitor_vendas`   | Apenas leitura                             |


---


## ✅ Exemplo: DCL em Java com JDBC

### 🔐 Exemplo: conceder `INSERT` e uso da sequência a um usuário

```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class GrantPermissionExample {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/seu_banco";
        String user = "admin";
        String password = "sua_senha";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {

            // Exemplo de comandos DCL
            String grantInsert = "GRANT INSERT ON clientes TO joao;";
            String grantSequence = "GRANT USAGE, SELECT ON SEQUENCE clientes_id_seq TO joao;";

            // Executa os comandos
            stmt.executeUpdate(grantInsert);
            stmt.executeUpdate(grantSequence);

            System.out.println("Permissões concedidas com sucesso.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

---

### ⚠️ Dicas importantes:

* Você precisa estar conectado com um usuário que **tenha privilégios de administração**, como `postgres` ou outro com `GRANT` permission.
* Comandos DCL **não são transacionais** na maioria dos SGBDs — ou seja, mesmo que você envolva em uma transação, eles não são desfeitos com `rollback`.

---

# ✅ **Criar um dump**

### **1. Dump de um banco específico (formato SQL)**

```bash
pg_dump -U usuario -h host -d nome_do_banco > backup.sql
```

### **2. Dump em formato customizado (recomendado)**

Permite restaurar objetos individualmente:

```bash
pg_dump -U usuario -h host -d nome_do_banco -F c -f backup.dump
```

### **3. Dump de todos os bancos**

```bash
pg_dumpall -U usuario > backup_completo.sql
```

---

# ✅ **Restaurar um dump**

## **A) Restaurar dump em formato SQL**

```bash
psql -U usuario -h host -d nome_do_banco < backup.sql
```

> Obs.: O banco precisa existir antes da restauração.

Criar o banco, se necessário:

```bash
createdb -U usuario nome_do_banco
```

---

## **B) Restaurar dump em formato customizado (.dump ou .backup)**

Usa o `pg_restore`:

```bash
pg_restore -U usuario -h host -d nome_do_banco backup.dump
```

Se quiser que ele drope e recrie objetos:

```bash
pg_restore -U usuario -h host -d nome_do_banco --clean --create backup.dump
```

---

# 🔐 **Dicas úteis**

### Especificar a porta

```bash
-p 5432
```

### Forçar sobrescrita de objetos

```bash
--clean
```

### Ver conteúdo do dump

```bash
pg_restore --list backup.dump
```