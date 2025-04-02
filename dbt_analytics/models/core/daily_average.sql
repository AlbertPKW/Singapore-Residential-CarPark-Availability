{{ config(materialized='table') }}

with daily_lots as (
    select 
        date,
        avg(available_lots) as daily_avg_avail
    from {{ ref('fact_carpark') }}
    group by 1
)

select * from daily_lots
