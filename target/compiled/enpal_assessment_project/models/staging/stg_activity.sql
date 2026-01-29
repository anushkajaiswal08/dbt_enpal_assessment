

with source as (
    select * from "postgres"."public"."activity"
),

renamed as (
    select
        activity_id,
        type as activity_type,
        assigned_to_user as user_id,
        deal_id,
        done as is_done,
        due_to as due_date
    from source
)

select * from renamed