-- The window re-derived from the date must equal the window the researcher recorded
-- (the assertion in METHODOLOGY section 6).
select
    release_id,
    release_date,
    source_essay_window,
    essay_window
from {{ ref('int_release_candidates__enriched') }}
where essay_window is distinct from source_essay_window
