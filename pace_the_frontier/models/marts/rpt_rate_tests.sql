{#- Before vs after, segment by segment, with an exact two-sided test of "same release rate
    in both windows". Under that null, and given n = before + after releases, the after count
    is Binomial(n, 0.5) (the conditional test for two Poisson counts over equal exposure).
    The two-sided p-value doubles the smaller tail, capped at 1. With this many segments,
    read the Bonferroni column before calling anything a signal. -#}

with

candidates as (

    select
        releases.*,
        labs.region,
        labs.is_author_or_endorser

    from {{ ref('fct_release_candidates') }} as releases
    left join {{ ref('dim_labs') }} as labs
        on releases.lab_id = labs.lab_id

),

comparisons as (

    select * from (values
        (1, 'all_counted', 'headline', 'All counted releases (main definition)'),
        (2, 'top_tier', 'capability', 'Top-tier releases'),
        (3, 'new_flagship', 'capability', 'New flagships (top tier, excluding snapshot refreshes)'),
        (4, 'below_flagship', 'capability', 'Releases below the top tier'),
        (5, 'author_or_endorser', 'essay_stance', 'Labs that wrote or publicly endorsed the essay'),
        (6, 'no_response_recorded', 'essay_stance', 'Labs with no recorded response'),
        (7, 'region_us', 'geography', 'US labs'),
        (8, 'region_china', 'geography', 'Chinese labs'),
        (9, 'region_europe', 'geography', 'European labs'),
        (10, 'generally_available', 'access', 'Generally available at announcement'),
        (11, 'restricted_access', 'access', 'Preview, limited, gated or announced only'),
        (12, 'open_weights', 'access', 'Open weights at launch or promised'),
        (13, 'top_tier_generally_available', 'access', 'Top-tier and generally available'),
        (14, 'top_tier_restricted', 'access', 'Top-tier with restricted access'),
        (15, 'released_only', 'sensitivity', 'Excluding announced-only models'),
        (16, 'incl_borderline_labs', 'sensitivity', 'Including the four borderline labs'),
        (17, 'worst_case_dates', 'sensitivity', 'Date-sensitive rows moved to their conflicting dates')
    ) as t (comparison_order, comparison_id, comparison_group, comparison_label)

),

memberships as (

    select
        comparisons.comparison_id,
        case comparisons.comparison_id
            when 'all_counted' then candidates.is_counted
            when 'top_tier' then candidates.is_counted and candidates.is_top_tier
            when 'new_flagship' then candidates.is_counted and candidates.top_tier_kind = 'new_flagship'
            when 'below_flagship' then candidates.is_counted and not candidates.is_top_tier
            when 'author_or_endorser' then candidates.is_counted and candidates.is_author_or_endorser
            when 'no_response_recorded' then candidates.is_counted and not candidates.is_author_or_endorser
            when 'region_us' then candidates.is_counted and candidates.region = 'US'
            when 'region_china' then candidates.is_counted and candidates.region = 'China'
            when 'region_europe' then candidates.is_counted and candidates.region = 'Europe'
            when 'generally_available' then candidates.is_counted and candidates.is_generally_available
            when 'restricted_access' then candidates.is_counted and candidates.is_restricted_access
            when 'open_weights' then candidates.is_counted and candidates.is_open_weights
            when 'top_tier_generally_available' then candidates.is_counted and candidates.is_top_tier and candidates.is_generally_available
            when 'top_tier_restricted' then candidates.is_counted and candidates.is_top_tier and candidates.is_restricted_access
            when 'released_only' then candidates.is_counted_released_only
            when 'incl_borderline_labs' then candidates.is_counted_incl_borderline
            when 'worst_case_dates' then candidates.is_counted
        end as is_member,
        case
            when comparisons.comparison_id = 'worst_case_dates' then candidates.essay_window_alt_date
            else candidates.essay_window
        end as comparison_window

    from candidates
    cross join comparisons

),

counts as (

    select
        comparison_id,
        count(*) filter (where is_member and comparison_window = 'before') as before_count,
        count(*) filter (where is_member and comparison_window = 'after') as after_count

    from memberships
    group by comparison_id

),

outcomes as (

    select
        comparison_id,
        after_count,
        cast(before_count + after_count as double) as n,
        unnest(range(0, before_count + after_count + 1)) as k

    from counts

),

probabilities as (

    select
        comparison_id,
        after_count,
        k,
        exp(lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) - n * ln(2)) as probability

    from outcomes

),

tails as (

    select
        comparison_id,
        sum(probability) filter (where k <= after_count) as lower_tail,
        sum(probability) filter (where k >= after_count) as upper_tail

    from probabilities
    group by comparison_id

),

final as (

    select
        comparisons.comparison_order,
        comparisons.comparison_id,
        comparisons.comparison_group,
        comparisons.comparison_label,
        counts.before_count,
        counts.after_count,
        counts.after_count - counts.before_count as change,
        case
            when counts.before_count > 0
                then round(counts.after_count::double / counts.before_count, 3)
        end as rate_ratio,
        least(1.0, 2 * least(tails.lower_tail, tails.upper_tail)) as p_value_two_sided,
        least(1.0, 2 * least(tails.lower_tail, tails.upper_tail) * count(*) over ()) as p_value_bonferroni

    from comparisons
    inner join counts
        on comparisons.comparison_id = counts.comparison_id
    inner join tails
        on comparisons.comparison_id = tails.comparison_id

)

select * from final
order by comparison_order
