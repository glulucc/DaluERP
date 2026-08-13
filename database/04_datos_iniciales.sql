-- ============================================================
-- DALU ERP
-- Script: 04_datos_iniciales.sql
-- Descripción: Datos iniciales para desarrollo
-- PostgreSQL 17
-- ============================================================

BEGIN;

-- ============================================================
-- UNIDADES DE MEDIDA
-- ============================================================

INSERT INTO catalogo.unidad_medida
(
    codigo,
    nombre,
    abreviatura,
    permite_decimales
)
VALUES
    ('UN', 'Unidad', 'un', FALSE),
    ('KG', 'Kilogramo', 'kg', TRUE),
    ('G',  'Gramo', 'g', TRUE),
    ('L',  'Litro', 'l', TRUE),
    ('ML', 'Mililitro', 'ml', TRUE),
    ('M',  'Metro', 'm', TRUE),
    ('CM', 'Centímetro', 'cm', TRUE),
    ('CAJ', 'Caja', 'caja', FALSE),
    ('PAQ', 'Paquete', 'paq', FALSE)
ON CONFLICT (codigo) DO NOTHING;


-- ============================================================
-- EMPRESA DE DESARROLLO
-- ============================================================

INSERT INTO configuracion.empresa
(
    nombre,
    nombre_comercial,
    identificacion,
    correo,
    telefono,
    direccion,
    moneda_codigo,
    zona_horaria
)
VALUES
(
    'Empresa Demo Dalú',
    'Dalú Demo',
    'DEMO-001',
    'demo@dalu.local',
    '0000-0000',
    'Dirección de desarrollo',
    'CRC',
    'America/Costa_Rica'
)
ON CONFLICT (identificacion) DO NOTHING;


-- ============================================================
-- SUCURSAL PRINCIPAL
-- ============================================================

INSERT INTO configuracion.sucursal
(
    empresa_id,
    codigo,
    nombre,
    correo,
    telefono,
    direccion
)
SELECT
    empresa_id,
    'MATRIZ',
    'Sucursal Principal',
    correo,
    telefono,
    direccion
FROM configuracion.empresa
WHERE identificacion = 'DEMO-001'
  AND NOT EXISTS
  (
      SELECT 1
      FROM configuracion.sucursal s
      WHERE s.empresa_id = configuracion.empresa.empresa_id
        AND s.codigo = 'MATRIZ'
  );


-- ============================================================
-- CATEGORÍAS
-- ============================================================

INSERT INTO catalogo.categoria
(
    empresa_id,
    codigo,
    nombre,
    descripcion
)
SELECT
    empresa_id,
    datos.codigo,
    datos.nombre,
    datos.descripcion
FROM configuracion.empresa e
CROSS JOIN
(
    VALUES
        ('BEBIDAS',     'Bebidas',     'Bebidas frías y calientes'),
        ('POLLO',       'Pollo',       'Productos de pollo'),
        ('PIZZAS',      'Pizzas',      'Pizzas y productos relacionados'),
        ('INGREDIENTES','Ingredientes','Ingredientes utilizados en recetas'),
        ('INSUMOS',     'Insumos',     'Materiales e insumos operativos'),
        ('EMPAQUES',    'Empaques',    'Bolsas, cajas y empaques')
) AS datos(codigo, nombre, descripcion)
WHERE e.identificacion = 'DEMO-001'
ON CONFLICT (empresa_id, codigo) DO NOTHING;


COMMIT;