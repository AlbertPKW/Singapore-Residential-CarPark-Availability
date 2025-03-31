{{ config(materialized='table') }}

with lots_availability as (
    select 
        subzone_id,
        available_lots,
        date
    from {{ ref('fact_carpark') }}
),
subzones as (
    select
        subzone_id,
        SUBZONE_N,
        geometry
    from {{ ref('dim_subzones') }}
),
lots_by_day as (
    select
        subzone_id,
        date as Date,
        avg(available_lots) as Day_Available_Lots
    from lots_availability
    group by 1,2
),
average_lots as (
    select
        subzone_id,
        avg(Day_Available_Lots) as Daily_Average_Available_Lots
    from lots_by_day
    group by 1
)

select 
    s.SUBZONE_N as Subzone,
    a.Daily_Average_Available_Lots,
    s.geometry
from average_lots a
inner join subzones s
on a.subzone_id = s.subzone_id
