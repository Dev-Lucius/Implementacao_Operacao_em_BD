# 🗄️ Implementação e Operação em Banco de Dados

Repositório dedicado aos estudos e implementações desenvolvidas na disciplina Implementação e Operação em Banco de Dados do curso de Análise e Desenvolvimento de Sistemas.

Este projeto reúne modelagem relacional, consultas SQL, normalização e programação em banco de dados, consolidando conceitos fundamentais para o desenvolvimento de sistemas orientados a dados.

## 📌 Sobre a Disciplina

A disciplina aborda os fundamentos necessários para projetar, implementar e operar bancos de dados relacionais, explorando tanto aspectos conceituais quanto práticos.

### Principais tópicos abordados

- Modelo Relacional
- Linguagem SQL
- Definição e Manipulação de Dados
- Consultas Avançadas
- Normalização de Dados
- Programação em Banco de Dados

## 🧠 Competências Desenvolvidas

Durante o desenvolvimento das atividades desta disciplina, foram trabalhadas as seguintes competências:

- ✔ Modelagem de dados relacionais
- ✔ Escrita de consultas SQL complexas
- ✔ Manipulação eficiente de dados
- ✔ Aplicação de normalização
- ✔ Desenvolvimento de lógica dentro do banco de dados

## 🗃️ Modelo Relacional

O modelo relacional organiza os dados em tabelas compostas por:

- Tuplas (linhas) → registros
- Atributos (colunas) → propriedades
- Chaves primárias → identificadores únicos
- Chaves estrangeiras → relações entre tabelas

## Exemplo ...

```sql
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100)
```

## 🧩 Normalização de Dados

A normalização é o processo de organizar tabelas para:

- reduzir redundância
- evitar inconsistência de dados
- melhorar integridade do banco

### Formas de Normais Abordardas

| Forma Normal | Objetivo                          |
| ------------ | --------------------------------- |
| 1FN          | Eliminar grupos repetitivos       |
| 2FN          | Remover dependências parciais     |
| 3FN          | Eliminar dependências transitivas |

## ⚙️ Programação em Banco de Dados

Introdução à lógica executada diretamente no banco de dados.

- Exemplos abordados
- Stored Procedures
- Functions
- Triggers
- Views

### Exemplo de trigger:

```sql
CREATE OR REPLACE FUNCTION log_insert_cliente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_clientes(data_log)
    VALUES (NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Descrição                                  |
| ---------- | ------------------------------------------ |
| SQL        | Linguagem padrão para bancos relacionais   |
| PostgreSQL | Sistema de gerenciamento de banco de dados |
| pgAdmin    | Interface gráfica para administração       |
| DBeaver    | Ferramenta universal para bancos de dados  |


## 📊 Exemplos de Aplicação

Os scripts presentes neste repositório simulam cenários comuns em sistemas reais:

- Sistema de clientes e pedidos
- Relacionamentos entre entidades
- Consultas analíticas
- Automatização de operações com triggers

## 📚 Referências de Estudo

- Documentação oficial do PostgreSQL
- Material da disciplina
- Modelagem de banco de dados relacional

## 📚 Conteúdo Complementar

Os **resumos teóricos, mapas conceituais e anotações detalhadas** da cadeira de **Implementação e Operação de Banco de Dados** estão disponíveis no meu Notion, com acesso no link abaixo:

🔗 **Acesse aqui:** [Resumos da Cadeira no Notion](https://www.notion.so/3057c6764d48808ea350ee2b292cdbc9?v=3057c6764d488152852c000c8342eaf8&source=copy_link)


## 👨‍💻 Autor

**Lucas Oliveira**

Estudante de Análise e Desenvolvimento de Sistemas com foco em:

- Engenharia de Software
- Desenvolvimento Full Stack
- Banco de Dados
- Arquitetura de Sistemas

📌 [![GitHub](https://img.shields.io/badge/GitHub-Perfil-181717?logo=github)](https://github.com/Dev-Lucius)

## 📜 Licença

Este repositório possui finalidade educacional e acadêmica.

---
> 💡 Parte da minha jornada de aprendizado em engenharia de software e desenvolvimento de sistemas.
---
