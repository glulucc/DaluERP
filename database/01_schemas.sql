-- ============================================================
-- DALU ERP
-- Script: 01_schemas.sql
-- Descripción: Estructura lógica de la base de datos
-- PostgreSQL 17
-- ============================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS seguridad;
CREATE SCHEMA IF NOT EXISTS configuracion;
CREATE SCHEMA IF NOT EXISTS catalogo;
CREATE SCHEMA IF NOT EXISTS inventario;
CREATE SCHEMA IF NOT EXISTS compras;
CREATE SCHEMA IF NOT EXISTS ventas;
CREATE SCHEMA IF NOT EXISTS caja;
CREATE SCHEMA IF NOT EXISTS auditoria;

COMMIT;