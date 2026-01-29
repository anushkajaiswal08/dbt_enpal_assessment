
  create view "postgres"."public_pipedrive_analytics"."int_deal_stage_transitions__dbt_tmp"
    
    
  as (
    

-- This model extracts and enriches stage transitions from deal changes

with stage_changes as (
    select
        deal_id,
        change_time,
        cast(new_value as integer) as stage_id
    from "postgres"."public_pipedrive_analytics"."stg_deal_changes"
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
    left join "postgres"."public_pipedrive_analytics"."stg_stages" s 
        on sc.stage_id = s.stage_id
)

select * from with_stages
  );