{{
    config(
        materialized='view'
    )
}}

with availability_data as 
(
    select *,
        row_number() over(partition by carpark_number, lot_type, carpark_datetime) as rn
    from {{ source('staging','carpark_availability_data') }}
    where carpark_number is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['carpark_number', 'lot_type', 'carpark_datetime']) }} AS availability_key,
    carpark_number,
    lot_type as lot_code,
    {{ get_lot_type_description('lot_type') }} as lot_type,
    total_lots,
    available_lots,
    carpark_datetime
from availability_data
where rn = 1
