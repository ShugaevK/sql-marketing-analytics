# SQL для маркетинга: Начальный уровень

## 📚 Обучающий кейс по SQL запросам в marketing analytics

Этот репозиторий содержит примеры SQL запросов для решения типичных задач в маркетинге: когортный анализ, расчёт метрик, аналитика трафика и многое другое.

**Уровень:** Начинающий (SELECT, WHERE, GROUP BY, JOIN)

---

## 🎯 Что вы научитесь делать

1. **Когортный анализ** — группировать пользователей по дате и источнику
2. **Расчёт KPI** — CTR, CPC, CPA, ROAS, Conversion Rate
3. **Анализ трафика** — по каналам, источникам, устройствам
4. **Расчёт retention** — удержание пользователей по неделям/месяцам
5. **Сегментация** — выделение high-value и low-value клиентов

---

## 📊 База данных (пример структуры)

### Таблица `users`
```
user_id (INT, PRIMARY KEY)
registration_date (DATE)
source (VARCHAR) — google, yandex, vk, direct
device (VARCHAR) — desktop, mobile, tablet
region (VARCHAR) — moscow, spb, other
```

### Таблица `clicks`
```
click_id (INT, PRIMARY KEY)
user_id (INT, FOREIGN KEY)
click_date (DATE)
campaign_id (INT)
cost (DECIMAL) — стоимость клика
device (VARCHAR)
```

### Таблица `conversions`
```
conversion_id (INT, PRIMARY KEY)
user_id (INT, FOREIGN KEY)
conversion_date (DATE)
revenue (DECIMAL) — выручка от конверсии
conversion_type (VARCHAR) — trial, paid, upgrade
```

---

## 🔥 Основные SQL запросы

### 1️⃣ БАЗОВЫЙ ЗАПРОС: Количество кликов по дням

```sql
SELECT 
  click_date,
  COUNT(*) as clicks,
  COUNT(DISTINCT user_id) as unique_users
FROM clicks
GROUP BY click_date
ORDER BY click_date DESC;
```

**Что считает:**
- Каждый день показывает количество кликов
- Уникальные пользователи
- Сортирует от новых к старым

---

### 2️⃣ CTR (Click-Through Rate)

```sql
SELECT 
  c.click_date,
  c.source,
  COUNT(DISTINCT c.click_id) as clicks,
  COUNT(DISTINCT cv.conversion_id) as conversions,
  ROUND(
    COUNT(DISTINCT cv.conversion_id)::float / 
    COUNT(DISTINCT c.click_id) * 100, 2
  ) as conversion_rate_pct
FROM clicks c
LEFT JOIN conversions cv ON c.user_id = cv.user_id 
  AND cv.conversion_date = c.click_date
GROUP BY c.click_date, c.source
ORDER BY c.click_date DESC;
```

**Что здесь:**
- `LEFT JOIN` — присоединяем конверсии к кликам
- `ROUND()` — округляем до 2 знаков
- `::float` — преобразуем в число для расчёта
- `GROUP BY` — группируем по дате и источнику

---

### 3️⃣ CPA (Cost Per Acquisition)

```sql
SELECT 
  u.source,
  COUNT(DISTINCT cv.conversion_id) as conversions,
  SUM(c.cost) as total_spend,
  ROUND(SUM(c.cost) / COUNT(DISTINCT cv.conversion_id), 2) as cpa
FROM users u
JOIN clicks c ON u.user_id = c.user_id
JOIN conversions cv ON u.user_id = cv.user_id
WHERE c.click_date >= '2025-01-01' 
  AND c.click_date < '2025-02-01'
GROUP BY u.source
ORDER BY cpa ASC;
```

**Что здесь:**
- `INNER JOIN` — только пользователи с кликами И конверсиями
- `WHERE` — фильтруем по периоду
- `SUM()` — суммируем стоимость
- CPA = Spend / Conversions

---

### 4️⃣ КОГОРТНЫЙ АНАЛИЗ (Retention)

```sql
WITH first_click AS (
  SELECT 
    user_id,
    MIN(click_date) as first_click_date,
    DATE_TRUNC('week', MIN(click_date)) as cohort_week
  FROM clicks
  GROUP BY user_id
)
SELECT 
  fc.cohort_week,
  COUNT(DISTINCT fc.user_id) as cohort_size,
  COUNT(DISTINCT CASE 
    WHEN c.click_date >= fc.first_click_date + INTERVAL '7 days' 
    THEN c.user_id 
  END) as week_2_users,
  COUNT(DISTINCT CASE 
    WHEN c.click_date >= fc.first_click_date + INTERVAL '14 days' 
    THEN c.user_id 
  END) as week_3_users,
  ROUND(
    COUNT(DISTINCT CASE WHEN c.click_date >= fc.first_click_date + INTERVAL '7 days' 
    THEN c.user_id END)::float / COUNT(DISTINCT fc.user_id) * 100, 1
  ) as week_2_retention_pct
FROM first_click fc
LEFT JOIN clicks c ON fc.user_id = c.user_id 
  AND c.click_date >= fc.first_click_date
GROUP BY fc.cohort_week
ORDER BY fc.cohort_week DESC;
```

**Что здесь:**
- `WITH` (CTE) — создаём временную таблицу с первым кликом каждого пользователя
- `DATE_TRUNC('week', ...)` — группируем по неделям
- `CASE WHEN` — считаем только пользователей, вернувшихся на неделю 2+
- `INTERVAL` — добавляем дни

---

### 5️⃣ ВЫСОКОЦЕННЫЕ КЛИЕНТЫ (High-Value Users)

```sql
SELECT 
  u.user_id,
  u.source,
  COUNT(DISTINCT c.click_id) as total_clicks,
  COUNT(DISTINCT cv.conversion_id) as conversions,
  SUM(cv.revenue) as ltv,
  ROUND(SUM(cv.revenue)::float / SUM(c.cost), 2) as roi
FROM users u
JOIN clicks c ON u.user_id = c.user_id
LEFT JOIN conversions cv ON u.user_id = cv.user_id
GROUP BY u.user_id, u.source
HAVING COUNT(DISTINCT cv.conversion_id) >= 2 
  AND SUM(cv.revenue) > 5000
ORDER BY ltv DESC
LIMIT 100;
```

**Что здесь:**
- `HAVING` — фильтруем ПОСЛЕ группировки (не WHERE!)
- `LTV` (Lifetime Value) = сумма выручки
- `ROI` = Revenue / Cost
- `LIMIT` — берём топ 100

---

## 📝 Структура файлов

```
.
├── 1_beginner/
│   ├── 01_select_basics.sql           # SELECT, WHERE, ORDER BY
│   ├── 02_aggregates.sql              # COUNT, SUM, AVG, GROUP BY
│   ├── 03_joins_basics.sql            # INNER JOIN, LEFT JOIN
│   └── 04_ctr_cpa_calcs.sql          # Первые KPI расчёты
├── 2_intermediate/
│   ├── 05_cohort_analysis.sql         # WITH (CTE), когорты
│   ├── 06_retention_analysis.sql      # Удержание пользователей
│   ├── 07_traffic_segmentation.sql    # GROUP BY по нескольким полям
│   └── 08_date_functions.sql          # DATE_TRUNC, EXTRACT, DATE arithmetic
├── 3_marketing_kpi/
│   ├── 09_roas_calculation.sql        # ROI, ROAS для кампаний
│   ├── 10_channel_comparison.sql      # Сравнение каналов (Google vs Yandex)
│   ├── 11_device_analysis.sql         # Анализ по устройствам
│   └── 12_ltv_segments.sql            # LTV по сегментам
├── README.md                           # Этот файл
└── sample_data.sql                     # Примеры INSERT для тестирования
```

---

## 💡 Ключевые концепции SQL для маркетолога

### GROUP BY — группировка
**Что:** Объединяет строки по одинаковым значениям
**Когда:** Считаем метрики по дням, каналам, источникам
```sql
GROUP BY channel, device
-- Результат: каждая комбинация (канал + устройство) в отдельной строке
```

### JOIN — объединение таблиц
**INNER JOIN:** Только совпадающие записи (клики с конверсиями)
**LEFT JOIN:** Все записи слева + совпадающие справа (все клики, даже без конверсий)
```sql
JOIN conversions ON clicks.user_id = conversions.user_id
```

### WHERE vs HAVING
**WHERE:** Фильтруем ПЕРЕД группировкой (строки)
**HAVING:** Фильтруем ПОСЛЕ группировки (группы)
```sql
WHERE source = 'google'  -- только Google
HAVING COUNT(*) > 100    -- группы более 100 кликов
```

### CASE WHEN — условная логика
**Что:** Если...то...иначе
**Когда:** Классификация, расчёт условных сумм
```sql
CASE 
  WHEN revenue > 5000 THEN 'VIP'
  WHEN revenue > 1000 THEN 'Premium'
  ELSE 'Standard'
END as customer_segment
```

---

## 🚀 Рекомендации для начинающих

1. **Начните с SELECT** — сначала просто выбирайте данные
2. **Добавьте WHERE** — фильтруйте по датам, каналам
3. **Используйте GROUP BY** — группируйте и считайте метрики
4. **Добавьте JOIN** — объединяйте таблицы
5. **Пишите с комментариями** — `--` перед строкой

**Шаблон запроса:**
```sql
SELECT     -- что выбираем
  column1,
  COUNT(*) as count
FROM       -- из какой таблицы
  table1
WHERE      -- какие строки
  date >= '2025-01-01'
GROUP BY   -- группируем по
  column1
ORDER BY   -- сортируем по
  count DESC;
```

---

## 📌 Типичные задачи маркетолога на SQL

✅ **День 1-2:** SELECT, WHERE, ORDER BY, LIMIT
✅ **День 3-4:** COUNT, SUM, AVG, GROUP BY
✅ **День 5-6:** INNER JOIN, LEFT JOIN
✅ **День 7:** Расчёт CTR, CPC, CPA
✅ **День 8-10:** Когортный анализ, CASE WHEN
✅ **День 11-14:** Retention, LTV, ROI

---

## 🔗 Полезные ресурсы

- **SQL синтаксис:** все примеры для PostgreSQL / MySQL
- **Практика:** используйте реальные данные из Google Analytics, Yandex Metrica
- **Экспорт:** CSV → Excel/Google Sheets для визуализации

---

**Уровень:** 👶 Начинающий → 🧑‍💼 Junior Analyst
**Время обучения:** 2-3 недели
**Практическое применение:** Сразу на работе!
