with

source as (

    select * from {{ source('research', 'frontier_model_candidates') }}

),

renamed as (

    select
        {{ slugify('developer') }} || '__' || {{ slugify('model') }} as release_id,
        {{ slugify('developer') }} as lab_id,
        trim(developer) as developer_name,
        trim(model) as model_name,
        cast("date" as date) as release_date,
        "window" as source_essay_window,
        counted = 'yes' as is_counted,
        case top_tier
            when 'yes' then true
            when 'no' then false
        end as is_top_tier,
        nullif(trim(tier), '') as tier,
        trim(release_type) as release_type,
        nullif(trim(notes), '') as notes,
        source_url,
        regexp_extract(source_url, '^https?://(www\.)?([^/]+)', 2) as source_domain,
        _source_file,
        _loaded_at

    from source

)

select * from renamed
