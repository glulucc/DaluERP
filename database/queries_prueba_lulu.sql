SELECT *
FROM configuracion.empresa;

SELECT *
FROM configuracion.sucursal;

SELECT codigo, nombre, abreviatura
FROM catalogo.unidad_medida
ORDER BY unidad_medida_id;

SELECT codigo, nombre
FROM catalogo.categoria
ORDER BY categoria_id;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'inventario'
ORDER BY table_name;


SELECT *
FROM inventario.almacen;



SELECT categoria_id, codigo, nombre
FROM catalogo.categoria
WHERE codigo = 'BEBIDAS';

SELECT unidad_medida_id, codigo, nombre
FROM catalogo.unidad_medida
WHERE codigo = 'UN';


INSERT INTO catalogo.producto
(
    empresa_id,
    categoria_id,
    unidad_medida_id,
    codigo,
    codigo_barras,
    nombre,
    descripcion,
    tipo_producto,
    es_vendible,
    es_inventariable,
    es_ingrediente,
    costo_actual,
    precio_base,
    stock_minimo,
    stock_maximo
)
SELECT
    e.empresa_id,
    c.categoria_id,
    u.unidad_medida_id,
    'BEB-001',
    '744000000001',
    'Coca-Cola 600ml',
    'Bebida gaseosa 600ml',
    'PRODUCTO',
    TRUE,
    TRUE,
    FALSE,
    450.00,
    800.00,
    10,
    100
FROM configuracion.empresa e
JOIN catalogo.categoria c
    ON c.empresa_id = e.empresa_id
JOIN catalogo.unidad_medida u
    ON u.codigo = 'UN'
WHERE e.identificacion = 'DEMO-001'
  AND c.codigo = 'BEBIDAS'
ON CONFLICT (empresa_id, codigo) DO NOTHING;


SELECT
    producto_id,
    codigo,
    nombre,
    costo_actual,
    precio_base
FROM catalogo.producto
WHERE codigo = 'BEB-001';


INSERT INTO inventario.existencia
(
    almacen_id,
    producto_id,
    cantidad,
    costo_promedio
)
SELECT
    a.almacen_id,
    p.producto_id,
    10,
    450.00
FROM inventario.almacen a
JOIN catalogo.producto p
    ON p.codigo = 'BEB-001'
JOIN configuracion.empresa e
    ON e.empresa_id = p.empresa_id
WHERE a.codigo = 'ALM-01'
  AND e.identificacion = 'DEMO-001'
ON CONFLICT (almacen_id, producto_id) DO NOTHING;

SELECT
    a.nombre AS almacen,
    p.codigo,
    p.nombre,
    ex.cantidad,
    ex.costo_promedio
FROM inventario.existencia ex
JOIN inventario.almacen a
    ON a.almacen_id = ex.almacen_id
JOIN catalogo.producto p
    ON p.producto_id = ex.producto_id;


INSERT INTO inventario.movimiento_inventario
(
    empresa_id,
    sucursal_id,
    almacen_id,
    producto_id,
    tipo_movimiento,
    cantidad,
    costo_unitario,
    referencia_tipo,
    motivo
)
SELECT
    e.empresa_id,
    s.sucursal_id,
    a.almacen_id,
    p.producto_id,
    'ENTRADA',
    10,
    450.00,
    'INICIAL',
    'Entrada inicial de inventario'
FROM configuracion.empresa e
JOIN configuracion.sucursal s
    ON s.empresa_id = e.empresa_id
JOIN inventario.almacen a
    ON a.sucursal_id = s.sucursal_id
JOIN catalogo.producto p
    ON p.empresa_id = e.empresa_id
WHERE e.identificacion = 'DEMO-001'
  AND s.codigo = 'MATRIZ'
  AND a.codigo = 'ALM-01'
  AND p.codigo = 'BEB-001';



 UPDATE inventario.existencia ex
SET
    cantidad = ex.cantidad + 10,
    costo_promedio = 450.00,
    actualizado_en = CURRENT_TIMESTAMP
WHERE ex.almacen_id = (
    SELECT a.almacen_id
    FROM inventario.almacen a
    WHERE a.codigo = 'ALM-01'
)
AND ex.producto_id = (
    SELECT p.producto_id
    FROM catalogo.producto p
    WHERE p.codigo = 'BEB-001'
);


SELECT
    p.codigo,
    p.nombre,
    ex.cantidad,
    ex.costo_promedio
FROM inventario.existencia ex
JOIN catalogo.producto p
    ON p.producto_id = ex.producto_id
WHERE p.codigo = 'BEB-001';



INSERT INTO inventario.movimiento_inventario
(
    empresa_id,
    sucursal_id,
    almacen_id,
    producto_id,
    tipo_movimiento,
    cantidad,
    costo_unitario,
    referencia_tipo,
    motivo
)
SELECT
    e.empresa_id,
    s.sucursal_id,
    a.almacen_id,
    p.producto_id,
    'SALIDA',
    2,
    450.00,
    'VENTA',
    'Salida por venta de prueba'
FROM configuracion.empresa e
JOIN configuracion.sucursal s
    ON s.empresa_id = e.empresa_id
JOIN inventario.almacen a
    ON a.sucursal_id = s.sucursal_id
JOIN catalogo.producto p
    ON p.empresa_id = e.empresa_id
WHERE e.identificacion = 'DEMO-001'
  AND s.codigo = 'MATRIZ'
  AND a.codigo = 'ALM-01'
  AND p.codigo = 'BEB-001';




  UPDATE inventario.existencia ex
SET
    cantidad = ex.cantidad - 2,
    actualizado_en = CURRENT_TIMESTAMP
WHERE ex.almacen_id = (
    SELECT almacen_id
    FROM inventario.almacen
    WHERE codigo = 'ALM-01'
)
AND ex.producto_id = (
    SELECT producto_id
    FROM catalogo.producto
    WHERE codigo = 'BEB-001'
);



SELECT
    p.codigo,
    p.nombre,
    ex.cantidad,
    ex.costo_promedio
FROM inventario.existencia ex
JOIN catalogo.producto p
    ON p.producto_id = ex.producto_id
WHERE p.codigo = 'BEB-001';


SELECT
    mi.movimiento_id,
    mi.fecha_movimiento,
    p.codigo,
    p.nombre,
    mi.tipo_movimiento,
    mi.cantidad,
    mi.costo_unitario,
    mi.referencia_tipo,
    mi.motivo
FROM inventario.movimiento_inventario mi
JOIN catalogo.producto p
    ON p.producto_id = mi.producto_id
WHERE p.codigo = 'BEB-001'
ORDER BY mi.movimiento_id;