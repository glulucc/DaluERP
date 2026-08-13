-- ============================================================
-- DALU ERP
-- Script: 02_configuracion.sql
-- Descripción: Empresa y sucursales
-- PostgreSQL 17
-- ============================================================

BEGIN;

-- ============================================================
-- TABLA: configuracion.empresa
-- Representa una empresa que utiliza Dalú ERP.
-- ============================================================

CREATE TABLE IF NOT EXISTS configuracion.empresa
(
    empresa_id          BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR(150) NOT NULL,
    nombre_comercial    VARCHAR(150),
    identificacion      VARCHAR(30),
    correo              VARCHAR(150),
    telefono            VARCHAR(30),
    direccion           VARCHAR(500),
    moneda_codigo       CHAR(3) NOT NULL DEFAULT 'CRC',
    zona_horaria        VARCHAR(60) NOT NULL DEFAULT 'America/Costa_Rica',
    activa              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_empresa
        PRIMARY KEY (empresa_id),

    CONSTRAINT uq_empresa_identificacion
        UNIQUE (identificacion)
);


-- ============================================================
-- TABLA: configuracion.sucursal
-- Una empresa puede tener una o varias sucursales.
-- ============================================================

CREATE TABLE IF NOT EXISTS configuracion.sucursal
(
    sucursal_id         BIGINT GENERATED ALWAYS AS IDENTITY,
    empresa_id          BIGINT NOT NULL,

    codigo              VARCHAR(20) NOT NULL,
    nombre              VARCHAR(150) NOT NULL,

    identificacion      VARCHAR(30),
    correo              VARCHAR(150),
    telefono            VARCHAR(30),
    direccion           VARCHAR(500),

    activa              BOOLEAN NOT NULL DEFAULT TRUE,

    creado_en           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_sucursal
        PRIMARY KEY (sucursal_id),

    CONSTRAINT fk_sucursal_empresa
        FOREIGN KEY (empresa_id)
        REFERENCES configuracion.empresa (empresa_id),

    CONSTRAINT uq_sucursal_empresa_codigo
        UNIQUE (empresa_id, codigo)
);


-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_sucursal_empresa_id
    ON configuracion.sucursal (empresa_id);

CREATE INDEX IF NOT EXISTS ix_empresa_activa
    ON configuracion.empresa (activa);

CREATE INDEX IF NOT EXISTS ix_sucursal_activa
    ON configuracion.sucursal (activa);


COMMIT;