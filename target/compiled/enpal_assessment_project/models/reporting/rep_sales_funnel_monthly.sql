

/*
    Sales Funnel Monthly Report
    
    This model creates a monthly sales funnel report with the following KPIs:
    - Step 1: Lead Generation
    - Step 2: Qualified Lead
      - Step 2.1: Sales Call 1 (activities with type 'meeting')
    - Step 3: Needs Assessment
      - Step 3.1: Sales Call 2 (activities with type 'sc_2')
    - Step 4: Proposal/Quote Preparation
    - Step 5: Negotiation
    - Step 6: Closing
    - Step 7: Implementation/Onboarding
    - Step 8: Follow-up/Customer Success
    - Step 9: Renewal/Expansion
*/

with stage_transitions as (
    -- Count distinct deals that reached each stage per month
    select
        month,
        stage_id,
        stage_name,
        count(distinct deal_id) as deals_count
    from "postgres"."public_pipedrive_analytics"."int_deal_stage_transitions"
    group by month, stage_id, stage_name
),

-- Sales Call 1 activities (type = 'meeting' maps to Sales Call 1 per activity_types)
sales_call_1 as (
    select
        date_trunc('month', due_date)::date as month,
        count(distinct deal_id) as deals_count
    from "postgres"."public_pipedrive_analytics"."stg_activity"
    where activity_type = 'meeting'
      and is_done = true
    group by date_trunc('month', due_date)::date
),

-- Sales Call 2 activities (type = 'sc_2' maps to Sales Call 2 per activity_types)
sales_call_2 as (
    select
        date_trunc('month', due_date)::date as month,
        count(distinct deal_id) as deals_count
    from "postgres"."public_pipedrive_analytics"."stg_activity"
    where activity_type = 'sc_2'
      and is_done = true
    group by date_trunc('month', due_date)::date
),

-- Stage-based funnel steps
stage_funnel as (
    select
        month,
        stage_name as kpi_name,
        case stage_id
            when 1 then 'Step 1'
            when 2 then 'Step 2'
            when 3 then 'Step 3'
            when 4 then 'Step 4'
            when 5 then 'Step 5'
            when 6 then 'Step 6'
            when 7 then 'Step 7'
            when 8 then 'Step 8'
            when 9 then 'Step 9'
        end as funnel_step,
        deals_count
    from stage_transitions
),

-- Sales Call 1 funnel step (Step 2.1 - occurs during Qualified Lead stage)
sales_call_1_funnel as (
    select
        month,
        'Sales Call 1' as kpi_name,
        'Step 2.1' as funnel_step,
        deals_count
    from sales_call_1
),

-- Sales Call 2 funnel step (Step 3.1 - occurs during Needs Assessment stage)
sales_call_2_funnel as (
    select
        month,
        'Sales Call 2' as kpi_name,
        'Step 3.1' as funnel_step,
        deals_count
    from sales_call_2
),

-- Combine all funnel steps
final as (
    select * from stage_funnel
    union all
    select * from sales_call_1_funnel
    union all
    select * from sales_call_2_funnel
)

select
    month,
    kpi_name,
    funnel_step,
    deals_count
from final
order by month, funnel_step