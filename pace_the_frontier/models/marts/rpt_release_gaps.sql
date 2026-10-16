{#- Cadence: one row per pair of consecutive days on which at least one counted model
    was released. A pause after the essay would show up as a long across_essay gap. -#}

with

release_days as (

    select
        release_date,
        count(*) as releases_on_day

    from {{ ref('fct_release_candidates') }}
    where is_counted
    group by release_date

),

paired as (

    select
        lag(release_date) over (order by release_date) as gap_start_date,
        release_date as gap_end_date,
        releases_on_day as releases_on_end_date

    from release_days

),

final as (

    select
        strftime(gap_start_date, '%Y-%m-%d') || '_' || strftime(gap_end_date, '%Y-%m-%d') as gap_id,
        gap_start_date,
        gap_end_date,
        gap_end_date - gap_start_date as gap_days,
        gap_end_date - gap_start_date - 1 as quiet_days,
        releases_on_end_date,
        {{ essay_window("gap_start_date - date '" ~ var('essay_date') ~ "'") }} as start_window,
        {{ essay_window("gap_end_date - date '" ~ var('essay_date') ~ "'") }} as end_window,
        case
            when gap_start_date < date '{{ var("essay_date") }}'
                and gap_end_date > date '{{ var("essay_date") }}' then 'across_essay'
            when gap_end_date < date '{{ var("essay_date") }}' then 'within_before'
            else 'within_after'
        end as gap_position

    from paired
    where gap_start_date is not null

)

select * from final
