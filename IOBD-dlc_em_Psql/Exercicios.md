# 🧾 Exercícios – DCL e Normalização

---

## **Aplicação de DCL**

Criação do usuário da aplicação de requerimentos:

```sql
CREATE USER usuario_app WITH PASSWORD 'senha123';

GRANT CONNECT ON DATABASE requerimentos TO usuario_app;
GRANT USAGE ON SCHEMA public TO usuario_app;

GRANT SELECT, INSERT, UPDATE
    ON requerente, requerimento, documento, andamento
    TO usuario_app;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO usuario_app;
```

---

## ✅ **Lista – DCL (contextualizado para sistema de requerimentos)**

### **Questão 1**

**Pergunta:** Crie um usuário chamado `usuario_teste` com a senha `senha123`.

---

### **Questão 2**

**Pergunta:** Conceda permissão de SELECT na tabela `requerente` para o usuário `usuario_teste`.

---

### **Questão 3**

**Pergunta:** Revogue a permissão de SELECT na tabela `requerente` do usuário `usuario_teste`.

---

### **Questão 4**

**Pergunta:** Conceda permissão de INSERT e UPDATE na tabela `requerimento` para o usuário `usuario_teste`.

---

### **Questão 5**

**Pergunta:** Crie um papel (role) chamado `analista_requerimento` e conceda permissão de DELETE na tabela `documento` para esse papel.

---

### **Questão 6**

**Pergunta:** Atribua o papel `analista_requerimento` ao usuário `usuario_teste`.

---

### **Questão 7**

**Pergunta:** Revogue o papel `analista_requerimento` do usuário `usuario_teste`.

---

### **Questão 8**

**Pergunta:** Conceda permissão de EXECUTE em uma função chamada `calcular_tempo_medio_analise` para o usuário `usuario_teste`.

---

### **Questão 9**

**Pergunta:** Crie um papel chamado `leitor` com permissão de SELECT em todas as tabelas do esquema `public`.

---

### **Questão 10**

**Pergunta:** Conceda permissão de USAGE no esquema `protocolo` para o usuário `usuario_teste`.

---

### **Questão 11**

**Pergunta:** Conceda permissão de USAGE e SELECT na sequence `requerente_id_seq` para o usuário `usuario_teste`.

---

### **Questão 12**

**Pergunta:** Conceda permissão de UPDATE na sequence `requerimento_id_seq` para o usuário `usuario_teste`.

---

### **Questão 13**

**Pergunta:** Revogue a permissão de USAGE na sequence `requerente_id_seq` do usuário `usuario_teste`.

---

### **Questão 14**

**Pergunta:** Crie um papel chamado `admin_requerimentos` com permissão de USAGE e UPDATE em todas as sequences do esquema `public`.

---

### **Questão 15**

**Pergunta:** Atribua o papel `admin_requerimentos` ao usuário `usuario_teste`.