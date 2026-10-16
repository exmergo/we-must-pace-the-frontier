-- Row-level rules of the enrichment, each written out independently of the model's own
-- CASE logic, plus pins for the handful of rows the date and event rules touch.
with

enriched as (

    select * from {{ ref('int_release_candidates__enriched') }}

),

staged_rows as (

    select count(*) as n from {{ ref('stg_research__release_candidates') }}

),

expected_alt_windows as (

    -- METHODOLOGY 7.1: the window each date-conflict row lands in under its conflicting date.
    select * from (values
        ('DeepSeek-V4-Pro-0813', 'outside'),
        ('Kimi K2.8 Preview', 'essay_day'),
        ('Grok 4.6', 'outside'),
        ('Qwen3.8-Omni-Flash', 'after')
    ) as t (model_name, expected_window)

),

expected_events as (

    select * from (values
        ('GPT-6.1 Sol', 'OpenAI DevDay'),
        ('Qwen4 family (Max, Plus, Flash, 27B)', 'Alibaba Apsara Conference')
    ) as t (model_name, expected_event)

),

failures as (

    select 'joins dropped or duplicated rows' as failure, null as release_id
    from enriched
    having count(*) <> (select n from staged_rows)

    union all

    select 'essay_period is not the signed 10-day bucket of days_from_essay', release_id
    from enriched
    where essay_period <> sign(days_from_essay) * ceil(abs(days_from_essay) / 10.0)

    union all

    select 'essay_period_label does not name the side of the essay', release_id
    from enriched
    where (essay_period < 0 and essay_period_label <> (-essay_period * 10 - 9) || '-' || (-essay_period * 10) || ' days before')
        or (essay_period > 0 and essay_period_label <> (essay_period * 10 - 9) || '-' || (essay_period * 10) || ' days after')

    union all

    select 'top_tier_kind disagrees with is_top_tier and is_snapshot_update', release_id
    from enriched
    where (top_tier_kind = 'flagship_refresh') <> coalesce(is_top_tier and is_snapshot_update, false)
        or (top_tier_kind = 'new_flagship') <> coalesce(is_top_tier and not is_snapshot_update, false)
        or (top_tier_kind = 'below_flagship') <> coalesce(not is_top_tier, false)

    union all

    select 'exclusion_category set on a counted row, or missing on an excluded one', release_id
    from enriched
    where (is_counted and exclusion_category is not null)
        or (not is_counted and (exclusion_category is null or exclusion_category = 'unclassified'))

    union all

    select 'outside_window exclusion on a row inside a window', release_id
    from enriched
    where exclusion_category = 'outside_window' and essay_window <> 'outside'

    union all

    select 'alternative window differs without a date conflict', release_id
    from enriched
    where not has_date_conflict and essay_window_alt_date <> essay_window

    union all

    select 'date-conflict row lands in the wrong alternative window', enriched.release_id
    from expected_alt_windows
    left join enriched
        on expected_alt_windows.model_name = enriched.model_name
    where enriched.essay_window_alt_date is distinct from expected_alt_windows.expected_window

    union all

    select 'launch_event does not match the rows whose notes name an event', coalesce(enriched.release_id, expected_events.model_name)
    from enriched
    full outer join expected_events
        on enriched.model_name = expected_events.model_name
    where enriched.launch_event is distinct from expected_events.expected_event

)

select * from failures
