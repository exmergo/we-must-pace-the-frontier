with

labs as (

    select * from {{ ref('seed_labs') }}

),

final as (

    select
        lab_id,
        lab_name,
        in_scope_list,
        case when in_scope_list then 'agreed_13_lab_list' else 'borderline' end as lab_scope,
        parent_country,
        region,
        essay_coordination_group,
        essay_stance,
        essay_stance in ('author', 'endorsed_publicly') as is_author_or_endorser,
        stance_date,
        stance_quote,
        stance_source_url

    from labs

)

select * from final
