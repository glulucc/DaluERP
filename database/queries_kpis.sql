--kpi principal
SELECT
    COUNT(DISTINCT v.venta_id) AS cantidad_ventas,

    COALESCE(SUM(v.total), 0) AS ventas_totales,

    COALESCE(SUM(v.costo_total), 0) AS costo_ventas,

    COALESCE(SUM(v.ganancia_bruta), 0) AS ganancia_bruta,

    CASE
        WHEN COALESCE(SUM(v.total), 0) = 0 THEN 0
        ELSE
            ROUND(
                (
                    SUM(v.ganancia_bruta)
                    / SUM(v.total)
                ) * 100,
                2
            )
    END AS margen_porcentaje

FROM ventas.venta v

WHERE v.estado = 'CONFIRMADA'
  AND v.fecha_venta >= CURRENT_DATE
  AND v.fecha_venta < CURRENT_DATE + INTERVAL '1 day';


--kpis inventario
SELECT
    COUNT(*) AS productos_con_existencia,

    COALESCE(SUM(ex.cantidad), 0) AS unidades_en_inventario,

    COALESCE(
        SUM(ex.cantidad * ex.costo_promedio),
        0
    ) AS valor_inventario

FROM inventario.existencia ex;

--producto bajo minimo
SELECT
    p.codigo,
    p.nombre,
    ex.cantidad AS existencia,
    p.stock_minimo,
    (p.stock_minimo - ex.cantidad) AS faltante

FROM inventario.existencia ex

JOIN catalogo.producto p
    ON p.producto_id = ex.producto_id

WHERE ex.cantidad <= p.stock_minimo

ORDER BY
    (p.stock_minimo - ex.cantidad) DESC;


--kpis juntas
WITH ventas_periodo AS
(
    SELECT
        COUNT(DISTINCT venta_id) AS cantidad_ventas,
        COALESCE(SUM(total), 0) AS ventas_totales,
        COALESCE(SUM(costo_total), 0) AS costo_ventas,
        COALESCE(SUM(ganancia_bruta), 0) AS ganancia_bruta

    FROM ventas.venta

    WHERE estado = 'CONFIRMADA'
      AND fecha_venta >= CURRENT_DATE
      AND fecha_venta < CURRENT_DATE + INTERVAL '1 day'
),

inventario_actual AS
(
    SELECT
        COUNT(*) AS productos_con_existencia,

        COALESCE(
            SUM(cantidad),
            0
        ) AS unidades_en_inventario,

        COALESCE(
            SUM(cantidad * costo_promedio),
            0
        ) AS valor_inventario

    FROM inventario.existencia
),

productos_bajo_minimo AS
(
    SELECT
        COUNT(*) AS cantidad_productos_bajo_minimo

    FROM inventario.existencia ex

    JOIN catalogo.producto p
        ON p.producto_id = ex.producto_id

    WHERE ex.cantidad <= p.stock_minimo
)

SELECT
    v.cantidad_ventas,

    ROUND(v.ventas_totales, 2)
        AS ventas_totales,

    ROUND(v.costo_ventas, 2)
        AS costo_ventas,

    ROUND(v.ganancia_bruta, 2)
        AS ganancia_bruta,

    CASE
        WHEN v.ventas_totales = 0 THEN 0
        ELSE ROUND(
            (v.ganancia_bruta / v.ventas_totales) * 100,
            2
        )
    END AS margen_porcentaje,

    i.productos_con_existencia,

    i.unidades_en_inventario,

    ROUND(i.valor_inventario, 2)
        AS valor_inventario,

    p.cantidad_productos_bajo_minimo

FROM ventas_periodo v
CROSS JOIN inventario_actual i
CROSS JOIN productos_bajo_minimo p;