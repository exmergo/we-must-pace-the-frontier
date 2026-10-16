-- The per-developer table in METHODOLOGY section 2, including ByteDance at zero.
with

expected as (

    select * from (values
        ('Alibaba (Qwen)', 3, 2),
        ('DeepSeek', 3, 0),
        ('Google DeepMind', 2, 1),
        ('Z.ai (Zhipu)', 2, 0),
        ('Anthropic', 1, 3),
        ('OpenAI', 1, 3),
        ('Meta', 1, 2),
        ('Tencent', 1, 0),
        ('Moonshot AI', 1, 0),
        ('xAI', 0, 1),
        ('MiniMax', 0, 1),
        ('Mistral AI', 0, 1),
        ('ByteDance', 0, 0)
    ) as t (lab_name, expected_before, expected_after)

),

labs as (

    select * from {{ ref('dim_labs') }}
    where in_scope_list

),

counts as (

    select
        lab_id,
        count(*) filter (where essay_window = 'before') as actual_before,
        count(*) filter (where essay_window = 'after') as actual_after
    from {{ ref('fct_release_candidates') }}
    where is_counted
    group by lab_id

)

select
    coalesce(expected.lab_name, labs.lab_name) as lab_name,
    expected.expected_before,
    expected.expected_after,
    coalesce(counts.actual_before, 0) as actual_before,
    coalesce(counts.actual_after, 0) as actual_after
from expected
full outer join labs
    on expected.lab_name = labs.lab_name
left join counts
    on labs.lab_id = counts.lab_id
where expected.lab_name is null
    or labs.lab_id is null
    or expected.expected_before <> coalesce(counts.actual_before, 0)
    or expected.expected_after <> coalesce(counts.actual_after, 0)
