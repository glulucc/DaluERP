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




INSERT INTO compras.proveedor
(
    empresa_id,
    codigo,
    nombre,
    identificacion,
    correo,
    telefono,
    contacto_nombre
)
SELECT
    empresa_id,
    'PROV-001',
    'Distribuidora Demo',
    'PROV-DEMO-001',
    'proveedor@demo.local',
    '0000-0000',
    'Proveedor Demo'
FROM configuracion.empresa
WHERE identificacion = 'DEMO-001'
ON CONFLICT (empresa_id, codigo) DO NOTHING;



SELECT
    proveedor_id,
    codigo,
    nombre
FROM compras.proveedor;


INSERT INTO compras.compra
(
    empresa_id,
    sucursal_id,
    proveedor_id,
    numero_documento,
    fecha_compra,
    subtotal,
    descuento,
    impuesto,
    total,
    estado,
    observaciones
)
SELECT
    e.empresa_id,
    s.sucursal_id,
    p.proveedor_id,
    'FAC-PROV-001',
    CURRENT_TIMESTAMP,
    5000.00,
    0.00,
    0.00,
    5000.00,
    'BORRADOR',
    'Compra de prueba de 10 Coca-Colas'
FROM configuracion.empresa e
JOIN configuracion.sucursal s
    ON s.empresa_id = e.empresa_id
JOIN compras.proveedor p
    ON p.empresa_id = e.empresa_id
WHERE e.identificacion = 'DEMO-001'
  AND s.codigo = 'MATRIZ'
  AND p.codigo = 'PROV-001'
RETURNING compra_id;


INSERT INTO compras.compra_detalle
(
    compra_id,
    producto_id,
    cantidad,
    costo_unitario,
    descuento,
    impuesto,
    subtotal,
    total
)
SELECT
    1,
    producto_id,
    10,
    500.00,
    0.00,
    0.00,
    5000.00,
    5000.00
FROM catalogo.producto
WHERE codigo = 'BEB-001';


SELECT
    cd.compra_detalle_id,
    cd.compra_id,
    p.codigo,
    p.nombre,
    cd.cantidad,
    cd.costo_unitario,
    cd.total
FROM compras.compra_detalle cd
JOIN catalogo.producto p
    ON p.producto_id = cd.producto_id;

UPDATE compras.compra
SET
    estado = 'CONFIRMADA',
    actualizado_en = CURRENT_TIMESTAMP
WHERE compra_id = 1;

SELECT
    compra_id,
    numero_documento,
    estado,
    total
FROM compras.compra;

--registar inventario
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
    referencia_id,
    motivo
)
SELECT
    c.empresa_id,
    c.sucursal_id,
    a.almacen_id,
    cd.producto_id,
    'ENTRADA',
    cd.cantidad,
    cd.costo_unitario,
    'COMPRA',
    c.compra_id,
    'Entrada por compra'
FROM compras.compra c
JOIN compras.compra_detalle cd
    ON cd.compra_id = c.compra_id
JOIN inventario.almacen a
    ON a.sucursal_id = c.sucursal_id
JOIN catalogo.producto p
    ON p.producto_id = cd.producto_id
WHERE c.compra_id = 1
  AND c.estado = 'CONFIRMADA'
  AND a.codigo = 'ALM-01';


  --actualizar costo y promedio
  UPDATE inventario.existencia ex
SET
    costo_promedio =
        (
            (ex.cantidad * ex.costo_promedio)
            +
            (10 * 500.00)
        )
        /
        (ex.cantidad + 10),

    cantidad = ex.cantidad + 10,

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


--crear cliente
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'ventas'
ORDER BY table_name;

INSERT INTO ventas.cliente
(
    empresa_id,
    codigo,
    nombre,
    identificacion,
    correo,
    telefono
)
SELECT
    empresa_id,
    'CLI-001',
    'Cliente Demo',
    'CLI-DEMO-001',
    'cliente@demo.local',
    '0000-0000'
FROM configuracion.empresa
WHERE identificacion = 'DEMO-001'
ON CONFLICT (empresa_id, codigo) DO NOTHING;

SELECT
    cliente_id,
    codigo,
    nombre
FROM ventas.cliente;



INSERT INTO ventas.venta
(
    empresa_id,
    sucursal_id,
    cliente_id,
    numero_documento,
    fecha_venta,
    subtotal,
    descuento,
    impuesto,
    total,
    costo_total,
    ganancia_bruta,
    estado,
    observaciones
)
SELECT
    e.empresa_id,
    s.sucursal_id,
    c.cliente_id,
    'VENTA-0001',
    CURRENT_TIMESTAMP,
    1600.00,
    0.00,
    0.00,
    1600.00,
    935.71,
    664.29,
    'BORRADOR',
    'Primera venta de prueba'
FROM configuracion.empresa e
JOIN configuracion.sucursal s
    ON s.empresa_id = e.empresa_id
JOIN ventas.cliente c
    ON c.empresa_id = e.empresa_id
WHERE e.identificacion = 'DEMO-001'
  AND s.codigo = 'MATRIZ'
  AND c.codigo = 'CLI-001'
RETURNING venta_id;


INSERT INTO ventas.venta_detalle
(
    venta_id,
    producto_id,
    cantidad,
    precio_unitario,
    costo_unitario,
    descuento,
    impuesto,
    subtotal,
    total,
    costo_total,
    ganancia_bruta
)
SELECT
    1,
    p.producto_id,
    2,
    800.00,
    ex.costo_promedio,
    0.00,
    0.00,
    1600.00,
    1600.00,
    ROUND(2 * ex.costo_promedio, 2),
    ROUND(1600.00 - (2 * ex.costo_promedio), 2)
FROM catalogo.producto p
JOIN inventario.existencia ex
    ON ex.producto_id = p.producto_id
JOIN inventario.almacen a
    ON a.almacen_id = ex.almacen_id
WHERE p.codigo = 'BEB-001'
  AND a.codigo = 'ALM-01';



  SELECT
    vd.venta_detalle_id,
    p.codigo,
    p.nombre,
    vd.cantidad,
    vd.precio_unitario,
    vd.costo_unitario,
    vd.total,
    vd.costo_total,
    vd.ganancia_bruta
FROM ventas.venta_detalle vd
JOIN catalogo.producto p
    ON p.producto_id = vd.producto_id
WHERE vd.venta_id = 1;


UPDATE ventas.venta
SET
    estado = 'CONFIRMADA',
    actualizado_en = CURRENT_TIMESTAMP
WHERE venta_id = 1;

SELECT
    venta_id,
    numero_documento,
    estado,
    total,
    costo_total,
    ganancia_bruta
FROM ventas.venta
WHERE venta_id = 1;

--registra en inventario
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
    referencia_id,
    motivo
)
SELECT
    v.empresa_id,
    v.sucursal_id,
    a.almacen_id,
    vd.producto_id,
    'SALIDA',
    vd.cantidad,
    vd.costo_unitario,
    'VENTA',
    v.venta_id,
    'Salida por venta'
FROM ventas.venta v
JOIN ventas.venta_detalle vd
    ON vd.venta_id = v.venta_id
JOIN inventario.almacen a
    ON a.sucursal_id = v.sucursal_id
WHERE v.venta_id = 1
  AND v.estado = 'CONFIRMADA'
  AND a.codigo = 'ALM-01';



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
    v.numero_documento,
    c.nombre AS cliente,
    p.nombre AS producto,
    vd.cantidad,
    vd.precio_unitario,
    vd.costo_unitario,
    vd.total,
    vd.costo_total,
    vd.ganancia_bruta
FROM ventas.venta v
JOIN ventas.cliente c
    ON c.cliente_id = v.cliente_id
JOIN ventas.venta_detalle vd
    ON vd.venta_id = v.venta_id
JOIN catalogo.producto p
    ON p.producto_id = vd.producto_id
WHERE v.numero_documento = 'VENTA-0001';



-- para montar el codigo
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'catalogo'
  AND table_name = 'producto'
ORDER BY ordinal_position;


SELECT
    column_name,
    constraint_name
FROM information_schema.key_column_usage
WHERE table_schema = 'catalogo'
  AND table_name = 'producto'
ORDER BY ordinal_position;


SELECT
    column_name,
    column_default
FROM information_schema.columns
WHERE table_schema = 'catalogo'
  AND table_name = 'producto'
ORDER BY ordinal_position;


SELECT
    column_name,
    data_type,
    column_default,
    is_identity
FROM information_schema.columns
WHERE table_schema = 'catalogo'
  AND table_name = 'producto'
  AND column_name = 'producto_id';


  SELECT
    pg_get_serial_sequence('catalogo.producto', 'producto_id');

UPDATE catalogo.producto
SET
    creado_en = CURRENT_TIMESTAMP,
    actualizado_en = CURRENT_TIMESTAMP
WHERE producto_id = 2;


select * from catalogo.producto;


SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;



SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE
    (table_schema = 'configuracion' AND table_name = 'empresa')
    OR
    (table_schema = 'catalogo' AND table_name = 'categoria')
    OR
    (table_schema = 'catalogo' AND table_name = 'unidad_medida')
ORDER BY
    table_schema,
    table_name,
    ordinal_position;



	SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'seguridad';



SELECT *
FROM seguridad.categoria_usuario;


SELECT *
FROM seguridad.usuario;

UPDATE seguridad.usuario
SET password_hash = 'AQAAAAIAAYagAAAAEMnumzsSXWk1SSMuwXT2805zVzvzsOidMjYijcNFjQqZr+ShX8RDGHcvBWjiNVqgvw=='
WHERE usuario_id = 1
  AND correo_normalizado = 'ADMIN@DALUERP.LOCAL';

SELECT
    usuario_id,
    correo,
    password_hash,
    activa
FROM seguridad.usuario
WHERE usuario_id = 1;


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'seguridad'
ORDER BY table_name;



INSERT INTO seguridad.categoria_usuario
    (codigo, nombre, descripcion)
VALUES
    ('ADMINISTRACION', 'Administración', 'Personal administrativo y de gestión.'),
    ('VENTAS', 'Ventas', 'Personal encargado de ventas y atención comercial.'),
    ('COCINA', 'Cocina', 'Personal encargado de cocina y producción.'),
    ('TRANSPORTE', 'Transporte', 'Personal encargado de transporte y entregas.'),
    ('INVENTARIO', 'Inventario', 'Personal encargado de inventarios y bodegas.'),
    ('COMPRAS', 'Compras', 'Personal encargado de compras y proveedores.'),
    ('CONTABILIDAD', 'Contabilidad', 'Personal encargado de procesos contables y financieros.'),
    ('OTRO', 'Otro', 'Personal que no pertenece a una categoría específica.');



SELECT
    categoria_usuario_id,
    codigo,
    nombre,
    activa
FROM seguridad.categoria_usuario
ORDER BY categoria_usuario_id;



INSERT INTO seguridad.permiso
    (codigo, nombre, modulo, descripcion)
VALUES

-- PRODUCTOS
('PRODUCTOS_VER',        'Ver productos',        'PRODUCTOS', 'Permite consultar productos.'),
('PRODUCTOS_CREAR',      'Crear productos',      'PRODUCTOS', 'Permite crear productos.'),
('PRODUCTOS_EDITAR',     'Editar productos',     'PRODUCTOS', 'Permite modificar productos.'),
('PRODUCTOS_ELIMINAR',   'Eliminar productos',   'PRODUCTOS', 'Permite eliminar productos.'),

-- CLIENTES
('CLIENTES_VER',         'Ver clientes',         'CLIENTES', 'Permite consultar clientes.'),
('CLIENTES_CREAR',       'Crear clientes',       'CLIENTES', 'Permite crear clientes.'),
('CLIENTES_EDITAR',      'Editar clientes',      'CLIENTES', 'Permite modificar clientes.'),
('CLIENTES_ELIMINAR',    'Eliminar clientes',    'CLIENTES', 'Permite eliminar clientes.'),

-- PROVEEDORES
('PROVEEDORES_VER',      'Ver proveedores',      'PROVEEDORES', 'Permite consultar proveedores.'),
('PROVEEDORES_CREAR',    'Crear proveedores',    'PROVEEDORES', 'Permite crear proveedores.'),
('PROVEEDORES_EDITAR',   'Editar proveedores',   'PROVEEDORES', 'Permite modificar proveedores.'),
('PROVEEDORES_ELIMINAR', 'Eliminar proveedores', 'PROVEEDORES', 'Permite eliminar proveedores.'),

-- VENTAS
('VENTAS_VER',           'Ver ventas',           'VENTAS', 'Permite consultar ventas.'),
('VENTAS_CREAR',         'Crear ventas',         'VENTAS', 'Permite registrar ventas.'),
('VENTAS_EDITAR',        'Editar ventas',        'VENTAS', 'Permite modificar ventas.'),
('VENTAS_ANULAR',        'Anular ventas',        'VENTAS', 'Permite anular ventas.'),

-- COMPRAS
('COMPRAS_VER',          'Ver compras',          'COMPRAS', 'Permite consultar compras.'),
('COMPRAS_CREAR',        'Crear compras',        'COMPRAS', 'Permite registrar compras.'),
('COMPRAS_EDITAR',       'Editar compras',       'COMPRAS', 'Permite modificar compras.'),
('COMPRAS_ANULAR',       'Anular compras',       'COMPRAS', 'Permite anular compras.'),

-- INVENTARIO
('INVENTARIO_VER',       'Ver inventario',       'INVENTARIO', 'Permite consultar existencias e inventario.'),
('INVENTARIO_AJUSTAR',   'Ajustar inventario',   'INVENTARIO', 'Permite realizar ajustes de inventario.'),
('INVENTARIO_ENTRADAS',  'Registrar entradas',   'INVENTARIO', 'Permite registrar entradas de inventario.'),
('INVENTARIO_SALIDAS',   'Registrar salidas',    'INVENTARIO', 'Permite registrar salidas de inventario.'),

-- USUARIOS
('USUARIOS_VER',         'Ver usuarios',         'USUARIOS', 'Permite consultar usuarios.'),
('USUARIOS_CREAR',       'Crear usuarios',       'USUARIOS', 'Permite crear usuarios.'),
('USUARIOS_EDITAR',      'Editar usuarios',      'USUARIOS', 'Permite modificar usuarios.'),
('USUARIOS_DESACTIVAR',  'Desactivar usuarios',  'USUARIOS', 'Permite desactivar usuarios.'),

-- EMPRESAS
('EMPRESAS_VER',         'Ver empresas',         'EMPRESAS', 'Permite consultar empresas.'),
('EMPRESAS_CREAR',       'Crear empresas',       'EMPRESAS', 'Permite crear empresas.'),
('EMPRESAS_EDITAR',      'Editar empresas',      'EMPRESAS', 'Permite modificar empresas.'),
('EMPRESAS_DESACTIVAR',  'Desactivar empresas',  'EMPRESAS', 'Permite desactivar empresas.'),

-- ROLES
('ROLES_VER',            'Ver roles',            'SEGURIDAD', 'Permite consultar roles.'),
('ROLES_CREAR',          'Crear roles',          'SEGURIDAD', 'Permite crear roles.'),
('ROLES_EDITAR',         'Editar roles',         'SEGURIDAD', 'Permite modificar roles.'),
('ROLES_ELIMINAR',       'Eliminar roles',       'SEGURIDAD', 'Permite eliminar roles.'),

-- PERMISOS
('PERMISOS_VER',         'Ver permisos',         'SEGURIDAD', 'Permite consultar permisos.');




SELECT
    permiso_id,
    codigo,
    nombre,
    modulo,
    activo
FROM seguridad.permiso
ORDER BY permiso_id;



INSERT INTO seguridad.rol
    (empresa_id, codigo, nombre, descripcion, es_global, activo)
VALUES
    (
        NULL,
        'SUPERADMIN',
        'Super Administrador',
        'Administrador global de DaluERP con acceso a todas las empresas y funciones del sistema.',
        TRUE,
        TRUE
    );


SELECT
    rol_id,
    empresa_id,
    codigo,
    nombre,
    es_global,
    activo
FROM seguridad.rol
WHERE codigo = 'SUPERADMIN';


SELECT COUNT(*)
FROM seguridad.permiso
WHERE activo = TRUE;


SELECT
    permiso_id,
    codigo,
    nombre,
    modulo
FROM seguridad.permiso
ORDER BY permiso_id;


SELECT codigo
FROM seguridad.permiso
ORDER BY codigo;



--Ahora asignamos los 37 al SUPERADMIN

--Como queremos que SUPERADMIN tenga acceso total, podemos hacerlo de una vez:

INSERT INTO seguridad.rol_permiso (rol_id, permiso_id)
SELECT
    r.rol_id,
    p.permiso_id
FROM seguridad.rol r
CROSS JOIN seguridad.permiso p
WHERE r.codigo = 'SUPERADMIN'
  AND p.activo = TRUE;


SELECT COUNT(*) AS cantidad_permisos
FROM seguridad.rol_permiso rp
INNER JOIN seguridad.rol r
    ON r.rol_id = rp.rol_id
WHERE r.codigo = 'SUPERADMIN';

SELECT
    r.codigo AS rol,
    p.codigo AS permiso,
    p.modulo
FROM seguridad.rol_permiso rp
INNER JOIN seguridad.rol r
    ON r.rol_id = rp.rol_id
INNER JOIN seguridad.permiso p
    ON p.permiso_id = rp.permiso_id
WHERE r.codigo = 'SUPERADMIN'
ORDER BY p.modulo, p.codigo;



INSERT INTO seguridad.usuario
    (
        categoria_usuario_id,
        nombre,
        correo,
        correo_normalizado,
        password_hash,
        activa
    )
VALUES
    (
        (
            SELECT categoria_usuario_id
            FROM seguridad.categoria_usuario
            WHERE codigo = 'ADMINISTRACION'
        ),
        'Super Administrador',
        'admin@daluerp.local',
        'ADMIN@DALUERP.LOCAL',
        'PENDIENTE_DE_HASH',
        TRUE
    );


	SELECT
    usuario_id,
    nombre,
    correo,
    activa
FROM seguridad.usuario
WHERE correo_normalizado = 'ADMIN@DALUERP.LOCAL';


INSERT INTO seguridad.usuario_rol
    (usuario_id, rol_id)
SELECT
    u.usuario_id,
    r.rol_id
FROM seguridad.usuario u
CROSS JOIN seguridad.rol r
WHERE u.correo_normalizado = 'ADMIN@DALUERP.LOCAL'
  AND r.codigo = 'SUPERADMIN'
  AND r.es_global = TRUE;


  SELECT
    u.nombre AS usuario,
    u.correo,
    r.codigo AS rol,
    r.nombre AS nombre_rol,
    r.es_global
FROM seguridad.usuario_rol ur
INNER JOIN seguridad.usuario u
    ON u.usuario_id = ur.usuario_id
INNER JOIN seguridad.rol r
    ON r.rol_id = ur.rol_id;



	INSERT INTO seguridad.rol
    (empresa_id, codigo, nombre, descripcion, es_global, activo)
VALUES
    (
        NULL,
        'ADMIN_EMPRESA',
        'Administrador de Empresa',
        'Administrador con control sobre la operación de una empresa.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'ADMINISTRATIVO',
        'Administrativo',
        'Usuario encargado de tareas administrativas.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'VENDEDOR',
        'Vendedor',
        'Usuario encargado de ventas y atención a clientes.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'SUPERVISOR_VENTAS',
        'Supervisor de Ventas',
        'Usuario encargado de supervisar las operaciones de ventas.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'COCINERO',
        'Cocinero',
        'Usuario encargado de operaciones de cocina y producción.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'INVENTARIO',
        'Encargado de Inventario',
        'Usuario encargado del control y movimientos de inventario.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'COMPRAS',
        'Encargado de Compras',
        'Usuario encargado de compras y proveedores.',
        TRUE,
        TRUE
    ),
    (
        NULL,
        'TRANSPORTE',
        'Transportista',
        'Usuario encargado de transporte y entregas.',
        TRUE,
        TRUE
    );


	SELECT
    rol_id,
    empresa_id,
    codigo,
    nombre,
    es_global,
    activo
FROM seguridad.rol
ORDER BY rol_id;


SELECT
    r.codigo AS rol,
    r.nombre,
    r.es_global,
    COUNT(rp.permiso_id) AS cantidad_permisos
FROM seguridad.rol r
LEFT JOIN seguridad.rol_permiso rp
    ON rp.rol_id = r.rol_id
GROUP BY
    r.rol_id,
    r.codigo,
    r.nombre,
    r.es_global
ORDER BY r.rol_id;

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'seguridad'
  AND table_name = 'categoria_usuario'
ORDER BY ordinal_position;

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'seguridad'
  AND table_name = 'usuario'
ORDER BY ordinal_position;



SELECT
    u.nombre AS usuario,
    u.correo,
    r.codigo AS rol,
    r.nombre AS nombre_rol,
    r.es_global
FROM seguridad.usuario_rol ur
INNER JOIN seguridad.usuario u
    ON u.usuario_id = ur.usuario_id
INNER JOIN seguridad.rol r
    ON r.rol_id = ur.rol_id
WHERE u.correo_normalizado = 'ADMIN@DALUERP.LOCAL';