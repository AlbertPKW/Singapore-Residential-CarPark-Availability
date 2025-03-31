{{
    config(
        materialized='view'
    )
}}

with carpark_info as 
(
    select *,
        row_number() over(partition by car_park_no) as rn
    from {{ source('staging','hdb_carpark_information') }}
    where car_park_no is not null
)

select
    car_park_no,
    address,
    latitude,
    longitude,
    ST_GEOGPOINT(longitude, latitude) AS geometry,
    car_park_type,
    type_of_parking_system,
    short_term_parking,
    free_parking,
    night_parking,
    car_park_decks,
    gantry_height,
    car_park_basement
from carpark_info
where rn = 1