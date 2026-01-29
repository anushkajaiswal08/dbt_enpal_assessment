{{
    config(
        materialized='view'
    )
}}

-- This model extracts and enriches stage transitions from deal changes

with stage_changes as (
    select
        deal_id,
        change_time,
        cast(new_value as integer) as stage_id
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'stage_id'
),

with_stages as (
    select
        sc.deal_id,
        sc.change_time,
        sc.stage_id,
        s.stage_name,
        date_trunc('month', sc.change_time)::date as month
    from stage_changes sc
    left join {{ ref('stg_stages') }} s 
        on sc.stage_id = s.stage_id
)

select * from with_stages

