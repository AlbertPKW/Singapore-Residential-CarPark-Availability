{{ config(materialized='table') }}

with carpark_average_avail as (
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
    from carpark_average_avail
    group by 1,2
),
regions as (
    select
        subzone_id,
        Region
    from {{ ref('dim_subzones') }}
)

select
    a.date,
    a.Daily_Average_Available_Lots,
    r.Region
from average_lots a
inner join regions r
on a.subzone_id = r.subzone_id
