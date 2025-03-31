{{
    config(
        materialized='view'
    )
}}

select 
    id,
    REGION_N,
    SUBZONE_N,
    PLN_AREA_N,
    geometry
from {{ source('subzones','subzones') }}