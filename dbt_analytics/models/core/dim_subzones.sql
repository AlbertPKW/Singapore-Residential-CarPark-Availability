{{
    config(
        materialized='table'
    )
}}

SELECT 
    id as subzone_id,
    REGION_N,
    SUBZONE_N,
    PLN_AREA_N,
    geometry
FROM {{ ref("stg_sg_subzones") }}