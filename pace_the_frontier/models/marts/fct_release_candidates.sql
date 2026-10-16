{#- One row per candidate release, counted or not, so that exclusions and every
    sensitivity variant stay queryable. Filter on is_counted for the main definition. -#}

with

enriched as (

    select * from {{ ref('int_release_candidates__enriched') }}

),

final as (

    select
        -- keys
        release_id,
        lab_id,

        -- what was released
        model_name,
        developer_name,
        tier,
        tier_band,
        tier_rank,
        is_top_tier,
        top_tier_kind,
        release_type,
        access_level,
        is_generally_available,
        is_restricted_access,
        is_announced_only,
        has_gated_variant,
        open_weights_status,
        is_open_weights,
        is_snapshot_update,
        is_staggered_rollout,
        launch_event,

        -- when, relative to the essay
        release_date,
        days_from_essay,
        essay_window,
        essay_period,
        essay_period_label,
        release_weekday,
        is_weekend,

        -- counting rule and its variants
        is_counted,
        exclusion_category,
        is_borderline_lab,
        is_counted_released_only,
        is_counted_incl_borderline,

        -- date sensitivity (METHODOLOGY 7.1)
        has_date_conflict,
        alt_release_date,
        days_from_essay_alt_date,
        essay_window_alt_date,
        is_window_date_sensitive,

        -- evidence
        source_url,
        source_domain,
        source_type,
        source_rank,
        notes

    from enriched

)

select * from final
