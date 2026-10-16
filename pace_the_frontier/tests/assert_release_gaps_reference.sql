-- Cadence report: one gap per consecutive pair of counted release days, gap positions
-- consistent with their windows, and the single gap that spans the essay pinned.
with

gaps as (

    select * from {{ ref('rpt_release_gaps') }}

),

release_days as (

    select count(distinct release_date) as n
    from {{ ref('fct_release_candidates') }}
    where is_counted

),

failures as (

    select 'gap count is not counted release days minus one' as failure, null as gap_id
    from gaps
    having count(*) <> (select n - 1 from release_days)

    union all

    select 'gap_position disagrees with the windows of its endpoints', gap_id
    from gaps
    where (gap_position = 'within_before' and (start_window <> 'before' or end_window <> 'before'))
        or (gap_position = 'within_after' and (start_window <> 'after' or end_window <> 'after'))
        or (gap_position = 'across_essay' and (start_window <> 'before' or end_window <> 'after'))

    union all

    select 'the gap across the essay is not 11 Sep to 18 Sep (7 days)', null
    from gaps
    where gap_position = 'across_essay'
    having count(*) <> 1
        or min(gap_start_date) <> date '2026-09-11'
        or min(gap_end_date) <> date '2026-09-18'
        or min(gap_days) <> 7

)

select * from failures
