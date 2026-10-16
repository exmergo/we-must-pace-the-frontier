{#- Every enrichment here is derived from the research CSV itself, the mapping seeds,
    or METHODOLOGY.md; nothing comes from new research. -#}

with

candidates as (

    select * from {{ ref('stg_research__release_candidates') }}

),

release_types as (

    select * from {{ ref('seed_release_type_map') }}

),

tiers as (

    select * from {{ ref('seed_tier_map') }}

),

labs as (

    select * from {{ ref('seed_labs') }}

),

source_domains as (

    select * from {{ ref('seed_source_domains') }}

),

date_sensitivity as (

    select * from {{ ref('seed_date_sensitivity') }}

),

joined as (

    select
        candidates.*,
        release_types.access_level,
        release_types.open_weights_status,
        release_types.has_gated_variant,
        release_types.is_snapshot_update,
        release_types.is_staggered_rollout,
        coalesce(tiers.tier_band, 'not_classified') as tier_band,
        tiers.tier_rank,
        not labs.in_scope_list as is_borderline_lab,
        source_domains.source_type,
        source_domains.source_rank,
        date_sensitivity.conflicting_date

    from candidates
    left join release_types
        on candidates.release_type = release_types.release_type
    left join tiers
        on candidates.tier = tiers.tier
    left join labs
        on candidates.lab_id = labs.lab_id
    left join source_domains
        on candidates.source_domain = source_domains.source_domain
    left join date_sensitivity
        on candidates.model_name = date_sensitivity.model_name

),

timed as (

    select
        *,
        release_date - date '{{ var("essay_date") }}' as days_from_essay,
        coalesce(conflicting_date, release_date) as alt_release_date,
        coalesce(conflicting_date, release_date) - date '{{ var("essay_date") }}' as days_from_essay_alt_date

    from joined

),

classified as (

    select
        *,
        {{ essay_window('days_from_essay') }} as essay_window,
        {{ essay_window('days_from_essay_alt_date') }} as essay_window_alt_date,
        -- Equal 10-day periods, three per window: +1 = days 1..10 after, -3 = days 21..30 before.
        -- Rows outside the windows land in periods beyond +/-3.
        cast(sign(days_from_essay) * ceil(abs(days_from_essay) / 10.0) as integer) as essay_period,
        dayname(release_date) as release_weekday,
        isodow(release_date) in (6, 7) as is_weekend,
        conflicting_date is not null as has_date_conflict,
        access_level = 'general_availability' as is_generally_available,
        access_level in ('preview_or_limited', 'gated_or_restricted', 'announced_only') as is_restricted_access,
        access_level = 'announced_only' as is_announced_only,
        open_weights_status in ('at_launch', 'promised_later') as is_open_weights,
        case
            when is_top_tier and is_snapshot_update then 'flagship_refresh'
            when is_top_tier then 'new_flagship'
            when not is_top_tier then 'below_flagship'
            else 'not_assessed'
        end as top_tier_kind,
        case
            when notes ilike '%DevDay%' then 'OpenAI DevDay'
            when notes ilike '%Apsara%' then 'Alibaba Apsara Conference'
        end as launch_event

    from timed

),

final as (

    select
        *,
        case
            when essay_period < 0
                then (-essay_period * 10 - 9) || '-' || (-essay_period * 10) || ' days before'
            when essay_period > 0
                then (essay_period * 10 - 9) || '-' || (essay_period * 10) || ' days after'
            else 'essay day'
        end as essay_period_label,
        case
            when is_counted then null
            when notes ilike '%outside the 13-lab list%' then 'lab_outside_list'
            when essay_window = 'outside' then 'outside_window'
            when notes ilike '%earnings call%' then 'roadmap_mention'
            when notes ilike '%never announced%' or access_level = 'cancelled' then 'never_released'
            when notes ilike '%decision-only%' then 'decision_only_endpoint'
            when notes ilike '%configuration%' then 'product_configuration'
            when notes ilike '%serving%' or notes ilike '%pricing%' then 'serving_or_pricing_tier'
            when regexp_matches(lower(notes), 'image|video|speech|voice|avatar|translation') then 'non_llm_modality'
            else 'unclassified'
        end as exclusion_category,
        essay_window is distinct from essay_window_alt_date as is_window_date_sensitive,
        -- METHODOLOGY 7.2 variants of the counting rule.
        is_counted and not is_announced_only as is_counted_released_only,
        is_counted or (is_borderline_lab and essay_window in ('before', 'after')) as is_counted_incl_borderline

    from classified

)

select * from final
