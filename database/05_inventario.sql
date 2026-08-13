-- ============================================================
-- DALU ERP
-- Script: 05_inventario.sql
-- Descripción: Almacenes, existencias y movimientos
-- PostgreSQL 17
-- ============================================================

BEGIN;


-- ============================================================
-- TABLA: inventario.almacen
-- Lugares físicos donde se almacena inventario.
-- ============================================================

CREATE TABLE IF NOT EXISTS inventario.almacen
(
    almacen_id          BIGINT GENERATED ALWAYS AS IDENTITY,
    empresa_id          BIGINT NOT NULL,
    sucursal_id         BIGINT NOT NULL,

    codigo              VARCHAR(30) NOT NULL,
    nombre              VARCHAR(100) NOT NULL,
    descripcion         VARCHAR(250),

    activo              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_almacen
        PRIMARY KEY (almacen_id),

    CONSTRAINT fk_almacen_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT fk_almacen_sucursal
        FOREIGN KEY (sucursal_id)
        REFERENCES configuracion.sucursal (sucursal_id),

    CONSTRAINT uq_almacen_empresa_codigo
        UNIQUE (empresa_id, codigo)
);


-- ============================================================
-- TABLA: inventario.existencia
--
-- Representa la cantidad actual de cada producto en cada
-- almacén.
--
-- Ejemplo:
--
-- Almacén: COCINA
-- Producto: Queso Mozzarella
-- Cantidad: 25.500 KG
-- ============================================================

CREATE TABLE IF NOT EXISTS inventario.existencia
(
    existencia_id       BIGINT GENERATED ALWAYS AS IDENTITY,

    almacen_id          BIGINT NOT NULL,
    producto_id         BIGINT NOT NULL,

    cantidad            NUMERIC(18,4) NOT NULL DEFAULT 0,

    costo_promedio      NUMERIC(18,4) NOT NULL DEFAULT 0,

    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_existencia
        PRIMARY KEY (existencia_id),

    CONSTRAINT fk_existencia_almacen
        FOREIGN KEY (almacen_id)
        REFERENCES inventario.almacen (almacen_id),

    CONSTRAINT fk_existencia_producto
        FOREIGN KEY (producto_id)
        REFERENCES catalogo.producto (producto_id),

    CONSTRAINT uq_existencia_almacen_producto
        UNIQUE (almacen_id, producto_id),

    CONSTRAINT ck_existencia_cantidad
        CHECK (cantidad >= 0),

    CONSTRAINT ck_existencia_costo
        CHECK (costo_promedio >= 0)
);


-- ============================================================
-- TABLA: inventario.movimiento_inventario
--
-- Historial de todos los movimientos.
--
-- IMPORTANTE:
-- Esta tabla es el historial.
--
-- La existencia representa el estado actual.
-- El movimiento representa cómo llegamos a ese estado.
-- ============================================================

CREATE TABLE IF NOT EXISTS inventario.movimiento_inventario
(
    movimiento_id          BIGINT GENERATED ALWAYS AS IDENTITY,

    empresa_id             BIGINT NOT NULL,
    sucursal_id            BIGINT NOT NULL,
    almacen_id             BIGINT NOT NULL,
    producto_id            BIGINT NOT NULL,

    tipo_movimiento        VARCHAR(30) NOT NULL,

    cantidad               NUMERIC(18,4) NOT NULL,

    costo_unitario         NUMERIC(18,4) NOT NULL DEFAULT 0,

    referencia_tipo        VARCHAR(50),
    referencia_id          BIGINT,

    motivo                 VARCHAR(250),

    fecha_movimiento       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    creado_por             BIGINT,

    creado_en              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_movimiento_inventario
        PRIMARY KEY (movimiento_id),

    CONSTRAINT fk_movimiento_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT fk_movimiento_sucursal
        FOREIGN KEY (sucursal_id)
        REFERENCES configuracion.sucursal (sucursal_id),

    CONSTRAINT fk_movimiento_almacen
        FOREIGN KEY (almacen_id)
        REFERENCES inventario.almacen (almacen_id),

    CONSTRAINT fk_movimiento_producto
        FOREIGN KEY (producto_id)
        REFERENCES catalogo.producto (producto_id),

    CONSTRAINT ck_movimiento_tipo
        CHECK
        (
            tipo_movimiento IN
            (
                'ENTRADA',
                'SALIDA',
                'AJUSTE_POSITIVO',
                'AJUSTE_NEGATIVO',
                'TRANSFERENCIA_ENTRADA',
                'TRANSFERENCIA_SALIDA',
                'MERMA'
            )
        ),

    CONSTRAINT ck_movimiento_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT ck_movimiento_costo
        CHECK (costo_unitario >= 0)
);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_almacen_empresa
    ON inventario.almacen (empresa_id);

CREATE INDEX IF NOT EXISTS ix_almacen_sucursal
    ON inventario.almacen (sucursal_id);

CREATE INDEX IF NOT EXISTS ix_existencia_producto
    ON inventario.existencia (producto_id);

CREATE INDEX IF NOT EXISTS ix_movimiento_empresa
    ON inventario.movimiento_inventario (empresa_id);

CREATE INDEX IF NOT EXISTS ix_movimiento_sucursal
    ON inventario.movimiento_inventario (sucursal_id);

CREATE INDEX IF NOT EXISTS ix_movimiento_almacen
    ON inventario.movimiento_inventario (almacen_id);

CREATE INDEX IF NOT EXISTS ix_movimiento_producto
    ON inventario.movimiento_inventario (producto_id);

CREATE INDEX IF NOT EXISTS ix_movimiento_fecha
    ON inventario.movimiento_inventario (fecha_movimiento);

CREATE INDEX IF NOT EXISTS ix_movimiento_referencia
    ON inventario.movimiento_inventario
    (
        referencia_tipo,
        referencia_id
    );


COMMIT;