

with source as (
    select * from "postgres"."public"."deal_changes"
),

renamed as (
    select
        deal_id,
        change_time,
        changed_field_key,
        new_value
    from source
)

select * from renamed