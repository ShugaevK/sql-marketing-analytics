-- SQL для маркетинга: Примеры запросов для анализа

-- 1. Когортный анализ (Cohort Analysis)
-- Группируем пользователей по дате регистрации и анализируем их активность

SELECT 
    DATE_TRUNC('month', u.registration_date) AS cohort_month,
    DATE_TRUNC('month', e.event_date) AS event_month,
    COUNT(DISTINCT u.user_id) AS users_count
FROM users u
JOIN events e ON u.user_id = e.user_id
GROUP BY cohort_month, event_month
ORDER BY cohort_month, event_month;

-- 2. Расчет KPI (CTR, CPC, CPA, ROAS, Conversion Rate)
-- Вычисляем основные метрики маркетолога

SELECT 
    campaign_name,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    ROUND(SUM(clicks)::FLOAT / NULLIF(SUM(impressions), 0) * 100, 2) AS ctr_percent,
    SUM(cost) AS total_cost,
    ROUND(SUM(cost)::FLOAT / NULLIF(SUM(clicks), 0), 2) AS cpc,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(cost)::FLOAT / NULLIF(SUM(conversions), 0), 2) AS cpa,
    SUM(revenue) AS total_revenue,
    ROUND(SUM(revenue)::FLOAT / NULLIF(SUM(cost), 0), 2) AS roas
FROM campaigns
GROUP BY campaign_name
HAVING SUM(conversions) > 0;

-- 3. Анализ трафика по каналам (Traffic Analysis by Channels)
-- Определяем, какие каналы приносят больше всего трафика

SELECT 
    traffic_source,
    device_type,
    COUNT(*) AS sessions_count,
    SUM(CASE WHEN conversion = 1 THEN 1 ELSE 0 END) AS converted_sessions,
    ROUND(SUM(CASE WHEN conversion = 1 THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 2) AS conversion_rate
FROM sessions
GROUP BY traffic_source, device_type
ORDER BY sessions_count DESC;

-- 4. Retention анализ (Удержание пользователей)
-- Рассчитываем, какой процент пользователей возвращается

WITH first_visit AS (
    SELECT 
        user_id,
        MIN(DATE(visit_date)) AS first_date
    FROM visits
    GROUP BY user_id
),
return_visits AS (
    SELECT 
        fv.user_id,
        COUNT(DISTINCT v.visit_date) AS visit_count
    FROM first_visit fv
    JOIN visits v ON fv.user_id = v.user_id AND v.visit_date > fv.first_date
    GROUP BY fv.user_id
)
SELECT 
    CASE 
        WHEN rv.visit_count IS NULL THEN 'Не вернулись'
        WHEN rv.visit_count = 1 THEN 'Вернулись 1 раз'
        WHEN rv.visit_count >= 2 AND rv.visit_count <= 4 THEN 'Вернулись 2-4 раза'
        ELSE 'Постоянные посетители'
    END AS retention_group,
    COUNT(DISTINCT fv.user_id) AS user_count,
    ROUND(COUNT(DISTINCT fv.user_id)::FLOAT / (SELECT COUNT(DISTINCT user_id) FROM first_visit) * 100, 2) AS percentage
FROM first_visit fv
LEFT JOIN return_visits rv ON fv.user_id = rv.user_id
GROUP BY retention_group;

-- 5. Сегментация (High-Value vs Low-Value клиенты)
-- Разделяем клиентов по стоимости

SELECT 
    CASE 
        WHEN lifetime_value >= (SELECT AVG(lifetime_value) FROM customers) THEN 'High-Value'
        ELSE 'Low-Value'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    AVG(lifetime_value) AS avg_ltv,
    SUM(purchases) AS total_purchases,
    AVG(purchase_frequency) AS avg_purchase_frequency
FROM customers
GROUP BY customer_segment;
