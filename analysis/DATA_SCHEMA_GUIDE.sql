/* ============================================================
   DATABASE SCHEMA GUIDE: СТРУКТУРА БАЗЫ ДАННЫХ ДЛЯ МАРКЕТИНГА
   ============================================================
   
   ЭТО ПОЛНЫЙ ПУТЕВОДИТЕЛЬ ДЛЯ НАЧИНАЮЩИХ МАРКЕТОЛОГОВ
   
   Содержимое:
   1. Описание каждой таблицы
   2. Назначение каждого поля
   3. Примеры, как использовать поля в SQL
   4. Связи между таблицами (relationships)
   5. Типичные задачи и их решения
*/

/* ============================================================
   ТАБЛИЦА: users
   ============================================================
   НАЗНАЧЕНИЕ: Хранит информацию о пользователях сайта/приложения
   
   КОГДА СОЗДАЕТСЯ: При регистрации пользователя на сайте
   КАК ИСПОЛЬЗУЕТСЯ: Базовая таблица для связи с другими данными
   
   ПОЛЯ:
   ------
*/

/* user_id (INT, PRIMARY KEY)
   Назначение: Уникальный номер пользователя
   Пример: 1, 2, 3, 4...
   Как использовать: JOIN users u ON orders.user_id = u.user_id
   Зачем: Чтобы найти все действия одного пользователя
*/

/* registration_date (DATE)
   Назначение: День, когда пользователь зарегистрировался
   Пример: 2025-01-15
   Как использовать: WHERE DATE_TRUNC('month', registration_date) = '2025-01'
   Зачем: Для когортного анализа - группировать пользователей по периодам
           и смотреть, как они себя ведут со временем
*/

/* source (VARCHAR)
   Назначение: Откуда пришел пользователь (какой канал маркетинга его привел)
   Возможные значения: 'google', 'yandex', 'vk', 'direct', 'referral', 'organic'
   Пример: 'google', 'yandex'
   Как использовать: WHERE source = 'google'
   Зачем: Понять, какие маркетинговые каналы приносят лучших пользователей
           SELECT source, COUNT(*) FROM users GROUP BY source
*/

/* device (VARCHAR)
   Назначение: С какого устройства пришел пользователь
   Возможные значения: 'desktop', 'mobile', 'tablet'
   Пример: 'desktop', 'mobile'
   Как использовать: WHERE device = 'mobile'
   Зачем: Оптимизировать сайт для популярных устройств
           SELECT device, COUNT(*) FROM users GROUP BY device
*/

/* region (VARCHAR)
   Назначение: Географический регион пользователя
   Возможные значения: 'moscow', 'spb', 'other'
   Пример: 'moscow', 'spb'
   Как использовать: WHERE region = 'moscow'
   Зачем: Проводить региональные маркетинговые кампании
           SELECT region, COUNT(*) FROM users GROUP BY region
*/


/* ============================================================
   ТАБЛИЦА: clicks
   ============================================================
   НАЗНАЧЕНИЕ: Все клики пользователей на рекламные объявления
   
   КОГДА СОЗДАЕТСЯ: Каждый раз, когда пользователь кликает на объявление
   КАК ИСПОЛЬЗУЕТСЯ: Для анализа рекламных кампаний
   
   ПОЛЯ:
   ------
*/

/* click_id (INT, PRIMARY KEY)
   Назначение: Уникальный номер клика
   Пример: 1, 2, 3, 4...
   Как использовать: SELECT COUNT(DISTINCT click_id) FROM clicks
*/

/* user_id (INT, FOREIGN KEY -> users.user_id)
   Назначение: Кто сделал клик (связь с таблицей users)
   Пример: 1, 2, 3
   Как использовать: JOIN users u ON clicks.user_id = u.user_id
   Зачем: Узнать, кто кликнул и откуда он пришел
*/

/* click_date (DATE)
   Назначение: Дата и время клика
   Пример: 2025-01-15
   Как использовать: WHERE click_date >= '2025-01-01' AND click_date < '2025-02-01'
   Зачем: Анализировать тренды по дням/неделям
*/

/* campaign_id (INT)
   Назначение: Какая реклама была нажата (связь с кампаниями)
   Пример: 1, 2, 3 (ID рекламной кампании)
   Как использовать: WHERE campaign_id = 1
   Зачем: Узнать, какую рекламу кликали
*/

/* cost (DECIMAL)
   Назначение: Во сколько обошелся этот клик рекламодателю
   Пример: 0.50, 1.25, 2.00 (в рублях или валюте)
   Как использовать: SUM(cost) - сумма всех расходов
   Зачем: Считать ROI и эффективность кампаний
*/

/* device (VARCHAR)
   Назначение: На каком устройстве был сделан клик
   Возможные значения: 'desktop', 'mobile', 'tablet'
   Пример: 'mobile'
   Как использовать: GROUP BY device для анализа по устройствам
   Зачем: Понять, с какие устройства приносят больше/меньше кликов
*/


/* ============================================================
   ТАБЛИЦА: conversions
   ============================================================
   НАЗНАЧЕНИЕ: Все конверсии пользователей (покупки, регистрации, контакты)
   
   КОГДА СОЗДАЕТСЯ: Когда пользователь совершает целевое действие
   КАК ИСПОЛЬЗУЕТСЯ: Для анализа результативности кампаний
   
   ПОЛЯ:
   ------
*/

/* conversion_id (INT, PRIMARY KEY)
   Назначение: Уникальный номер конверсии
   Пример: 1, 2, 3, 4...
   Как использовать: COUNT(conversion_id) - считать конверсии
*/

/* user_id (INT, FOREIGN KEY -> users.user_id)
   Назначение: Кто совершил конверсию (связь с users)
   Пример: 1, 2, 3
   Как использовать: JOIN users ON conversions.user_id = users.user_id
*/

/* conversion_date (DATE)
   Назначение: Когда произошла конверсия
   Пример: 2025-01-15
   Как использовать: WHERE conversion_date >= '2025-01-01'
   Зачем: Анализировать скорость конверсии
*/

/* revenue (DECIMAL)
   Назначение: Сколько денег принесла эта конверсия
   Пример: 100.00, 250.50 (в рублях)
   Как использовать: SUM(revenue) - общий доход
   Зачем: Считать ROAS (Return On Ad Spend) и прибыль
*/

/* conversion_type (VARCHAR)
   Назначение: Какой тип конверсии произошел
   Возможные значения: 'trial' (пробный период), 'paid' (платеж), 'upgrade' (повышение)
   Пример: 'paid'
   Как использовать: WHERE conversion_type = 'paid'
   Зачем: Разделять разные типы целевых действий
*/


/* ============================================================
   СВЯЗИ МЕЖДУ ТАБЛИЦАМИ (Database Relationships)
   ============================================================
*/

/* users -> clicks
   Один пользователь может сделать много кликов
   users.user_id -> clicks.user_id
   
   Пример запроса:
   SELECT u.user_id, u.source, COUNT(c.click_id) AS total_clicks
   FROM users u
   LEFT JOIN clicks c ON u.user_id = c.user_id
   GROUP BY u.user_id, u.source;
   
   Что это показывает: Сколько кликов сделал каждый пользователь
*/

/* users -> conversions
   Один пользователь может совершить много конверсий
   users.user_id -> conversions.user_id
   
   Пример запроса:
   SELECT u.user_id, u.source, COUNT(cv.conversion_id) AS total_conversions
   FROM users u
   LEFT JOIN conversions cv ON u.user_id = cv.user_id
   GROUP BY u.user_id, u.source;
   
   Что это показывает: Сколько конверсий совершил каждый пользователь
*/

/* clicks -> conversions
   Один клик может привести к конверсии
   (Связь через user_id - кто кликнул и кто потом конвертировался)
   
   Пример запроса:
   SELECT 
       COUNT(DISTINCT c.user_id) AS users_who_clicked,
       COUNT(DISTINCT cv.user_id) AS users_who_converted,
       ROUND(COUNT(DISTINCT cv.user_id)::FLOAT / COUNT(DISTINCT c.user_id) * 100, 2) AS conversion_rate
   FROM clicks c
   LEFT JOIN conversions cv ON c.user_id = cv.user_id
   
   Что это показывает: Какой процент кликающих людей потом конвертировалась
*/


/* ============================================================
   ТИПИЧНЫЕ SQL ЗАДАЧИ
   ============================================================
*/

/* ЗАДАЧА 1: Сколько пользователей пришло из Google?*/
SELECT COUNT(*) AS users_from_google
FROM users
WHERE source = 'google';

/* ЗАДАЧА 2: Какой процент пользователей с мобильного?*/
SELECT 
    ROUND(COUNT(CASE WHEN device = 'mobile' THEN 1 END)::FLOAT / COUNT(*) * 100, 2) AS mobile_percentage
FROM users;

/* ЗАДАЧА 3: Сколько мы потратили на Google рекламу?*/
SELECT SUM(cost) AS total_google_cost
FROM clicks
WHERE campaign_id IN (SELECT id FROM campaigns WHERE source = 'google');

/* ЗАДАЧА 4: Сколько конверсий мы получили в январе?*/
SELECT COUNT(*) AS conversions_january
FROM conversions
WHERE DATE_TRUNC('month', conversion_date) = '2025-01';

/* ЗАДАЧА 5: Какой был средний доход на конверсию?*/
SELECT 
    AVG(revenue) AS avg_revenue_per_conversion,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_conversions
FROM conversions;

/* ЗАДАЧА 6: Какой источник принес больше всего денег?*/
SELECT 
    u.source,
    SUM(cv.revenue) AS total_revenue
FROM conversions cv
JOIN users u ON cv.user_id = u.user_id
GROUP BY u.source
ORDER BY total_revenue DESC;

/* ЗАДАЧА 7: Сколько стоит привлечение одного клиента?*/
SELECT 
    u.source,
    SUM(c.cost) AS total_cost,
    COUNT(DISTINCT cv.conversion_id) AS total_conversions,
    ROUND(SUM(c.cost) / COUNT(DISTINCT cv.conversion_id), 2) AS cpa
FROM users u
JOIN clicks c ON u.user_id = c.user_id
LEFT JOIN conversions cv ON u.user_id = cv.user_id
GROUP BY u.source;
