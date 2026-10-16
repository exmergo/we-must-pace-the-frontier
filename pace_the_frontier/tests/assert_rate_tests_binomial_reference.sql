-- Pins the exact test to values worked by hand, so a broken implementation cannot pass.
--   15 vs 14: the after count sits at the centre of Binomial(29, 0.5), so p = 1.
--   10 vs 3: lower tail P(X <= 3 | n = 13) = (1 + 13 + 78 + 286) / 8192, doubled = 0.09228515625.
--   2 vs 7: upper tail P(X >= 7 | n = 9) = (36 + 9 + 1) / 512, doubled = 0.1796875.
--   0 vs 1: no before releases, so the rate ratio is undefined (null) and p = 1.
--   13 vs 14: the worst-case dates variant reads essay_window_alt_date, not essay_window.
with

expected as (

    select * from (values
        ('all_counted', 15, 14, 0.933, 1.0),
        ('region_china', 10, 3, 0.3, 0.09228515625),
        ('author_or_endorser', 2, 7, 3.5, 0.1796875),
        ('region_europe', 0, 1, null, 1.0),
        ('worst_case_dates', 13, 14, 1.077, 1.0)
    ) as t (comparison_id, before_count, after_count, rate_ratio, p_value_two_sided)

)

select
    expected.comparison_id,
    expected.p_value_two_sided as expected_p,
    tests.p_value_two_sided as actual_p,
    expected.rate_ratio as expected_ratio,
    tests.rate_ratio as actual_ratio
from expected
left join {{ ref('rpt_rate_tests') }} as tests
    on expected.comparison_id = tests.comparison_id
where tests.comparison_id is null
    or tests.before_count <> expected.before_count
    or tests.after_count <> expected.after_count
    or tests.rate_ratio is distinct from expected.rate_ratio
    or abs(tests.p_value_two_sided - expected.p_value_two_sided) > 1e-9
    or tests.p_value_two_sided not between 0 and 1
    or tests.p_value_bonferroni < tests.p_value_two_sided
