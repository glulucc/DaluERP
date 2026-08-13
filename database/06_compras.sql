-- ============================================================
-- DALU ERP
-- Script: 06_compras.sql
-- Descripción: Proveedores y compras
-- PostgreSQL 17
-- ============================================================

BEGIN;


-- ============================================================
-- TABLA: compras.proveedor
-- ============================================================

CREATE TABLE IF NOT EXISTS compras.proveedor
(
    proveedor_id        BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id          BIGINT NOT NULL,

    codigo              VARCHAR(30) NOT NULL,
    nombre              VARCHAR(150) NOT NULL,

    identificacion      VARCHAR(30),
    correo              VARCHAR(150),
    telefono            VARCHAR(30),

    direccion           VARCHAR(500),

    contacto_nombre     VARCHAR(150),

    activo              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_proveedor
        PRIMARY KEY (proveedor_id),

    CONSTRAINT fk_proveedor_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT uq_proveedor_empresa_codigo
        UNIQUE (empresa_id, codigo)
);


-- ============================================================
-- TABLA: compras.compra
--
-- Encabezado de la compra.
-- ============================================================

CREATE TABLE IF NOT EXISTS compras.compra
(
    compra_id              BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id             BIGINT NOT NULL,
    sucursal_id            BIGINT NOT NULL,
    proveedor_id           BIGINT NOT NULL,

    numero_documento       VARCHAR(50),

    fecha_compra           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    subtotal               NUMERIC(18,2) NOT NULL DEFAULT 0,
    descuento              NUMERIC(18,2) NOT NULL DEFAULT 0,
    impuesto               NUMERIC(18,2) NOT NULL DEFAULT 0,
    total                  NUMERIC(18,2) NOT NULL DEFAULT 0,

    estado                 VARCHAR(20) NOT NULL DEFAULT 'BORRADOR',

    observaciones          VARCHAR(500),

    creado_en              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_compra
        PRIMARY KEY (compra_id),

    CONSTRAINT fk_compra_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT fk_compra_sucursal
        FOREIGN KEY (sucursal_id)
        REFERENCES configuracion.sucursal (sucursal_id),

    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY (proveedor_id)
        REFERENCES compras.proveedor (proveedor_id),

    CONSTRAINT ck_compra_estado
        CHECK
        (
            estado IN
            (
                'BORRADOR',
                'CONFIRMADA',
                'ANULADA'
            )
        ),

    CONSTRAINT ck_compra_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT ck_compra_descuento
        CHECK (descuento >= 0),

    CONSTRAINT ck_compra_impuesto
        CHECK (impuesto >= 0),

    CONSTRAINT ck_compra_total
        CHECK (total >= 0)
);


-- ============================================================
-- TABLA: compras.compra_detalle
-- ============================================================

CREATE TABLE IF NOT EXISTS compras.compra_detalle
(
    compra_detalle_id       BIGINT GENERATED ALWAYS AS IDENTITY,

    compra_id               BIGINT NOT NULL,
    producto_id             BIGINT NOT NULL,

    cantidad                NUMERIC(18,4) NOT NULL,

    costo_unitario          NUMERIC(18,4) NOT NULL,

    descuento               NUMERIC(18,2) NOT NULL DEFAULT 0,

    impuesto                NUMERIC(18,2) NOT NULL DEFAULT 0,

    subtotal                NUMERIC(18,2) NOT NULL DEFAULT 0,

    total                   NUMERIC(18,2) NOT NULL DEFAULT 0,

    CONSTRAINT pk_compra_detalle
        PRIMARY KEY (compra_detalle_id),

    CONSTRAINT fk_compra_detalle_compra
        FOREIGN KEY (compra_id)
        REFERENCES compras.compra (compra_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_compra_detalle_producto
        FOREIGN KEY (producto_id)
        REFERENCES catalogo.producto (producto_id),

    CONSTRAINT ck_compra_detalle_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT ck_compra_detalle_costo
        CHECK (costo_unitario >= 0),

    CONSTRAINT ck_compra_detalle_descuento
        CHECK (descuento >= 0),

    CONSTRAINT ck_compra_detalle_impuesto
        CHECK (impuesto >= 0),

    CONSTRAINT ck_compra_detalle_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT ck_compra_detalle_total
        CHECK (total >= 0)
);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_proveedor_empresa
    ON compras.proveedor (empresa_id);

CREATE INDEX IF NOT EXISTS ix_proveedor_activo
    ON compras.proveedor (empresa_id, activo);

CREATE INDEX IF NOT EXISTS ix_compra_empresa
    ON compras.compra (empresa_id);

CREATE INDEX IF NOT EXISTS ix_compra_sucursal
    ON compras.compra (sucursal_id);

CREATE INDEX IF NOT EXISTS ix_compra_proveedor
    ON compras.compra (proveedor_id);

CREATE INDEX IF NOT EXISTS ix_compra_fecha
    ON compras.compra (fecha_compra);

CREATE INDEX IF NOT EXISTS ix_compra_estado
    ON compras.compra (estado);

CREATE INDEX IF NOT EXISTS ix_compra_detalle_compra
    ON compras.compra_detalle (compra_id);

CREATE INDEX IF NOT EXISTS ix_compra_detalle_producto
    ON compras.compra_detalle (producto_id);


COMMIT;