{{ config(materialized='table') }}

with lot_capacity as (
    select 
        distinct subzone_id,
        total_lots,
        lot_type
    from {{ ref('fact_carpark') }}
),
regions as (
    select
        subzone_id,
        Region
    from {{ ref('dim_subzones') }}
)

select
    r.Region,
    l.lot_type as Lot_Type,
    sum(total_lots) as Total_Lots
from lot_capacity l
inner join regions r
on l.subzone_id = r.subzone_id
group by 1,2