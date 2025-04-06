{{
    config(
        materialized='table'
    )
}}

SELECT
    car_park_no AS carpark_key,
    car_park_no,
    address,
    latitude,
    longitude,
    geometry,
    car_park_type,
    type_of_parking_system AS parking_system_type,
    short_term_parking,
    free_parking,
    night_parking,
    car_park_decks AS num_decks,
    gantry_height,
    CASE 
        WHEN car_park_basement = 'Y' THEN TRUE
        ELSE FALSE
    END AS has_basement,
FROM {{ ref("stg_carpark_info") }}