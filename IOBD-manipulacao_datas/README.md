# 📅 Funções de Manipulação de Data no PostgreSQL

> **Apostila Digital** — Guia completo sobre funções de data e tempo no PostgreSQL, com exemplos práticos, casos de uso reais e exercícios resolvidos.

---

## 📚 Sumário

1. [Tipos de Dados de Data e Tempo](#-tipos-de-dados-de-data-e-tempo)
2. [Valores Atuais do Sistema](#-valores-atuais-do-sistema)
3. [Funções de Extração](#-funções-de-extração)
4. [Funções de Truncamento](#-funções-de-truncamento)
5. [Aritmética com Datas](#-aritmética-com-datas)
6. [Intervalos (INTERVAL)](#-intervalos-interval)
7. [Formatação de Datas](#-formatação-de-datas)
8. [Conversão e Parsing](#-conversão-e-parsing)
9. [Funções de Construção](#-funções-de-construção)
10. [Funções de Diferença e Idade](#-funções-de-diferença-e-idade)
11. [Timezones](#-timezones)
12. [Exercícios Resolvidos](#-exercícios-resolvidos)
13. [Cheatsheet Rápido](#-cheatsheet-rápido)

---

## 🗂️ Tipos de Dados de Data e Tempo

O PostgreSQL oferece um conjunto rico de tipos para representar data e hora:

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `DATE` | Apenas data (ano, mês, dia) | `2024-03-15` |
| `TIME` | Apenas hora (sem fuso) | `14:30:00` |
| `TIMETZ` | Hora com fuso horário | `14:30:00-03` |
| `TIMESTAMP` | Data + hora (sem fuso) | `2024-03-15 14:30:00` |
| `TIMESTAMPTZ` | Data + hora (com fuso) | `2024-03-15 14:30:00-03` |
| `INTERVAL` | Duração de tempo | `3 days 2 hours` |

### Quando usar cada tipo?

```sql
-- DATE: quando só a data importa (aniversário, data de contrato)
CREATE TABLE usuarios (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(100),
    nascimento DATE
);

-- TIMESTAMP: eventos internos sem preocupação com fuso
CREATE TABLE logs (
    id         SERIAL PRIMARY KEY,
    acao       TEXT,
    criado_em  TIMESTAMP DEFAULT NOW()
);

-- TIMESTAMPTZ: recomendado para aplicações multi-timezone
CREATE TABLE pedidos (
    id          SERIAL PRIMARY KEY,
    descricao   TEXT,
    criado_em   TIMESTAMPTZ DEFAULT NOW()
);
```

> 💡 **Boas Práticas:** Prefira sempre `TIMESTAMPTZ` em sistemas que podem ter usuários em fusos horários diferentes. O PostgreSQL armazena internamente em UTC e converte automaticamente.

---

## ⏱️ Valores Atuais do Sistema

Funções para obter a data e hora do momento atual:

```sql
-- Data atual (sem hora)
SELECT CURRENT_DATE;
-- Resultado: 2024-03-15

-- Hora atual (sem data)
SELECT CURRENT_TIME;
-- Resultado: 14:30:00.123456-03

-- Data e hora atual COM fuso horário (recomendado)
SELECT NOW();
SELECT CURRENT_TIMESTAMP;
-- Resultado: 2024-03-15 14:30:00.123456-03

-- Data e hora atual SEM fuso horário
SELECT LOCALTIMESTAMP;
-- Resultado: 2024-03-15 14:30:00.123456
```

### Diferença entre NOW() e CLOCK_TIMESTAMP()

```sql
-- NOW() retorna o timestamp do INÍCIO da transação (consistente)
BEGIN;
    SELECT NOW();  -- 14:30:00
    SELECT pg_sleep(2);
    SELECT NOW();  -- ainda 14:30:00 (mesma transação)
COMMIT;

-- CLOCK_TIMESTAMP() retorna o tempo REAL de execução (muda a cada chamada)
BEGIN;
    SELECT CLOCK_TIMESTAMP();  -- 14:30:00
    SELECT pg_sleep(2);
    SELECT CLOCK_TIMESTAMP();  -- 14:30:02 (atualizado!)
COMMIT;
```

> 💡 Use `NOW()` para consistência transacional (ex: múltiplos INSERTs com a mesma data). Use `CLOCK_TIMESTAMP()` para medir tempo de execução.

---

## 🔍 Funções de Extração

### EXTRACT()

Extrai uma parte específica de uma data ou intervalo.

**Sintaxe:** `EXTRACT(campo FROM expressão)`

```sql
SELECT EXTRACT(YEAR  FROM CURRENT_DATE);  -- 2024
SELECT EXTRACT(MONTH FROM CURRENT_DATE);  -- 3
SELECT EXTRACT(DAY   FROM CURRENT_DATE);  -- 15

-- Aplicando em uma coluna
SELECT
    nome,
    nascimento,
    EXTRACT(YEAR  FROM nascimento) AS ano_nasc,
    EXTRACT(MONTH FROM nascimento) AS mes_nasc,
    EXTRACT(DAY   FROM nascimento) AS dia_nasc
FROM usuarios;
```

### Campos disponíveis no EXTRACT()

| Campo | Descrição | Intervalo |
|-------|-----------|-----------|
| `YEAR` | Ano | Ex: 2024 |
| `MONTH` | Mês | 1–12 |
| `DAY` | Dia do mês | 1–31 |
| `HOUR` | Hora | 0–23 |
| `MINUTE` | Minuto | 0–59 |
| `SECOND` | Segundo (com decimais) | 0–60.999... |
| `DOW` | Dia da semana | 0=Dom ... 6=Sáb |
| `ISODOW` | Dia da semana (ISO) | 1=Seg ... 7=Dom |
| `DOY` | Dia do ano | 1–366 |
| `WEEK` | Semana do ano (ISO) | 1–53 |
| `QUARTER` | Trimestre | 1–4 |
| `EPOCH` | Segundos desde 1970-01-01 | Número grande |
| `MILLENNIUM` | Milênio | Ex: 3 |
| `CENTURY` | Século | Ex: 21 |
| `DECADE` | Década | Ex: 202 |
| `JULIAN` | Número do dia Juliano | — |
| `MICROSECONDS` | Microssegundos | — |
| `MILLISECONDS` | Milissegundos | — |

```sql
-- Exemplos práticos de cada campo
SELECT
    EXTRACT(DOW      FROM NOW()) AS dia_semana,       -- 0 (Domingo)
    EXTRACT(ISODOW   FROM NOW()) AS dia_semana_iso,   -- 7 (Domingo, padrão ISO)
    EXTRACT(DOY      FROM NOW()) AS dia_do_ano,       -- 75 (75º dia do ano)
    EXTRACT(WEEK     FROM NOW()) AS semana_do_ano,    -- 11
    EXTRACT(QUARTER  FROM NOW()) AS trimestre,        -- 1
    EXTRACT(EPOCH    FROM NOW()) AS unix_timestamp;   -- 1710509400
```

### DATE_PART() — Alternativa ao EXTRACT()

```sql
-- DATE_PART é equivalente ao EXTRACT, mas com sintaxe diferente
SELECT DATE_PART('year',  nascimento) AS ano  FROM usuarios;
SELECT DATE_PART('month', nascimento) AS mes  FROM usuarios;
SELECT DATE_PART('day',   nascimento) AS dia  FROM usuarios;

-- EXTRACT e DATE_PART são funcionalmente equivalentes:
SELECT EXTRACT(YEAR FROM NOW());      -- retorna 2024
SELECT DATE_PART('year', NOW());      -- retorna 2024 (mesmo resultado)
```

---

## ✂️ Funções de Truncamento

### DATE_TRUNC()

Trunca uma data/timestamp para a precisão especificada.

**Sintaxe:** `DATE_TRUNC(campo, expressão)`

```sql
SELECT DATE_TRUNC('year',    '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-01-01 00:00:00

SELECT DATE_TRUNC('month',   '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-03-01 00:00:00

SELECT DATE_TRUNC('day',     '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-03-15 00:00:00

SELECT DATE_TRUNC('hour',    '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-03-15 14:00:00

SELECT DATE_TRUNC('minute',  '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-03-15 14:30:00

SELECT DATE_TRUNC('week',    '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-03-11 00:00:00 (segunda-feira da semana)

SELECT DATE_TRUNC('quarter', '2024-03-15 14:30:45'::TIMESTAMP);
-- Resultado: 2024-01-01 00:00:00 (início do trimestre)
```

### Caso de uso real: relatórios agrupados por período

```sql
-- Vendas por mês
SELECT
    DATE_TRUNC('month', criado_em) AS mes,
    COUNT(*)                        AS total_pedidos,
    SUM(valor)                      AS receita_total
FROM pedidos
GROUP BY DATE_TRUNC('month', criado_em)
ORDER BY mes DESC;

-- Acessos por hora
SELECT
    DATE_TRUNC('hour', criado_em) AS hora,
    COUNT(*)                       AS acessos
FROM logs
GROUP BY DATE_TRUNC('hour', criado_em)
ORDER BY hora;
```

---

## ➕ Aritmética com Datas

O PostgreSQL permite operações matemáticas diretamente em datas.

### Somando e subtraindo dias

```sql
-- Adicionar dias a uma data
SELECT CURRENT_DATE + 7;       -- daqui a 7 dias
SELECT CURRENT_DATE + 30;      -- daqui a 30 dias
SELECT CURRENT_DATE - 7;       -- 7 dias atrás

-- Subtrair duas datas → retorna número de dias
SELECT '2024-12-31'::DATE - '2024-01-01'::DATE;  -- 365
```

### Diferença entre timestamps

```sql
-- Diferença retorna INTERVAL
SELECT '2024-03-15 18:00:00'::TIMESTAMP
     - '2024-03-15 09:00:00'::TIMESTAMP;
-- Resultado: 09:00:00

-- Convertendo a horas numéricas
SELECT EXTRACT(EPOCH FROM (
    '2024-03-15 18:00:00'::TIMESTAMP
  - '2024-03-15 09:00:00'::TIMESTAMP
)) / 3600 AS horas;
-- Resultado: 9
```

### Tabela de operações

| Operação | Tipo do Resultado | Exemplo |
|----------|-------------------|---------|
| `DATE + INTEGER` | `DATE` | `'2024-01-01' + 10` → `2024-01-11` |
| `DATE - INTEGER` | `DATE` | `'2024-01-11' - 10` → `2024-01-01` |
| `DATE - DATE` | `INTEGER` | `'2024-01-11' - '2024-01-01'` → `10` |
| `TIMESTAMP + INTERVAL` | `TIMESTAMP` | `NOW() + INTERVAL '1 hour'` |
| `TIMESTAMP - TIMESTAMP` | `INTERVAL` | `ts2 - ts1` |
| `INTERVAL * NUMERIC` | `INTERVAL` | `INTERVAL '1 day' * 7` → `7 days` |

---

## 🕐 Intervalos (INTERVAL)

`INTERVAL` representa uma duração de tempo — a ferramenta mais flexível para aritmética de datas.

### Sintaxe de criação

```sql
-- Formas equivalentes de criar intervalos
SELECT INTERVAL '1 year';
SELECT INTERVAL '2 months';
SELECT INTERVAL '15 days';
SELECT INTERVAL '3 hours';
SELECT INTERVAL '30 minutes';
SELECT INTERVAL '45 seconds';

-- Combinados
SELECT INTERVAL '1 year 2 months 15 days';
SELECT INTERVAL '2 hours 30 minutes';
SELECT INTERVAL '1 day 12:30:00';

-- Usando abreviações
SELECT INTERVAL '1y 2mon 15d 3h 30m 45s';
```

### Usando INTERVAL em consultas

```sql
-- Requerimentos dos últimos 30 dias
SELECT * FROM requerimentos
WHERE criado_em >= NOW() - INTERVAL '30 days';

-- Contratos que vencem nos próximos 7 dias
SELECT * FROM contratos
WHERE data_vencimento BETWEEN CURRENT_DATE
                          AND CURRENT_DATE + INTERVAL '7 days';

-- Usuários ativos no último trimestre
SELECT * FROM usuarios
WHERE ultimo_acesso >= NOW() - INTERVAL '3 months';

-- Sessões criadas na última hora
SELECT * FROM sessoes
WHERE criado_em >= NOW() - INTERVAL '1 hour';
```

### Aritmética com INTERVAL

```sql
-- Multiplicar intervalo
SELECT INTERVAL '1 day' * 7;     -- 7 days
SELECT INTERVAL '1 hour' * 24;   -- 24:00:00

-- Dividir intervalo
SELECT INTERVAL '1 day' / 2;     -- 12:00:00

-- Somar intervalos
SELECT INTERVAL '1 hour' + INTERVAL '30 minutes';  -- 01:30:00

-- Extrair parte de um intervalo
SELECT EXTRACT(HOURS FROM INTERVAL '2 hours 30 minutes');  -- 2
SELECT EXTRACT(DAYS  FROM INTERVAL '10 days 3 hours');     -- 10
```

---

## 🎨 Formatação de Datas

### TO_CHAR()

Converte data/hora em texto formatado.

**Sintaxe:** `TO_CHAR(valor, 'formato')`

```sql
-- Formatos básicos
SELECT TO_CHAR(NOW(), 'DD/MM/YYYY');            -- 15/03/2024
SELECT TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI:SS'); -- 15/03/2024 14:30:45
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD');            -- 2024-03-15

-- Nome do dia e mês
SELECT TO_CHAR(NOW(), 'Day');    -- Friday   (inglês)
SELECT TO_CHAR(NOW(), 'TMDay'); -- Sexta-Feira (locale do servidor)
SELECT TO_CHAR(NOW(), 'Month'); -- March    (inglês)
SELECT TO_CHAR(NOW(), 'TMMonth'); -- Março  (locale do servidor)

-- Combinações
SELECT TO_CHAR(NOW(), 'DD "de" TMMonth "de" YYYY');
-- Resultado: 15 de Março de 2024

SELECT TO_CHAR(NOW(), 'TMDay, DD/MM/YYYY');
-- Resultado: Sexta-Feira, 15/03/2024
```

### Tabela de Padrões de Formatação

| Padrão | Descrição | Exemplo |
|--------|-----------|---------|
| `YYYY` | Ano com 4 dígitos | 2024 |
| `YY` | Ano com 2 dígitos | 24 |
| `MM` | Mês com zero à esquerda | 03 |
| `Month` | Nome do mês (inglês) | March |
| `TMMonth` | Nome do mês (locale) | Março |
| `MON` | Mês abreviado | Mar |
| `DD` | Dia com zero à esquerda | 05 |
| `D` | Dia da semana (1=Dom) | 6 |
| `Day` | Nome do dia (inglês) | Friday |
| `TMDay` | Nome do dia (locale) | Sexta-Feira |
| `DY` | Abreviação do dia | Fri |
| `HH` | Hora (01–12) | 02 |
| `HH24` | Hora (00–23) | 14 |
| `MI` | Minutos | 30 |
| `SS` | Segundos | 45 |
| `MS` | Milissegundos | 123 |
| `US` | Microssegundos | 123456 |
| `AM` / `PM` | Indicador AM/PM | PM |
| `TZ` | Nome do fuso horário | BRT |
| `WW` | Semana do ano | 11 |
| `Q` | Trimestre | 1 |
| `J` | Dia Juliano | 2460385 |

### Modificadores de formato

```sql
-- FM: remove espaços e zeros à esquerda
SELECT TO_CHAR(NOW(), 'FMDay, DD "de" FMMonth "de" YYYY');
-- Resultado: Sexta, 15 de Março de 2024 (sem espaços extras)

-- TM: usa o locale do servidor para nomes
SELECT TO_CHAR(NOW(), 'TMDay');   -- Sexta-Feira (se locale = pt_BR)

-- Texto literal entre aspas duplas
SELECT TO_CHAR(NOW(), '"Hoje é" Day');
-- Resultado: Hoje é Friday
```

---

## 🔄 Conversão e Parsing

### TO_DATE() — String para DATE

```sql
-- TO_DATE(texto, formato)
SELECT TO_DATE('15/03/2024', 'DD/MM/YYYY');      -- 2024-03-15
SELECT TO_DATE('2024-03-15', 'YYYY-MM-DD');      -- 2024-03-15
SELECT TO_DATE('15 Março 2024', 'DD Month YYYY'); -- 2024-03-15
SELECT TO_DATE('15032024', 'DDMMYYYY');           -- 2024-03-15
```

### TO_TIMESTAMP() — String para TIMESTAMP

```sql
SELECT TO_TIMESTAMP('15/03/2024 14:30:45', 'DD/MM/YYYY HH24:MI:SS');
-- Resultado: 2024-03-15 14:30:45

SELECT TO_TIMESTAMP('2024-03-15T14:30:45', 'YYYY-MM-DD"T"HH24:MI:SS');
-- Resultado: 2024-03-15 14:30:45

-- A partir de Unix Timestamp (segundos desde 1970)
SELECT TO_TIMESTAMP(1710509400);
-- Resultado: 2024-03-15 14:30:00+00
```

### Casting — Conversão com ::

```sql
-- String → DATE
SELECT '2024-03-15'::DATE;

-- String → TIMESTAMP
SELECT '2024-03-15 14:30:00'::TIMESTAMP;

-- String → TIMESTAMPTZ
SELECT '2024-03-15 14:30:00-03'::TIMESTAMPTZ;

-- DATE → TIMESTAMP (meia-noite)
SELECT CURRENT_DATE::TIMESTAMP;

-- TIMESTAMP → DATE (remove a hora)
SELECT NOW()::DATE;

-- TIMESTAMP → TEXT
SELECT NOW()::TEXT;
```

---

## 🏗️ Funções de Construção

### MAKE_DATE() e MAKE_TIMESTAMP()

Constroem uma data a partir de componentes numéricos.

```sql
-- MAKE_DATE(ano, mês, dia)
SELECT MAKE_DATE(2024, 3, 15);
-- Resultado: 2024-03-15

-- MAKE_TIMESTAMP(ano, mês, dia, hora, min, seg)
SELECT MAKE_TIMESTAMP(2024, 3, 15, 14, 30, 45);
-- Resultado: 2024-03-15 14:30:45

-- MAKE_TIMESTAMPTZ(ano, mês, dia, hora, min, seg, timezone)
SELECT MAKE_TIMESTAMPTZ(2024, 3, 15, 14, 30, 45, 'America/Sao_Paulo');
-- Resultado: 2024-03-15 14:30:45-03

-- Caso de uso: construir datas a partir de colunas separadas
SELECT MAKE_DATE(ano, mes, dia) AS data_completa
FROM tabela_com_colunas_separadas;
```

### MAKE_INTERVAL()

```sql
-- MAKE_INTERVAL(anos, meses, semanas, dias, horas, minutos, segundos)
SELECT MAKE_INTERVAL(years => 1, months => 2, days => 15);
-- Resultado: 1 year 2 mons 15 days

SELECT MAKE_INTERVAL(hours => 3, mins => 30);
-- Resultado: 03:30:00
```

---

## 📏 Funções de Diferença e Idade

### AGE() — Calcula o intervalo entre datas

```sql
-- AGE(data) → intervalo da data até HOJE
SELECT AGE('1990-05-20'::DATE);
-- Resultado: 33 years 9 months 25 days

-- AGE(data_fim, data_inicio) → intervalo entre duas datas
SELECT AGE('2024-03-15'::DATE, '2020-01-01'::DATE);
-- Resultado: 4 years 2 mons 14 days

-- Extraindo a idade em anos
SELECT EXTRACT(YEAR FROM AGE(nascimento)) AS idade_anos
FROM usuarios;

-- Filtrando maiores de 18 anos
SELECT * FROM usuarios
WHERE EXTRACT(YEAR FROM AGE(nascimento)) >= 18;

-- Filtrando maiores de 18 anos (alternativa)
WHERE nascimento <= CURRENT_DATE - INTERVAL '18 years';
```

### Diferença em dias

```sql
-- Diferença direta entre DATEs → retorna INTEGER
SELECT '2024-12-31'::DATE - '2024-01-01'::DATE AS dias;
-- Resultado: 365

-- Diferença entre TIMESTAMPs → retorna INTERVAL, converte com EPOCH
SELECT EXTRACT(EPOCH FROM (
    '2024-03-15 18:00:00'::TIMESTAMP
  - '2024-03-15 09:00:00'::TIMESTAMP
)) / 86400 AS dias_decimais;
-- Resultado: 0.375 (9 horas = 0.375 dia)

-- Diferença em dias inteiros
SELECT (data_fechamento::DATE - data_abertura::DATE) AS dias_aberto
FROM requerimentos;
```

### Comparação de datas em consultas

```sql
-- Registros de hoje
SELECT * FROM requerimentos
WHERE criado_em::DATE = CURRENT_DATE;

-- Alternativa com range (aproveita índices)
SELECT * FROM requerimentos
WHERE criado_em >= CURRENT_DATE
  AND criado_em <  CURRENT_DATE + INTERVAL '1 day';

-- Registros de um mês específico
SELECT * FROM pedidos
WHERE DATE_TRUNC('month', criado_em) = DATE_TRUNC('month', NOW());

-- Registros do ano atual
SELECT * FROM pedidos
WHERE EXTRACT(YEAR FROM criado_em) = EXTRACT(YEAR FROM NOW());
```

---

## 🌍 Timezones

### Visualizando e convertendo fusos horários

```sql
-- Ver o timezone atual da sessão
SHOW timezone;

-- Alterar timezone da sessão
SET timezone = 'America/Sao_Paulo';
SET timezone = 'UTC';

-- Listar todos os fusos disponíveis
SELECT * FROM pg_timezone_names ORDER BY name;

-- Converter entre fusos horários
SELECT NOW() AT TIME ZONE 'America/Sao_Paulo' AS horario_brasil;
SELECT NOW() AT TIME ZONE 'America/New_York'  AS horario_ny;
SELECT NOW() AT TIME ZONE 'UTC'               AS horario_utc;

-- Converter um timestamp armazenado
SELECT
    criado_em,
    criado_em AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo' AS horario_local
FROM pedidos;
```

### Fusos horários do Brasil

| Fuso | Região | Identificador |
|------|--------|---------------|
| BRT (UTC-3) | Brasília, SP, RJ, Sul | `America/Sao_Paulo` |
| AMT (UTC-4) | Amazonas, Mato Grosso | `America/Manaus` |
| ACT (UTC-5) | Acre | `America/Rio_Branco` |
| FNT (UTC-2) | Fernando de Noronha | `America/Noronha` |

```sql
-- Exemplo prático: armazenar e exibir em horário local
INSERT INTO pedidos (criado_em) VALUES (NOW() AT TIME ZONE 'UTC');

SELECT
    id,
    criado_em AT TIME ZONE 'America/Sao_Paulo' AS criado_em_brasil
FROM pedidos;
```

---

## 📝 Exercícios Resolvidos

### 56) Requerimentos de hoje

```sql
-- Forma simples (converte para DATE)
SELECT *
FROM requerimentos
WHERE criado_em::DATE = CURRENT_DATE;

-- Forma otimizada (utiliza índice na coluna criado_em)
SELECT *
FROM requerimentos
WHERE criado_em >= CURRENT_DATE
  AND criado_em <  CURRENT_DATE + INTERVAL '1 day';

-- Alternativa com BETWEEN
SELECT *
FROM requerimentos
WHERE criado_em BETWEEN CURRENT_DATE
                    AND CURRENT_DATE + INTERVAL '1 day' - INTERVAL '1 second';
```

> ⚠️ A segunda forma é preferível em produção, pois permite ao PostgreSQL usar índices na coluna `criado_em` sem precisar converter cada valor.

---

### 57) Diferença em dias

```sql
-- Diferença simples entre DATEs
SELECT
    id,
    data_abertura,
    data_fechamento,
    (data_fechamento::DATE - data_abertura::DATE) AS diferenca_dias
FROM requerimentos;

-- Com AGE() para leitura mais descritiva
SELECT
    id,
    data_abertura,
    data_fechamento,
    AGE(data_fechamento, data_abertura) AS tempo_decorrido
FROM requerimentos;

-- Diferença incluindo horas (como número decimal)
SELECT
    id,
    EXTRACT(EPOCH FROM (data_fechamento - data_abertura)) / 86400 AS dias_com_horas
FROM requerimentos;

-- Casos nulos: requerimentos ainda abertos
SELECT
    id,
    data_abertura,
    COALESCE(data_fechamento, NOW()::DATE) AS data_ref,
    (COALESCE(data_fechamento, NOW()::DATE) - data_abertura) AS dias_decorridos
FROM requerimentos;
```

---

### 58) Requerimentos dos últimos 30 dias

```sql
-- Últimos 30 dias a partir de HOJE (considera apenas a data)
SELECT *
FROM requerimentos
WHERE criado_em >= CURRENT_DATE - INTERVAL '30 days';

-- Últimos 30 dias a partir do MOMENTO EXATO (hora a hora)
SELECT *
FROM requerimentos
WHERE criado_em >= NOW() - INTERVAL '30 days';

-- Com contagem por dia
SELECT
    criado_em::DATE AS data,
    COUNT(*)         AS total
FROM requerimentos
WHERE criado_em >= NOW() - INTERVAL '30 days'
GROUP BY criado_em::DATE
ORDER BY data DESC;

-- Com status e agrupamento
SELECT
    criado_em::DATE AS data,
    status,
    COUNT(*)         AS total
FROM requerimentos
WHERE criado_em >= NOW() - INTERVAL '30 days'
GROUP BY criado_em::DATE, status
ORDER BY data DESC, status;
```

---

### 59) Extrair dia da semana

```sql
-- Número do dia da semana
SELECT
    id,
    criado_em,
    EXTRACT(DOW   FROM criado_em) AS dia_semana_0a6,  -- 0=Dom, 6=Sáb
    EXTRACT(ISODOW FROM criado_em) AS dia_semana_iso  -- 1=Seg, 7=Dom
FROM requerimentos;

-- Nome do dia da semana em inglês
SELECT
    id,
    TO_CHAR(criado_em, 'Day') AS dia_semana_en
FROM requerimentos;

-- Nome do dia em português (depende do locale do servidor)
SELECT
    id,
    TO_CHAR(criado_em, 'TMDay') AS dia_semana_pt
FROM requerimentos;

-- Mapeamento manual para garantir português
SELECT
    id,
    criado_em,
    CASE EXTRACT(DOW FROM criado_em)
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
    END AS dia_semana_pt
FROM requerimentos;

-- Filtrando apenas dias úteis (segunda a sexta)
SELECT *
FROM requerimentos
WHERE EXTRACT(DOW FROM criado_em) BETWEEN 1 AND 5;

-- Filtrando fins de semana
SELECT *
FROM requerimentos
WHERE EXTRACT(DOW FROM criado_em) IN (0, 6);
```

---

### 60) Idade do usuário

```sql
-- Idade completa como intervalo
SELECT
    id,
    nome,
    nascimento,
    AGE(nascimento) AS idade_completa
FROM usuarios;
-- Resultado: 33 years 9 months 25 days

-- Apenas anos
SELECT
    id,
    nome,
    nascimento,
    EXTRACT(YEAR FROM AGE(nascimento)) AS idade_anos
FROM usuarios;

-- Formatação amigável
SELECT
    id,
    nome,
    nascimento,
    EXTRACT(YEAR FROM AGE(nascimento)) || ' anos' AS idade
FROM usuarios;

-- Filtrar maiores de 18 anos
SELECT *
FROM usuarios
WHERE EXTRACT(YEAR FROM AGE(nascimento)) >= 18;

-- Alternativa mais eficiente (pode usar índice)
SELECT *
FROM usuarios
WHERE nascimento <= CURRENT_DATE - INTERVAL '18 years';

-- Faixa etária
SELECT
    nome,
    EXTRACT(YEAR FROM AGE(nascimento)) AS idade,
    CASE
        WHEN EXTRACT(YEAR FROM AGE(nascimento)) < 18  THEN 'Menor de idade'
        WHEN EXTRACT(YEAR FROM AGE(nascimento)) < 30  THEN 'Jovem adulto'
        WHEN EXTRACT(YEAR FROM AGE(nascimento)) < 60  THEN 'Adulto'
        ELSE 'Idoso'
    END AS faixa_etaria
FROM usuarios
ORDER BY nascimento;

-- Aniversariantes do mês atual
SELECT *
FROM usuarios
WHERE EXTRACT(MONTH FROM nascimento) = EXTRACT(MONTH FROM CURRENT_DATE);

-- Aniversariantes hoje
SELECT *
FROM usuarios
WHERE EXTRACT(MONTH FROM nascimento) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND EXTRACT(DAY   FROM nascimento) = EXTRACT(DAY   FROM CURRENT_DATE);
```

---

## 📋 Cheatsheet Rápido

### Referência de Funções

| Função | O que faz | Exemplo |
|--------|-----------|---------|
| `CURRENT_DATE` | Data atual | `2024-03-15` |
| `NOW()` | Data e hora atual com fuso | `2024-03-15 14:30:00-03` |
| `CURRENT_TIMESTAMP` | Igual ao NOW() | — |
| `LOCALTIMESTAMP` | Data e hora sem fuso | `2024-03-15 14:30:00` |
| `CLOCK_TIMESTAMP()` | Hora real (muda na transação) | — |
| `EXTRACT(campo FROM data)` | Extrai parte da data | `EXTRACT(YEAR FROM NOW())` |
| `DATE_PART(campo, data)` | Igual ao EXTRACT | `DATE_PART('year', NOW())` |
| `DATE_TRUNC(campo, data)` | Trunca para o período | `DATE_TRUNC('month', NOW())` |
| `AGE(data)` | Intervalo até hoje | `AGE('1990-01-01')` |
| `AGE(d2, d1)` | Intervalo entre datas | `AGE(d2, d1)` |
| `TO_CHAR(data, fmt)` | Data para texto | `TO_CHAR(NOW(), 'DD/MM/YYYY')` |
| `TO_DATE(txt, fmt)` | Texto para DATE | `TO_DATE('15/03/2024', 'DD/MM/YYYY')` |
| `TO_TIMESTAMP(txt, fmt)` | Texto para TIMESTAMP | — |
| `MAKE_DATE(a, m, d)` | Constrói uma DATE | `MAKE_DATE(2024, 3, 15)` |
| `MAKE_INTERVAL(...)` | Constrói um INTERVAL | `MAKE_INTERVAL(days => 30)` |

### Padrões de consulta mais comuns

```sql
-- Hoje
WHERE criado_em::DATE = CURRENT_DATE

-- Esta semana
WHERE criado_em >= DATE_TRUNC('week', NOW())

-- Este mês
WHERE criado_em >= DATE_TRUNC('month', NOW())

-- Este ano
WHERE criado_em >= DATE_TRUNC('year', NOW())

-- Últimas N horas
WHERE criado_em >= NOW() - INTERVAL 'N hours'

-- Últimos N dias
WHERE criado_em >= NOW() - INTERVAL 'N days'

-- Últimos N meses
WHERE criado_em >= NOW() - INTERVAL 'N months'

-- Entre duas datas
WHERE criado_em BETWEEN '2024-01-01' AND '2024-03-31'

-- Dias úteis (seg a sex)
WHERE EXTRACT(DOW FROM criado_em) BETWEEN 1 AND 5

-- Fins de semana
WHERE EXTRACT(DOW FROM criado_em) IN (0, 6)

-- Aniversariantes do mês
WHERE EXTRACT(MONTH FROM nascimento) = EXTRACT(MONTH FROM CURRENT_DATE)
```

---

## 🔗 Referências

- [Documentação Oficial do PostgreSQL — Date/Time Functions](https://www.postgresql.org/docs/current/functions-datetime.html)
- [Documentação Oficial — Data Types Date/Time](https://www.postgresql.org/docs/current/datatype-datetime.html)
- [Documentação Oficial — Pattern Formatting (TO_CHAR)](https://www.postgresql.org/docs/current/functions-formatting.html)

---

> Feito com 💙 para estudo e referência.  
> Sinta-se à vontade para abrir *issues* ou contribuir com mais exemplos!