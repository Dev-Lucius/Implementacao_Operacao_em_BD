# UUID no PostgreSQL

## Visão Geral

O **UUID (Universally Unique Identifier)** é um identificador de 128 bits projetado para ser único em praticamente qualquer contexto computacional. Sua principal finalidade é permitir a identificação de registros sem depender de sequências numéricas centralizadas.

No PostgreSQL, o tipo de dado `UUID` é amplamente utilizado em aplicações modernas, especialmente em:

* Sistemas distribuídos;
* Microsserviços;
* Aplicações em nuvem;
* Sistemas que exigem alta escalabilidade;
* Bancos de dados replicados.

Ao contrário de chaves numéricas sequenciais (`SERIAL` ou `BIGSERIAL`), os UUIDs podem ser gerados independentemente por diferentes servidores sem risco prático de colisão.

---

# Objetivos de Aprendizagem

Ao estudar este conteúdo, você será capaz de:

* Entender o conceito de UUID.
* Diferenciar UUID de identificadores sequenciais.
* Compreender quando utilizar UUID em bancos de dados.
* Criar tabelas utilizando UUID como chave primária.
* Gerar UUIDs automaticamente no PostgreSQL.
* Avaliar vantagens e desvantagens do uso de UUIDs.

---

# Conceitos Fundamentais

## O que é um UUID?

UUID significa **Universally Unique Identifier** (Identificador Universalmente Único).

Ele é definido pela RFC 4122 e outras especificações relacionadas.

Um UUID possui:

* 128 bits de tamanho;
* Representação textual de 36 caracteres;
* 32 dígitos hexadecimais;
* 4 hífens separando grupos de caracteres.

### Exemplo

```text
40e6215d-b5c6-4896-987c-f30f3678f608
6ecd8c99-4036-403d-bf84-cf8400f67836
3f333df6-90a4-4fda-8dd3-9485d27cee36
```

---

## Estrutura de um UUID

```text
xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
```

Onde:

| Campo | Descrição          |
| ----- | ------------------ |
| x     | Dígito hexadecimal |
| M     | Versão do UUID     |
| N     | Variante utilizada |

Exemplo:

```text
d6eb621f-6dd0-4cdc-93f5-07f51b249b51
```

Neste UUID:

* O primeiro grupo identifica parte dos dados gerados.
* O dígito `4` indica que é um UUID versão 4.
* A versão 4 utiliza números aleatórios para geração.

---

## 💡 Entenda o Conceito: Por que UUID existe?

Imagine uma empresa com diversos servidores inserindo registros simultaneamente.

Se cada servidor utilizar:

```sql
SERIAL
```

poderá ocorrer conflito ao integrar os dados posteriormente.

Por exemplo:

Servidor A:

```text
ID = 1
ID = 2
ID = 3
```

Servidor B:

```text
ID = 1
ID = 2
ID = 3
```

Ao unir os bancos, surgem colisões.

Com UUID:

Servidor A:

```text
ca61da8c-938a-48a6-8eb6-55aa08cd1b08
```

Servidor B:

```text
b0f5c66c-3c7e-4d6c-aea2-9d0d50b8a741
```

As chances de repetição tornam-se extremamente pequenas.

---

# UUID vs SERIAL

| Característica        | UUID      | SERIAL   |
| --------------------- | --------- | -------- |
| Tamanho               | 128 bits  | 32 bits  |
| Geração distribuída   | Sim       | Não      |
| Legibilidade humana   | Baixa     | Alta     |
| Segurança             | Maior     | Menor    |
| Escalabilidade        | Excelente | Limitada |
| Ordenação natural     | Não       | Sim      |
| Performance de índice | Menor     | Melhor   |

---

# Quando Utilizar UUID?

### Cenários recomendados

✅ Sistemas distribuídos

✅ Microsserviços

✅ APIs públicas

✅ Aplicações SaaS

✅ Bancos replicados

✅ Sistemas multi-tenant

---

### Cenários onde SERIAL pode ser suficiente

✅ Aplicações pequenas

✅ Sistemas internos

✅ Bancos únicos sem replicação

✅ Projetos acadêmicos simples

---

# Tipo de Dado UUID no PostgreSQL

O PostgreSQL possui suporte nativo ao tipo:

```sql
UUID
```

Exemplo:

```sql
CREATE TABLE exemplo (
    id UUID PRIMARY KEY
);
```

---

# Gerando UUIDs

## Função gen_random_uuid()

O PostgreSQL fornece a função:

```sql
gen_random_uuid()
```

Ela gera um UUID versão 4 baseado em números aleatórios.

### Exemplo

```sql
SELECT gen_random_uuid();
```

Saída:

```text
d6eb621f-6dd0-4cdc-93f5-07f51b249b51
```

---

## Como Funciona?

Fluxo simplificado:

```mermaid
flowchart LR

A[Solicitação de UUID]
--> B[gen_random_uuid()]
--> C[Geração Aleatória]
--> D[UUID v4]
```

---

# Criando uma Tabela com UUID

## Estrutura da Tabela

```sql
CREATE TABLE contacts (
    contact_id UUID DEFAULT gen_random_uuid(),
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    phone VARCHAR,
    PRIMARY KEY (contact_id)
);
```

---

## Análise da Estrutura

| Coluna     | Tipo    | Função              |
| ---------- | ------- | ------------------- |
| contact_id | UUID    | Identificador único |
| first_name | VARCHAR | Nome                |
| last_name  | VARCHAR | Sobrenome           |
| email      | VARCHAR | E-mail              |
| phone      | VARCHAR | Telefone            |

---

## 💡 Entenda o Conceito

A coluna:

```sql
contact_id UUID DEFAULT gen_random_uuid()
```

define que:

1. O campo utiliza UUID.
2. Caso nenhum valor seja informado, o PostgreSQL gera automaticamente um UUID.

Portanto:

```sql
INSERT INTO contacts (...)
```

não precisa informar o identificador manualmente.

---

# Inserindo Dados

```sql
INSERT INTO contacts (
    first_name,
    last_name,
    email,
    phone
)
VALUES
('John', 'Smith', 'john.smith@example.com', '408-237-2345'),
('Jane', 'Smith', 'jane.smith@example.com', '408-237-2344'),
('Alex', 'Smith', 'alex.smith@example.com', '408-237-2343')
RETURNING *;
```

---

# Resultado

```text
contact_id                            | first_name | last_name | email                  | phone
--------------------------------------+------------+-----------+------------------------+--------------
ca61da8c-938a-48a6-8eb6-55aa08cd1b08 | John       | Smith     | john.smith@example.com | 408-237-2345
fe2af584-8576-4d0e-b10d-6ec970732f8e | Jane       | Smith     | jane.smith@example.com | 408-237-2344
141aefe8-f553-43b9-bfbf-91361e83b15e | Alex       | Smith     | alex.smith@example.com | 408-237-2343
```

Observe que os valores da coluna `contact_id` foram gerados automaticamente.

---

# Vantagens do UUID

## Escalabilidade

Permite múltiplos servidores gerando IDs simultaneamente.

---

## Segurança

Dificulta ataques de enumeração.

Exemplo com SERIAL:

```text
/api/users/1
/api/users/2
/api/users/3
```

O atacante consegue prever IDs.

Com UUID:

```text
/api/users/ca61da8c-938a-48a6-8eb6-55aa08cd1b08
```

A previsão torna-se praticamente inviável.

---

## Independência de Banco

Permite sincronizar dados entre bancos sem colisão de chaves.

---

# Desvantagens do UUID

## Maior Consumo de Espaço

| Tipo    | Espaço   |
| ------- | -------- |
| INTEGER | 4 bytes  |
| BIGINT  | 8 bytes  |
| UUID    | 16 bytes |

---

## Índices Maiores

Os índices ocupam mais memória.

---

## Menor Legibilidade

Comparação:

```text
ID: 15
```

vs

```text
ca61da8c-938a-48a6-8eb6-55aa08cd1b08
```

---

# Boas Práticas

### Utilize UUID para:

* Sistemas distribuídos;
* Microsserviços;
* APIs públicas.

### Utilize SERIAL/BIGSERIAL para:

* Sistemas pequenos;
* Aplicações internas;
* Ambientes de teste.

### Combine UUID com índices adequados

```sql
CREATE INDEX idx_contacts_email
ON contacts(email);
```

---

# Possíveis Melhorias

## Técnicas

* Utilizar UUID v7 quando disponível.
* Adicionar restrições UNIQUE para e-mail.
* Implementar auditoria de alterações.

Exemplo:

```sql
ALTER TABLE contacts
ADD CONSTRAINT uq_contacts_email UNIQUE(email);
```

---

# Perguntas para Fixação

## Básico

1. O que significa UUID?
2. Quantos bits possui um UUID?
3. Qual função gera UUID no PostgreSQL?

## Intermediário

1. Qual a diferença entre UUID e SERIAL?
2. Por que UUID é útil em sistemas distribuídos?
3. O que faz a cláusula DEFAULT?

## Avançado

1. Como UUID afeta a performance de índices?
2. Quando UUID pode ser uma escolha inadequada?
3. Quais problemas UUID resolve em arquiteturas distribuídas?

---

# Resumo Executivo

O UUID é um identificador universal de 128 bits utilizado para garantir unicidade global dos registros. No PostgreSQL, ele pode ser armazenado através do tipo `UUID` e gerado automaticamente pela função `gen_random_uuid()`.

Embora consuma mais espaço que identificadores sequenciais como `SERIAL`, o UUID oferece vantagens significativas em sistemas distribuídos, aplicações escaláveis e ambientes que exigem sincronização entre múltiplas bases de dados. Por esse motivo, tornou-se uma prática comum em arquiteturas modernas baseadas em microsserviços e computação em nuvem.
