{{ config(materialized='table') }}

with occupancy_tbl as (
    select 
        date,
        hour as `Hour`,
        occupancy_rate
    from {{ ref('fact_carpark') }}
),
dow as (
    select
        date_day,
        day_of_week,
        CASE
            when day_of_week = 1 then 'Mon'
            when day_of_week = 2 then 'Tues'
            when day_of_week = 3 then 'Wed'
            when day_of_week = 4 then 'Thur'
            when day_of_week = 5 then 'Fri'
            when day_of_week = 6 then 'Sat'
            else 'Sun'
        end as `Day_Name`
    from {{ ref('dim_dates') }}
)

select
    d.day_of_week as day_num,
    d.`Day_Name`,
    o.`Hour`,
    avg(occupancy_rate) as Avg_Occupancy_Rate
from occupancy_tbl o
inner join dow d
on o.date = d.date_day
group by 1,2,3


