-- ============================================================
-- DALU ERP
-- Script: 03_catalogo.sql
-- Descripción: Categorías, unidades, productos y precios
-- PostgreSQL 17
-- ============================================================

BEGIN;


-- ============================================================
-- TABLA: catalogo.categoria
-- Categorías de productos.
-- Ejemplos:
--   Bebidas
--   Pizzas
--   Pollo
--   Ingredientes
--   Empaques
-- ============================================================

CREATE TABLE IF NOT EXISTS catalogo.categoria
(
    categoria_id        BIGINT GENERATED ALWAYS AS IDENTITY,
    empresa_id          BIGINT NOT NULL,

    codigo              VARCHAR(30) NOT NULL,
    nombre              VARCHAR(100) NOT NULL,
    descripcion         VARCHAR(250),

    categoria_padre_id  BIGINT,

    activa              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_categoria
        PRIMARY KEY (categoria_id),

    CONSTRAINT fk_categoria_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT fk_categoria_padre
        FOREIGN KEY (categoria_padre_id)
        REFERENCES catalogo.categoria (categoria_id),

    CONSTRAINT uq_categoria_empresa_codigo
        UNIQUE (empresa_id, codigo),

    CONSTRAINT uq_categoria_empresa_nombre
        UNIQUE (empresa_id, nombre)
);


-- ============================================================
-- TABLA: catalogo.unidad_medida
-- Unidades utilizadas para productos e inventario.
--
-- Ejemplos:
--   UN  = Unidad
--   KG  = Kilogramo
--   G   = Gramo
--   L   = Litro
--   ML  = Mililitro
-- ============================================================

CREATE TABLE IF NOT EXISTS catalogo.unidad_medida
(
    unidad_medida_id    BIGINT GENERATED ALWAYS AS IDENTITY,

    codigo              VARCHAR(10) NOT NULL,
    nombre              VARCHAR(50) NOT NULL,
    abreviatura         VARCHAR(10) NOT NULL,

    permite_decimales   BOOLEAN NOT NULL DEFAULT TRUE,
    activa              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_unidad_medida
        PRIMARY KEY (unidad_medida_id),

    CONSTRAINT uq_unidad_codigo
        UNIQUE (codigo),

    CONSTRAINT uq_unidad_nombre
        UNIQUE (nombre)
);


-- ============================================================
-- TABLA: catalogo.producto
-- Catálogo general de productos.
--
-- Un producto puede ser:
--   - Vendible
--   - Inventariable
--   - Ingrediente
--   - Insumo
--   - Servicio
--
-- Esto nos permitirá reutilizar el catálogo para diferentes
-- tipos de negocios.
-- ============================================================

CREATE TABLE IF NOT EXISTS catalogo.producto
(
    producto_id             BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id              BIGINT NOT NULL,
    categoria_id            BIGINT NOT NULL,
    unidad_medida_id        BIGINT NOT NULL,

    codigo                   VARCHAR(50) NOT NULL,
    codigo_barras            VARCHAR(50),

    nombre                   VARCHAR(150) NOT NULL,
    descripcion              VARCHAR(500),

    tipo_producto            VARCHAR(20) NOT NULL DEFAULT 'PRODUCTO',

    es_vendible              BOOLEAN NOT NULL DEFAULT TRUE,
    es_inventariable         BOOLEAN NOT NULL DEFAULT TRUE,
    es_ingrediente           BOOLEAN NOT NULL DEFAULT FALSE,

    costo_actual             NUMERIC(18,4) NOT NULL DEFAULT 0,
    precio_base              NUMERIC(18,2) NOT NULL DEFAULT 0,

    stock_minimo             NUMERIC(18,4) NOT NULL DEFAULT 0,
    stock_maximo             NUMERIC(18,4),

    activa                   BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_producto
        PRIMARY KEY (producto_id),

    CONSTRAINT fk_producto_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES catalogo.categoria (categoria_id),

    CONSTRAINT fk_producto_unidad
        FOREIGN KEY (unidad_medida_id)
        REFERENCES catalogo.unidad_medida (unidad_medida_id),

    CONSTRAINT uq_producto_empresa_codigo
        UNIQUE (empresa_id, codigo),

    CONSTRAINT uq_producto_empresa_codigo_barras
        UNIQUE (empresa_id, codigo_barras),

    CONSTRAINT ck_producto_tipo
        CHECK (
            tipo_producto IN
            (
                'PRODUCTO',
                'INGREDIENTE',
                'INSUMO',
                'SERVICIO'
            )
        ),

    CONSTRAINT ck_producto_costo
        CHECK (costo_actual >= 0),

    CONSTRAINT ck_producto_precio
        CHECK (precio_base >= 0),

    CONSTRAINT ck_producto_stock_minimo
        CHECK (stock_minimo >= 0),

    CONSTRAINT ck_producto_stock_maximo
        CHECK (
            stock_maximo IS NULL
            OR stock_maximo >= stock_minimo
        )
);


-- ============================================================
-- TABLA: catalogo.producto_precio
-- Permite manejar diferentes precios para un mismo producto.
--
-- Ejemplo:
--   Precio normal
--   Precio para llevar
--   Precio delivery
--   Precio mayorista
--
-- Más adelante podremos agregar listas de precios.
-- ============================================================

CREATE TABLE IF NOT EXISTS catalogo.producto_precio
(
    producto_precio_id    BIGINT GENERATED ALWAYS AS IDENTITY,

    producto_id           BIGINT NOT NULL,

    nombre                VARCHAR(50) NOT NULL,
    precio                NUMERIC(18,2) NOT NULL,

    fecha_inicio          DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin             DATE,

    activo                BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_producto_precio
        PRIMARY KEY (producto_precio_id),

    CONSTRAINT fk_producto_precio_producto
        FOREIGN KEY (producto_id)
        REFERENCES catalogo.producto (producto_id),

    CONSTRAINT ck_producto_precio_valor
        CHECK (precio >= 0),

    CONSTRAINT ck_producto_precio_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin >= fecha_inicio
        )
);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_categoria_empresa
    ON catalogo.categoria (empresa_id);

CREATE INDEX IF NOT EXISTS ix_categoria_padre
    ON catalogo.categoria (categoria_padre_id);

CREATE INDEX IF NOT EXISTS ix_producto_empresa
    ON catalogo.producto (empresa_id);

CREATE INDEX IF NOT EXISTS ix_producto_categoria
    ON catalogo.producto (categoria_id);

CREATE INDEX IF NOT EXISTS ix_producto_codigo_barras
    ON catalogo.producto (codigo_barras);

CREATE INDEX IF NOT EXISTS ix_producto_activo
    ON catalogo.producto (empresa_id, activa);

CREATE INDEX IF NOT EXISTS ix_producto_precio_producto
    ON catalogo.producto_precio (producto_id);


COMMIT;