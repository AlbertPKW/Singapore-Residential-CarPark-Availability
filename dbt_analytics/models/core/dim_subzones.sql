{{
    config(
        materialized='table'
    )
}}

SELECT 
    id as subzone_id,
    REPLACE(REGION_N, ' REGION', '') AS Region,
    SUBZONE_N,
    PLN_AREA_N,
    geometry
FROM {{ ref("stg_sg_subzones") }}