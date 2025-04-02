{{ config(materialized='table') }}

with lots_availability as (
    select 
        date,
        subzone_id,
        carpark_number,
        avg(available_lots) as carpark_daily_avg_avail
    from {{ ref('fact_carpark') }}
    group by 1,2,3
),
average_lots as (
    select 
        date,
        subzone_id,
        sum(carpark_daily_avg_avail) as Daily_Average_Available_Lots
    from lots_availability
    group by 1,2
),
subzones as (
    select
        subzone_id,
        SUBZONE_N,
        Region,
        geometry
    from {{ ref('dim_subzones') }}
)

select 
    a.Date,
    s.SUBZONE_N as Subzone,
    s.Region,
    a.Daily_Average_Available_Lots,
    s.geometry
from average_lots a
inner join subzones s
on a.subzone_id = s.subzone_id
