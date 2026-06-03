-- ==============================================================================
-- SCHEMA DE ESTUDO: BANCO DE DADOS MULTI-TENANT COM UUID
-- OBJETIVO: Demonstrar integridade referencial, segurança e indexação usando UUID
-- ==============================================================================

-- NOTA: A partir do PostgreSQL 13, a função gen_random_uuid() é nativa.
-- Se você estiver usando uma versão muito antiga (ex: v11, v12), descomente a linha abaixo:
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. TABELA: TENANTS (Empresas/Lojas que assinam a plataforma)
-- ------------------------------------------------------------------------------
CREATE TABLE tenants (
    tenant_id UUID DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_tenants PRIMARY KEY (tenant_id),
    CONSTRAINT uq_tenants_slug UNIQUE (slug)
);

COMMENT ON TABLE tenants IS 'Armazena as empresas clientes do ecossistema SaaS.';
COMMENT ON COLUMN tenants.tenant_id IS 'Chave primária global e randômica da empresa.';

-- ------------------------------------------------------------------------------
-- 2. TABELA: USERS (Usuários/Clientes de cada Tenant)
-- ------------------------------------------------------------------------------
CREATE TABLE users (
    user_id UUID DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL, -- Chave Estrangeira ligando o usuário ao seu Tenant
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT fk_users_tenants FOREIGN KEY (tenant_id) REFERENCES tenants (tenant_id) ON DELETE CASCADE,
    -- Regra de Negócio: O mesmo e-mail não pode se duplicar DENTRO da mesma loja (tenant)
    CONSTRAINT uq_users_email_per_tenant UNIQUE (tenant_id, email)
);

COMMENT ON COLUMN users.user_id IS 'Impede ataques de enumeração em endpoints públicos de perfil (/api/users/UUID).';

-- ------------------------------------------------------------------------------
-- 3. TABELA: PRODUCTS (Catálogo de Produtos)
-- ------------------------------------------------------------------------------
CREATE TABLE products (
    product_id UUID DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    sku VARCHAR(50) NOT NULL, -- Código de estoque definido pelo lojista
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT fk_products_tenants FOREIGN KEY (tenant_id) REFERENCES tenants (tenant_id) ON DELETE CASCADE,
    -- O SKU deve ser único por loja, mas pode se repetir em lojas diferentes
    CONSTRAINT uq_products_sku_per_tenant UNIQUE (tenant_id, sku)
);

-- ------------------------------------------------------------------------------
-- 4. TABELA: ORDERS (Pedidos realizados)
-- ------------------------------------------------------------------------------
CREATE TABLE orders (
    order_id UUID DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    user_id UUID NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_tenants FOREIGN KEY (tenant_id) REFERENCES tenants (tenant_id) ON DELETE CASCADE,
    -- Relacionamento de UUID com UUID entre tabelas parentes
    CONSTRAINT fk_orders_users FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT
);

COMMENT ON COLUMN orders.order_id IS 'Utilizado como código do pedido enviado ao cliente final. Evita expor o volume de vendas real da loja.';

-- ------------------------------------------------------------------------------
-- 5. TABELA: ORDER_ITEMS (Detalhamento dos produtos comprados)
-- ------------------------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id UUID DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    
    CONSTRAINT pk_order_items PRIMARY KEY (order_item_id),
    CONSTRAINT fk_items_orders FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_products FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE RESTRICT,
    -- Evita que o mesmo produto seja adicionado em linhas diferentes no mesmo pedido
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
);

-- INSERTS
-- 1. Inserindo dois Tenants (Lojas distintas)
INSERT INTO tenants (name, slug) 
VALUES 
    ('Tech Store BR', 'tech-store'),
    ('Moda Fashion', 'moda-fashion')
RETURNING tenant_id, name;

-- ATENÇÃO: Para os passos seguintes, substitua os UUIDs gerados no passo 1 
-- ou use subqueries dinâmicas como abaixo para garantir o funcionamento automático:

-- 2. Inserindo Usuários vinculados a cada Tenant dinamicamente
INSERT INTO users (tenant_id, name, email, password_hash)
VALUES 
    ((SELECT tenant_id FROM tenants WHERE slug = 'tech-store'), 'Carlos Eduardo', 'carlos@email.com', '$2b$12$hash...'),
    ((SELECT tenant_id FROM tenants WHERE slug = 'moda-fashion'), 'Ana Julia', 'ana@email.com', '$2b$12$hash...');

-- 3. Inserindo Produtos no catálogo de cada loja
INSERT INTO products (tenant_id, title, price, sku)
VALUES 
    ((SELECT tenant_id FROM tenants WHERE slug = 'tech-store'), 'Notebook Gamer X', 5499.90, 'NOTE-GMR-01'),
    ((SELECT tenant_id FROM tenants WHERE slug = 'tech-store'), 'Mouse Sem Fio Ouro', 250.00, 'MOU-SF-02'),
    ((SELECT tenant_id FROM tenants WHERE slug = 'moda-fashion'), 'Camiseta Algodão Egípcio', 120.00, 'CAM-ALG-01');

-- 4. Simulando a criação de um Pedido completo (Tech Store)
DO $$
DECLARE
    v_tenant_id UUID;
    v_user_id UUID;
    v_product_id UUID;
    v_order_id UUID;
BEGIN
    -- Captura as chaves randômicas existentes
    SELECT tenant_id INTO v_tenant_id FROM tenants WHERE slug = 'tech-store';
    SELECT user_id INTO v_user_id FROM users WHERE email = 'carlos@email.com';
    SELECT product_id INTO v_product_id FROM products WHERE sku = 'NOTE-GMR-01';

    -- Cria o pedido principal
    INSERT INTO orders (tenant_id, user_id, total_amount, status)
    VALUES (v_tenant_id, v_user_id, 5499.90, 'paid')
    RETURNING order_id INTO v_order_id;

    -- Vincula o item usando o UUID do pedido gerado acima
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, v_product_id, 1, 5499.90);
END $$;


-- Uma Pequena Consulta
SELECT 
    t.name AS loja,
    o.order_id AS codigo_pedido,
    u.name AS cliente,
    p.title AS produto,
    i.quantity AS qtd,
    i.unit_price AS valor_unitario,
    o.total_amount AS total_pedido
FROM orders o
JOIN tenants t ON o.tenant_id = t.tenant_id
JOIN users u ON o.user_id = u.user_id
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id;