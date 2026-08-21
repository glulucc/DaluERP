INSERT INTO seguridad.rol_permiso (rol_id, permiso_id)
SELECT
    r.rol_id,
    p.permiso_id
FROM seguridad.rol r
CROSS JOIN seguridad.permiso p
WHERE r.codigo = 'ADMIN_EMPRESA'
  AND p.codigo IN (
      'PRODUCTOS_VER',
      'PRODUCTOS_CREAR',
      'PRODUCTOS_EDITAR',
      'PRODUCTOS_ELIMINAR',

      'CLIENTES_VER',
      'CLIENTES_CREAR',
      'CLIENTES_EDITAR',
      'CLIENTES_ELIMINAR',

      'PROVEEDORES_VER',
      'PROVEEDORES_CREAR',
      'PROVEEDORES_EDITAR',
      'PROVEEDORES_ELIMINAR',

      'VENTAS_VER',
      'VENTAS_CREAR',
      'VENTAS_EDITAR',
      'VENTAS_ANULAR',

      'COMPRAS_VER',
      'COMPRAS_CREAR',
      'COMPRAS_EDITAR',
      'COMPRAS_ANULAR',

      'INVENTARIO_VER',
      'INVENTARIO_AJUSTAR',
      'INVENTARIO_ENTRADAS',
      'INVENTARIO_SALIDAS',

      'USUARIOS_VER',
      'USUARIOS_CREAR',
      'USUARIOS_EDITAR',
      'USUARIOS_DESACTIVAR',

      'EMPRESAS_VER',

      'ROLES_VER',
      'ROLES_CREAR',
      'ROLES_EDITAR',
      'ROLES_ELIMINAR',

      'PERMISOS_VER'
  );