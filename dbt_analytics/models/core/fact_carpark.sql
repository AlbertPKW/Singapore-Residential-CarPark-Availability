WITH availability_source AS (
    SELECT
        carpark_number,
        lot_code,
        lot_type,
        total_lots,
        CASE
            WHEN available_lots > total_lots THEN total_lots
            ELSE available_lots
        END AS avail_lots,
        carpark_datetime,
        PARSE_DATE('%F',FORMAT_DATE('%Y-%m-%d', DATE(carpark_datetime))) AS date,
        CAST(EXTRACT(HOUR FROM carpark_datetime) AS INT) AS hour

    FROM {{ ref('stg_carpark_availability') }}
),

carpark_dim AS (
    SELECT * FROM {{ ref('dim_carpark_info') }}
),

subzones_dim AS (
    SELECT * FROM {{ ref('dim_subzones') }}
),

lot_type_dim AS (
    SELECT * FROM {{ ref('dim_lot_type') }}
),

date_dim AS (
    SELECT * FROM {{ ref('dim_dates') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['availability_source.carpark_number', 
                               'availability_source.lot_code', 
                               'availability_source.carpark_datetime']) }} AS availability_key,
    availability_source.carpark_number,
    availability_source.lot_type,
    availability_source.date,
    availability_source.hour,
    z.subzone_id,
    availability_source.total_lots,
    availability_source.avail_lots as available_lots,
    (availability_source.total_lots - availability_source.avail_lots) AS occupied_lots,
    COALESCE(SAFE_DIVIDE((availability_source.total_lots - availability_source.avail_lots), 
                availability_source.total_lots) * 100, 0) AS occupancy_rate
FROM availability_source 
LEFT JOIN carpark_dim c
    ON availability_source.carpark_number = c.car_park_no
LEFT JOIN lot_type_dim l
    ON availability_source.lot_code = l.lot_type_code
LEFT JOIN date_dim t
    ON availability_source.date = t.date_day
INNER JOIN subzones_dim as z
    ON (ST_CONTAINS(z.geometry,c.geometry))
