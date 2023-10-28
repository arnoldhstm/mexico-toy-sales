
# Time History Chart per months
  SELECT
    DATE_TRUNC(date, MONTH) months
    , SUM(sa.units * pro.product_price) total
  FROM `sales` sa
  JOIN `products` pro
    ON sa.product_id = pro.product_id
  GROUP BY 1
  ORDER BY 1;

# filter lokasi most sales
  SELECT
    st.store_location
    , SUM(sa.units * pro.product_price) total
  FROM `sales` sa
  JOIN `stores` st
    ON sa.store_id = st.store_id
  JOIN `products` pro
    ON sa.product_id = pro.product_id
  GROUP BY 1
  ORDER BY 1;

# filter lokasi most sales
  SELECT
    st.store_city
    , SUM(sa.units * pro.product_price) total
  FROM `sales` sa
  JOIN `stores` st
    ON sa.store_id = st.store_id
  JOIN `products` pro
    ON sa.product_id = pro.product_id
  GROUP BY 1
  ORDER BY 1;

# sales berdasarkan category
  SELECT 
    pro.product_category
    , SUM(sa.units * pro.product_price) total
  FROM `sales` sa
    JOIN `products` pro
      ON sa.product_id = pro.product_id
  GROUP BY 1
  ORDER BY 2 DESC;

# Pareto Chart by product name
  WITH x AS (
    SELECT
      pro.product_name AS pro_name
      , SUM((pro.product_price - pro.product_cost) * sa.units) total_margin
    FROM `sales` sa
      JOIN `products` pro
        ON sa.product_id = pro.product_id
    GROUP BY 1
  )

  , y AS (
    SELECT 
      x.pro_name
      , x.total_margin
      , x.total_margin / SUM(x.total_margin) OVER () AS percentage
    FROM x
    ORDER BY 2,3 DESC
  )

  SELECT
    y.pro_name
    , y.total_margin
    , CAST(y.percentage * 100 AS INT64) AS percentage
    , CAST(SUM(y.percentage * 100) OVER(ORDER BY y.total_margin DESC) AS INT64) AS cum
  FROM y
  ;

# Pareto Chart by city
WITH x AS (
  SELECT
    st.store_city AS city
    , COUNT(sa.sale_id) AS totalsales
  FROM `sales` sa
    JOIN `stores` st
      ON sa.store_id = st.store_id
  GROUP BY 1
)

, y AS (
  SELECT 
    x.city
    , x.totalsales
    , x.totalsales / SUM(x.totalsales) OVER () AS percentage
  FROM x
  ORDER BY 2,3 DESC
)

SELECT
  y.city
  , y.totalsales
  , CAST(y.percentage * 100 AS INT64) AS percentage
  , CAST(SUM(y.percentage * 100) OVER(ORDER BY y.totalsales DESC) AS INT64) AS cum
FROM y
;

# Pareto Chart by storename
WITH x AS (
  SELECT
    st.store_name AS names
    , COUNT(sa.sale_id) AS totalsales
  FROM `sales` sa
    JOIN `stores` st
      ON sa.store_id = st.store_id
  GROUP BY 1
)

, y AS (
  SELECT 
    x.names
    , x.totalsales
    , x.totalsales / SUM(x.totalsales) OVER () AS percentage
  FROM x
  ORDER BY 2,3 DESC
)

SELECT
  REPLACE(y.names, 'Maven Toys', '') names
  , y.totalsales
  , CAST(y.percentage * 100 AS INT64) AS percentage
  , CAST(SUM(y.percentage * 100) OVER(ORDER BY y.totalsales DESC) AS INT64) AS cum
FROM y
  ;

WITH x AS (
  SELECT 
    DATE_TRUNC(sa.date, MONTH) months
    , pro.product_name
    , SUM(sa.units) units
  FROM `sales` sa
    JOIN `products` pro
    ON sa.product_id = pro.product_id
  GROUP BY 1,2
  )

SELECT 
  x.months
  , x.product_name
  , x.units
  , SUM(x.units) OVER (PARTITION BY x.product_name ORDER BY x.months DESC) cum
FROM x
;
