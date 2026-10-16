-- Every excluded row carries an exclusion category, and no counted row does.
select
    release_id,
    is_counted,
    exclusion_category
from {{ ref('fct_release_candidates') }}
where (is_counted and exclusion_category is not null)
    or (not is_counted and exclusion_category is null)
