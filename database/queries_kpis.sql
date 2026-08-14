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