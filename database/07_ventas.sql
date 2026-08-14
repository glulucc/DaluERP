-- ============================================================
-- DALU ERP
-- Script: 07_ventas.sql
-- Descripción: Clientes y ventas
-- PostgreSQL 17
-- ============================================================

BEGIN;


-- ============================================================
-- TABLA: ventas.cliente
-- ============================================================

CREATE TABLE IF NOT EXISTS ventas.cliente
(
    cliente_id          BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id          BIGINT NOT NULL,

    codigo              VARCHAR(30) NOT NULL,
    nombre              VARCHAR(150) NOT NULL,

    identificacion      VARCHAR(30),
    correo              VARCHAR(150),
    telefono            VARCHAR(30),

    direccion           VARCHAR(500),

    activo              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_cliente
        PRIMARY KEY (cliente_id),

    CONSTRAINT fk_cliente_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT uq_cliente_empresa_codigo
        UNIQUE (empresa_id, codigo)
);


-- ============================================================
-- TABLA: ventas.venta
--
-- Encabezado de la venta.
-- ============================================================

CREATE TABLE IF NOT EXISTS ventas.venta
(
    venta_id                BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id              BIGINT NOT NULL,
    sucursal_id             BIGINT NOT NULL,
    cliente_id              BIGINT,

    numero_documento        VARCHAR(50),

    fecha_venta              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    subtotal                 NUMERIC(18,2) NOT NULL DEFAULT 0,
    descuento                NUMERIC(18,2) NOT NULL DEFAULT 0,
    impuesto                 NUMERIC(18,2) NOT NULL DEFAULT 0,

    total                    NUMERIC(18,2) NOT NULL DEFAULT 0,

    costo_total              NUMERIC(18,2) NOT NULL DEFAULT 0,
    ganancia_bruta            NUMERIC(18,2) NOT NULL DEFAULT 0,

    estado                   VARCHAR(20) NOT NULL DEFAULT 'BORRADOR',

    observaciones            VARCHAR(500),

    creado_en                TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_venta
        PRIMARY KEY (venta_id),

    CONSTRAINT fk_venta_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT fk_venta_sucursal
        FOREIGN KEY (sucursal_id)
        REFERENCES configuracion.sucursal (sucursal_id),

    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES ventas.cliente (cliente_id),

    CONSTRAINT ck_venta_estado
        CHECK
        (
            estado IN
            (
                'BORRADOR',
                'CONFIRMADA',
                'ANULADA'
            )
        ),

    CONSTRAINT ck_venta_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT ck_venta_descuento
        CHECK (descuento >= 0),

    CONSTRAINT ck_venta_impuesto
        CHECK (impuesto >= 0),

    CONSTRAINT ck_venta_total
        CHECK (total >= 0),

    CONSTRAINT ck_venta_costo
        CHECK (costo_total >= 0)
);


-- ============================================================
-- TABLA: ventas.venta_detalle
-- ============================================================

CREATE TABLE IF NOT EXISTS ventas.venta_detalle
(
    venta_detalle_id        BIGINT GENERATED ALWAYS AS IDENTITY,

    venta_id                BIGINT NOT NULL,
    producto_id             BIGINT NOT NULL,

    cantidad                NUMERIC(18,4) NOT NULL,

    precio_unitario         NUMERIC(18,4) NOT NULL,

    costo_unitario          NUMERIC(18,4) NOT NULL,

    descuento               NUMERIC(18,2) NOT NULL DEFAULT 0,

    impuesto                NUMERIC(18,2) NOT NULL DEFAULT 0,

    subtotal                NUMERIC(18,2) NOT NULL DEFAULT 0,

    total                   NUMERIC(18,2) NOT NULL DEFAULT 0,

    costo_total             NUMERIC(18,2) NOT NULL DEFAULT 0,

    ganancia_bruta          NUMERIC(18,2) NOT NULL DEFAULT 0,

    CONSTRAINT pk_venta_detalle
        PRIMARY KEY (venta_detalle_id),

    CONSTRAINT fk_venta_detalle_venta
        FOREIGN KEY (venta_id)
        REFERENCES ventas.venta (venta_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_venta_detalle_producto
        FOREIGN KEY (producto_id)
        REFERENCES catalogo.producto (producto_id),

    CONSTRAINT ck_venta_detalle_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT ck_venta_detalle_precio
        CHECK (precio_unitario >= 0),

    CONSTRAINT ck_venta_detalle_costo
        CHECK (costo_unitario >= 0),

    CONSTRAINT ck_venta_detalle_descuento
        CHECK (descuento >= 0),

    CONSTRAINT ck_venta_detalle_impuesto
        CHECK (impuesto >= 0),

    CONSTRAINT ck_venta_detalle_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT ck_venta_detalle_total
        CHECK (total >= 0),

    CONSTRAINT ck_venta_detalle_costo_total
        CHECK (costo_total >= 0)
);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_cliente_empresa
    ON ventas.cliente (empresa_id);

CREATE INDEX IF NOT EXISTS ix_cliente_activo
    ON ventas.cliente (empresa_id, activo);

CREATE INDEX IF NOT EXISTS ix_venta_empresa
    ON ventas.venta (empresa_id);

CREATE INDEX IF NOT EXISTS ix_venta_sucursal
    ON ventas.venta (sucursal_id);

CREATE INDEX IF NOT EXISTS ix_venta_cliente
    ON ventas.venta (cliente_id);

CREATE INDEX IF NOT EXISTS ix_venta_fecha
    ON ventas.venta (fecha_venta);

CREATE INDEX IF NOT EXISTS ix_venta_estado
    ON ventas.venta (estado);

CREATE INDEX IF NOT EXISTS ix_venta_detalle_venta
    ON ventas.venta_detalle (venta_id);

CREATE INDEX IF NOT EXISTS ix_venta_detalle_producto
    ON ventas.venta_detalle (producto_id);


COMMIT;