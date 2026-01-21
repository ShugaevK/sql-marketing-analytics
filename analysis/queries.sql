/* SQL для маркетинга: Примеры запросов для анализа
   Этот файл содержит примеры SQL запросов для решения типичных задач в маркетинге:
   - когортный анализ
   - расчет KPI метрик (CTR, CPC, CPA, ROAS, Conversion Rate)
   - анализ трафика по источникам
   - анализ удержания пользователей (Retention)
   - сегментация клиентов (High-Value vs Low-Value)
*/

/* ============================================
   1. КОГОРТНЫЙ АНАЛИЗ (Cohort Analysis)
   ============================================
   Назначение: Группируем пользователей по дате регистрации (когорта)
               и анализируем их активность во времени
   
   Применение: - Определяем, какая когорта лучше всего удерживается
               - Оцениваем качество пользователей по периодам
               - Выявляем сезонные тренды
   
   Ключевые функции: DATE_TRUNC, COUNT DISTINCT, JOIN, GROUP BY
*/

SELECT 
    DATE_TRUNC('month', u.registration_date) AS cohort_month,
    DATE_TRUNC('month', e.event_date) AS event_month,
    COUNT(DISTINCT u.user_id) AS users_count
FROM users u
JOIN events e ON u.user_id = e.user_id
GROUP BY cohort_month, event_month
ORDER BY cohort_month, event_month;

/* Результат: Видим, сколько пользователей из каждой когорты активны в разные месяцы */


/* ============================================
   2. РАСЧЕТ KPI (CTR, CPC, CPA, ROAS, Conversion Rate)
   ============================================
   Назначение: Вычисляем основные метрики маркетолога для оценки эффективности
   
   Метрики:
   - CTR (Click Through Rate) = Клики / Показы * 100 (в процентах)
   - CPC (Cost Per Click) = Расходы / Клики (сколько стоит один клик)
   - CPA (Cost Per Action) = Расходы / Конверсии (стоимость привлечения клиента)
   - ROAS (Return On Ad Spend) = Доход / Расходы (окупаемость рекламы)
   - Conversion Rate = Конверсии / Клики * 100 (процент переходящих в покупку)
   
   Применение: - Сравниваем эффективность кампаний
               - Принимаем решения о масштабировании
               - Контролируем расходы
*/

SELECT 
    campaign_name,
    SUM(impressions) AS total_impressions,           /* Всего показов */
    SUM(clicks) AS total_clicks,                     /* Всего кликов */
    ROUND(SUM(clicks)::FLOAT / NULLIF(SUM(impressions), 0) * 100, 2) AS ctr_percent,
    SUM(cost) AS total_cost,                         /* Всего потрачено */
    ROUND(SUM(cost)::FLOAT / NULLIF(SUM(clicks), 0), 2) AS cpc,
    SUM(conversions) AS total_conversions,           /* Всего конверсий */
    ROUND(SUM(cost)::FLOAT / NULLIF(SUM(conversions), 0), 2) AS cpa,
    SUM(revenue) AS total_revenue,                   /* Всего заработано */
    ROUND(SUM(revenue)::FLOAT / NULLIF(SUM(cost), 0), 2) AS roas
FROM campaigns
GROUP BY campaign_name
HAVING SUM(conversions) > 0;

/* Результат: Видим, какие кампании работают эффективнее и где стоит сосредоточить бюджет */


/* ============================================
   3. АНАЛИЗ ТРАФИКА ПО КАНАЛАМ (Traffic Analysis by Channels)
   ============================================
   Назначение: Определяем, какие каналы и девайсы приносят больше всего трафика
               и какой процент трафика конвертируется
   
   Применение: - Оптимизируем инвестиции в разные каналы
               - Улучшаем UX для популярных девайсов
               - Выявляем проблемные каналы
   
   Ключевые функции: CASE WHEN, SUM, COUNT, GROUP BY
*/

SELECT 
    traffic_source,
    device_type,
    COUNT(*) AS sessions_count,
    SUM(CASE WHEN conversion = 1 THEN 1 ELSE 0 END) AS converted_sessions,
    ROUND(SUM(CASE WHEN conversion = 1 THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 2) AS conversion_rate
FROM sessions
GROUP BY traffic_source, device_type
ORDER BY sessions_count DESC;

/* Результат: Видим производительность каждого канала и устройства отдельно */


/* ============================================
   4. RETENTION АНАЛИЗ (Удержание пользователей)
   ============================================
   Назначение: Рассчитываем, какой процент пользователей возвращается
               на сайт и как часто они посещают его
   
   Применение: - Оцениваем качество продукта
               - Выявляем проблемы с юзабилити
               - Планируем re-engagement кампании
   
   Ключевые функции: WITH (CTE), MIN, COUNT DISTINCT, CASE WHEN
*/

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

/* Результат: Видим, как распределяются пользователи по группам удержания */


/* ============================================
   5. СЕГМЕНТАЦИЯ (High-Value vs Low-Value клиенты)
   ============================================
   Назначение: Разделяем клиентов на две группы:
               - High-Value: приносят выше среднего дохода
               - Low-Value: приносят ниже среднего дохода
   
   Применение: - Планируем целевые маркетинговые кампании
               - Оптимизируем затраты на привлечение
               - Выявляем VIP клиентов для специальной заботы
   
   Ключевые функции: CASE WHEN, AVG (подзапрос), GROUP BY
*/

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

/* Результат: Видим, как распределяются клиенты по стоимости и их характеристики */
