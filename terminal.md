# PostgreSQL psql Command Guide (Terminal)

Guia prático de **comandos essenciais do `psql`** usados no dia a dia por desenvolvedores backend.
Inclui paralelos com **Windows (CMD/PowerShell)** e **Linux/Mac (Bash/Zsh)** para facilitar o entendimento de quem trabalha frequentemente com terminal.

---

# 📚 Sumário

* Sobre o `psql`
* Como conectar ao PostgreSQL
* Comandos básicos de navegação
* Inspeção de bancos e tabelas
* Gerenciamento de usuários
* Execução de scripts SQL
* Histórico e edição de comandos
* Integração com o sistema operacional
* Exportação de resultados
* Tabela comparativa Windows vs Linux
* Fluxo real de uso de um backend

---

# 🧠 Sobre o `psql`

`psql` é o **cliente de linha de comando oficial do PostgreSQL**.
Ele permite:

* executar consultas SQL
* gerenciar bancos
* inspecionar tabelas
* executar scripts
* automatizar tarefas

Os comandos especiais do `psql` são chamados de **meta-comandos** e sempre começam com:

```
\
```

Exemplo:

```
\dt
\d usuarios
\l
```

---

# 🔌 Conectando ao PostgreSQL

### Conectar a um banco

```bash
psql -U usuario -d banco
```

Exemplo:

```bash
psql -U postgres -d postgres
```

### Conectar especificando host e porta

```bash
psql -U postgres -h localhost -p 5432
```

---

# 📂 Comandos básicos de navegação

### Listar todos os bancos

```
\l
```

ou

```
\list
```

---

### Conectar a outro banco

```
\c nome_do_banco
```

Exemplo:

```
\c loja
```

---

# 📦 Inspeção de tabelas

### Listar tabelas do banco atual

```
\dt
```

---

### Listar tabelas de todos os schemas

```
\dt *.*
```

---

### Ver estrutura de uma tabela

```
\d tabela
```

Exemplo:

```
\d usuarios
```

Mostra:

* colunas
* tipos
* chaves primárias
* índices
* constraints

---

### Ver detalhes completos de uma tabela

```
\d+ tabela
```

Exemplo:

```
\d+ usuarios
```

Mostra informações adicionais como:

* tamanho
* storage
* comentários

---

### Listar todas as relações do banco

```
\d
```

Inclui:

* tabelas
* views
* sequências

---

# 📊 Inspecionando objetos do banco

### Listar índices

```
\di
```

---

### Listar views

```
\dv
```

---

### Listar sequências

```
\ds
```

Sequências são usadas por campos como:

```
SERIAL
BIGSERIAL
```

---

# 👤 Gerenciamento de usuários

No PostgreSQL usuários são chamados de **roles**.

### Listar usuários

```
\du
```

Mostra:

* roles
* permissões
* superuser
* criação de banco

---

# 📜 Histórico de comandos

### Mostrar histórico

```
\s
```

Isso mostra todas as queries executadas na sessão.

---

# ✏️ Editar query em editor externo

```
\e
```

Isso abre o editor padrão do sistema:

Linux normalmente abre:

```
vim
```

Windows geralmente abre:

```
notepad
```

---

# 📂 Executar scripts SQL

### Executar arquivo SQL

```
\i arquivo.sql
```

Exemplo:

```
\i schema.sql
```

Muito usado em:

* migrations
* criação de schema
* seed de banco

---

# 🧾 Exportar resultado de query

### Enviar saída para arquivo

```
\o arquivo.txt
```

Depois execute uma query:

```
SELECT * FROM usuarios;
```

A saída será salva no arquivo.

Para voltar ao terminal:

```
\o
```

---

# 💻 Executar comandos do sistema

O `psql` permite executar comandos do sistema operacional.

Prefixo:

```
\!
```

---

## Windows

### Limpar terminal

```
\! cls
```

### Listar arquivos

```
\! dir
```

---

## Linux / Mac

### Limpar terminal

```
\! clear
```

### Listar arquivos

```
\! ls
```

---

# ❓ Ajuda dentro do psql

### Mostrar todos os comandos do psql

```
\?
```

---

### Ajuda de comandos SQL

```
\h
```

Exemplo:

```
\h SELECT
```

---

# 🚪 Sair do psql

```
\q
```

---

# 🖥️ Comparação Terminal vs psql

| Ação                     | psql       | Linux            | Windows           |
| ------------------------ | ---------- | ---------------- | ----------------- |
| listar bancos            | `\l`       | `ls`             | `dir`             |
| limpar tela              | `\! clear` | `clear`          | `cls`             |
| histórico                | `\s`       | `history`        | `doskey /history` |
| executar script          | `\i`       | `bash script.sh` | `.bat`            |
| executar comando sistema | `\!`       | shell            | cmd               |

---

# 🚀 Fluxo real de trabalho (Backend)

Um desenvolvedor backend normalmente faz algo assim:

### 1️⃣ conectar no banco

```
psql -U postgres
```

### 2️⃣ listar bancos

```
\l
```

### 3️⃣ conectar ao banco do projeto

```
\c projeto
```

### 4️⃣ ver tabelas

```
\dt
```

### 5️⃣ inspecionar tabela

```
\d usuarios
```

### 6️⃣ executar consulta

```
SELECT * FROM usuarios LIMIT 10;
```

---

# 🎯 Dicas de produtividade

### Limitar resultados

```
SELECT * FROM usuarios LIMIT 10;
```

---

### Ver apenas parte das colunas

```
SELECT id, nome FROM usuarios;
```

---

### Contar registros

```
SELECT COUNT(*) FROM usuarios;
```

---

# 📌 Conclusão

O `psql` é uma ferramenta extremamente poderosa para trabalhar diretamente com PostgreSQL.

Dominar esses comandos permite:

* debugar bancos rapidamente
* analisar dados
* testar queries
* entender schemas
* administrar sistemas backend

Essas habilidades são essenciais para desenvolvedores que trabalham com:

* APIs
* microsserviços
* sistemas distribuídos
* engenharia de dados
* DevOps

---

**Autor:** Lucas Oliveira
**Área:** Backend / Engenharia de Software
