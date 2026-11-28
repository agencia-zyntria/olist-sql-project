USE olist;

-- QUESTION 3
-- Which Brazilian customer states have the most delayed orders?


WITH eligible_orders AS (
    SELECT
        order_id,
        customer_id,
        CASE
            WHEN DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)
            THEN 1
            ELSE 0
        END AS is_late
    FROM orders
    WHERE order_status = 'delivered'
      AND DATE(order_delivered_customer_date) IS NOT NULL
      AND DATE(order_estimated_delivery_date) IS NOT NULL
)
SELECT
    COALESCE(c.customer_state, 'unknown') AS customer_state,
    COUNT(*) AS delivered_orders,
    SUM(o.is_late) AS delayed_orders,
    ROUND(100.0 * SUM(o.is_late) / COUNT(*), 2) AS delayed_percentage
FROM eligible_orders AS o
LEFT JOIN customers AS c
    ON c.customer_id = o.customer_id
GROUP BY COALESCE(c.customer_state, 'unknown')
ORDER BY delayed_orders DESC, customer_state;


-- QUESTION 4
-- Which product categories accumulate delays or low ratings?


WITH order_categories AS (
    SELECT DISTINCT
        oi.order_id,
        p.product_category_name
    FROM order_items AS oi
    LEFT JOIN products AS p
        ON p.product_id = oi.product_id
),
ranked_reviews AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                review_answer_timestamp DESC,
                review_creation_date DESC,
                review_id DESC,
                review_score DESC
        ) AS review_position
    FROM order_reviews
),
latest_reviews AS (
    SELECT order_id, review_score
    FROM ranked_reviews
    WHERE review_position = 1
      AND review_score BETWEEN 1 AND 5
),
category_orders AS (
    SELECT
        oc.order_id,
        oc.product_category_name,
        COALESCE(
            ct.product_category_name_english,
            oc.product_category_name,
            'unknown'
        ) AS category_name,
        CASE
            WHEN DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)
            THEN 1
            ELSE 0
        END AS is_late,
        r.review_score
    FROM order_categories AS oc
    JOIN orders AS o
        ON o.order_id = oc.order_id
    LEFT JOIN category_translation AS ct
        ON ct.product_category_name = oc.product_category_name
    LEFT JOIN latest_reviews AS r
        ON r.order_id = oc.order_id
    WHERE o.order_status = 'delivered'
      AND DATE(o.order_delivered_customer_date) IS NOT NULL
      AND DATE(o.order_estimated_delivery_date) IS NOT NULL
)
SELECT
    product_category_name AS category_portuguese,
    category_name AS category,
    COUNT(*) AS delivered_orders,
    SUM(is_late) AS delayed_orders,
    ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS delayed_percentage,
    COUNT(review_score) AS reviewed_orders,
    ROUND(AVG(review_score), 2) AS average_review_score,
    SUM(CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END) AS low_rating_orders,
    ROUND(
        100.0 * SUM(CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END)
        / NULLIF(COUNT(review_score), 0),
        2
    ) AS low_rating_percentage,
    SUM(
        CASE WHEN is_late = 1 AND review_score IN (1, 2) THEN 1 ELSE 0 END
    ) AS delayed_low_rating_orders
FROM category_orders
GROUP BY product_category_name, category_name
ORDER BY delayed_orders DESC, category_name, product_category_name;


-- QUESTION 5
-- How much item revenue is associated with late orders with low ratings?


WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue
    FROM order_items
    GROUP BY order_id
),
ranked_reviews AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                review_answer_timestamp DESC,
                review_creation_date DESC,
                review_id DESC,
                review_score DESC
        ) AS review_position
    FROM order_reviews
),
latest_reviews AS (
    SELECT order_id, review_score
    FROM ranked_reviews
    WHERE review_position = 1
      AND review_score BETWEEN 1 AND 5
),
eligible_orders AS (
    SELECT
        o.order_id,
        r.review_score,
        v.item_revenue,
        CASE
            WHEN DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)
                 AND r.review_score IN (1, 2)
            THEN 1
            ELSE 0
        END AS is_at_risk
    FROM orders AS o
    LEFT JOIN order_revenue AS v
        ON v.order_id = o.order_id
    LEFT JOIN latest_reviews AS r
        ON r.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND DATE(o.order_delivered_customer_date) IS NOT NULL
      AND DATE(o.order_estimated_delivery_date) IS NOT NULL
)
SELECT
    COUNT(*) AS delivered_orders,
    COUNT(review_score) AS reviewed_orders,
    COUNT(item_revenue) AS orders_with_item_revenue,
    COALESCE(SUM(is_at_risk), 0) AS delayed_low_rating_orders,
    COALESCE(ROUND(SUM(item_revenue), 2), 0) AS total_item_revenue_brl,
    COALESCE(
        ROUND(SUM(CASE WHEN is_at_risk = 1 THEN item_revenue ELSE 0 END), 2),
        0
    ) AS at_risk_item_revenue_brl,
    ROUND(
        100.0 * SUM(CASE WHEN is_at_risk = 1 THEN item_revenue ELSE 0 END)
        / NULLIF(SUM(item_revenue), 0),
        2
    ) AS at_risk_revenue_percentage
FROM eligible_orders;
