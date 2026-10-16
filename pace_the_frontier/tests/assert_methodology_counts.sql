-- Every count published in METHODOLOGY sections 2 and 7.2 must be reproduced by the marts.
with

expected as (

    select * from (values
        ('counted', 'before', 15),
        ('counted', 'after', 14),
        ('top_tier', 'before', 7),
        ('top_tier', 'after', 5),
        ('labs_shipping', 'before', 9),
        ('labs_shipping', 'after', 8),
        ('released_only', 'before', 15),
        ('released_only', 'after', 13),
        ('incl_borderline_labs', 'before', 16),
        ('incl_borderline_labs', 'after', 18),
        ('worst_case_dates', 'before', 13),
        ('worst_case_dates', 'after', 14)
    ) as t (measure, essay_window, expected_count)

),

releases as (

    select * from {{ ref('fct_release_candidates') }}

),

actual as (

    select 'counted' as measure, essay_window, count(*) as actual_count
    from releases where is_counted group by 1, 2
    union all
    select 'top_tier', essay_window, count(*)
    from releases where is_counted and is_top_tier group by 1, 2
    union all
    select 'labs_shipping', essay_window, count(distinct lab_id)
    from releases where is_counted group by 1, 2
    union all
    select 'released_only', essay_window, count(*)
    from releases where is_counted_released_only group by 1, 2
    union all
    select 'incl_borderline_labs', essay_window, count(*)
    from releases where is_counted_incl_borderline group by 1, 2
    union all
    select 'worst_case_dates', essay_window_alt_date, count(*)
    from releases where is_counted group by 1, 2

)

select
    expected.measure,
    expected.essay_window,
    expected.expected_count,
    coalesce(actual.actual_count, 0) as actual_count
from expected
left join actual
    on expected.measure = actual.measure
    and expected.essay_window = actual.essay_window
where expected.expected_count <> coalesce(actual.actual_count, 0)
