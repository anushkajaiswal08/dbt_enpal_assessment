

with source as (
    select * from "postgres"."public"."activity_types"
),

renamed as (
    select
        id as activity_type_id,
        name as activity_name,
        active as is_active,
        type as activity_type_code
    from source
)

select * from renamed