USE olist;

SELECT
    COUNT(*) AS total_pedidos_entregados,
    SUM(CASE WHEN DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date) THEN 1 ELSE 0 END) AS pedidos_tarde,
    SUM(CASE WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN 1 ELSE 0 END) AS pedidos_a_tiempo,
    ROUND(
        100.0 * SUM(CASE WHEN DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date) THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS porcentaje_tarde
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

SELECT
    CASE
        WHEN DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)
        THEN 'Tarde'
        ELSE 'A tiempo'
    END AS estado_entrega,
    COUNT(*) AS pedidos_con_resena,
    ROUND(AVG(r.review_score), 2) AS nota_media,
    ROUND(
        100.0 * SUM(CASE WHEN r.review_score IN (1, 2) THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS porcentaje_notas_bajas
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY estado_entrega;

WITH pedidos_ordenados AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp ASC
        ) AS num_pedido,
        CASE
            WHEN DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)
            THEN 1
            ELSE 0
        END AS es_tarde
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
),
resumen_clientes AS (
    SELECT
        customer_unique_id,
        COUNT(*) AS total_pedidos,
        MAX(CASE WHEN num_pedido = 1 THEN es_tarde END) AS primer_pedido_tarde
    FROM pedidos_ordenados
    GROUP BY customer_unique_id
)
SELECT
    CASE
        WHEN primer_pedido_tarde = 1 THEN 'Primer pedido tarde'
        ELSE 'Primer pedido a tiempo'
    END AS grupo_cliente,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN total_pedidos > 1 THEN 1 ELSE 0 END) AS clientes_que_repiten,
    ROUND(
        100.0 * SUM(CASE WHEN total_pedidos > 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS tasa_recompra_pct
FROM resumen_clientes
GROUP BY primer_pedido_tarde;