# Data dictionary

Every table in `warehouse/pace_the_frontier.duckdb`, what it holds, and how each derived field is computed. The dbt YAML files beside each model carry the same descriptions and the tests; this page gathers them in one place.

## Schemas

| Schema | Built by | Contents |
|---|---|---|
| `raw` | `scripts/load_raw.py` | The research CSV, unchanged, every column as text |
| `reference_dev` | dbt seeds | Hand-curated mapping tables (enrichment) |
| `staging_dev` | dbt (views) | The raw table renamed, typed and keyed |
| `intermediate_dev` | dbt (views) | Candidates joined to the seeds, with every derived field |
| `marts_dev` | dbt (tables) | What the semantic layer and the analysis read |

## `raw.frontier_model_candidates`

One row per candidate release (52 rows). Columns as in `data/METHODOLOGY.md` section 6: `window`, `counted`, `date`, `developer`, `model`, `tier`, `release_type`, `top_tier`, `notes`, `source_url`, plus `_source_file` and `_loaded_at`. Grain: `model` (unique). `window` is a reserved word in DuckDB and must be quoted.

## `marts_dev.fct_release_candidates`

One row per candidate release, counted or not. Grain: `release_id`.

### Keys and identity

| Column | Definition |
|---|---|
| `release_id` | `slugify(developer) || '__' || slugify(model)`, where `slugify` lower-cases and collapses non-alphanumerics to `_` |
| `lab_id` | `slugify(developer)`; joins to `dim_labs` |
| `model_name`, `developer_name` | As written in the research. A combined name (for example "Claude Fable 5.1 / Claude Mythos 5.1") is one counted unit |

### What was released

| Column | Definition |
|---|---|
| `tier` | Lineup position as written in the research; null on most excluded rows |
| `tier_band`, `tier_rank` | From `seed_tier_map`: flagship (1), upper (2), mid (3), small_fast (4); `not_classified` when no tier was recorded |
| `is_top_tier` | The researcher's `top_tier` flag (METHODOLOGY 4.6); null on excluded rows |
| `top_tier_kind` | `flagship_refresh` if top tier and `is_snapshot_update`; `new_flagship` if top tier otherwise; `below_flagship` if not top tier; `not_assessed` on excluded rows |
| `release_type` | As written in the research |
| `access_level` | From `seed_release_type_map`, describing access on the counted date: `general_availability`, `preview_or_limited` (preview, experimental, or one product surface such as a coding tool or subscription plan), `gated_or_restricted` (vetting or trusted-access programs), `announced_only`, `cancelled`, `non_release` (pricing or serving tiers, configurations, roadmap mentions) |
| `is_generally_available` | `access_level = 'general_availability'` |
| `is_restricted_access` | `access_level` in preview_or_limited, gated_or_restricted, announced_only |
| `is_announced_only` | `access_level = 'announced_only'` |
| `has_gated_variant` | The same model also shipped at a restricted level (Claude Mythos 5.1, Gemini 3.8 Flash Cyber) |
| `open_weights_status`, `is_open_weights` | `at_launch`, `promised_later` or `none`; `is_open_weights` is true for the first two |
| `is_snapshot_update` | The release type names a point release or snapshot update |
| `is_staggered_rollout` | The release type names later dates for wider access or weights |
| `launch_event` | `OpenAI DevDay` or `Alibaba Apsara Conference` when the research notes name the event |

### Timing

| Column | Definition |
|---|---|
| `release_date` | Announcement date under the METHODOLOGY 4.5 dating rule |
| `days_from_essay` | `release_date - 2026-09-12` (dbt var `essay_date`) |
| `essay_window` | `before` for days -30 to -1, `after` for 1 to 30, `essay_day` for 0, otherwise `outside` (macro `essay_window`, dbt var `window_days`). Tested equal to the researcher's `window` on every row |
| `essay_period` | `sign(days) * ceil(abs(days) / 10)`: three equal 10-day periods per window, -3 to -1 and 1 to 3 |
| `essay_period_label` | For example "1-10 days after", "21-30 days before" |
| `release_weekday`, `is_weekend` | Day of week of `release_date` |

### Counting rule and variants

| Column | Definition |
|---|---|
| `is_counted` | The researcher's `counted` flag: the METHODOLOGY 4.2 main definition |
| `exclusion_category` | Null on counted rows. On excluded rows, matched from the note in this order: `lab_outside_list`, `outside_window`, `roadmap_mention`, `never_released`, `decision_only_endpoint`, `product_configuration`, `serving_or_pricing_tier`, `non_llm_modality` |
| `is_borderline_lab` | The developer is Xiaomi, StepFun, Meituan or Sakana AI |
| `is_counted_released_only` | `is_counted` and not announced only (METHODOLOGY 7.2) |
| `is_counted_incl_borderline` | `is_counted`, or a borderline lab's row inside a window (METHODOLOGY 7.2) |

### Date sensitivity (METHODOLOGY 7.1)

| Column | Definition |
|---|---|
| `has_date_conflict` | The row appears in `seed_date_sensitivity` |
| `alt_release_date` | The conflicting date where one exists, otherwise `release_date` |
| `days_from_essay_alt_date`, `essay_window_alt_date` | Timing under the conflicting dates (the worst case for the before count) |
| `is_window_date_sensitive` | The conflicting date moves the row to a different window (DeepSeek-V4-Pro-0813, Kimi K2.8 Preview) |

### Evidence

| Column | Definition |
|---|---|
| `source_url` | The single source the row relies on most |
| `source_domain` | Host of `source_url` without `www.` |
| `source_type`, `source_rank` | From `seed_source_domains`, by the METHODOLOGY 5 hierarchy: vendor (1), tracker (2), press (3), aggregator (4) |
| `notes` | Research notes as written |

## `marts_dev.dim_labs`

One row per lab (17: the 13 on the agreed list plus 4 borderline labs). Grain: `lab_id`.

| Column | Definition |
|---|---|
| `lab_name` | As written in the research |
| `in_scope_list`, `lab_scope` | On the agreed 13-lab list, or `borderline` |
| `parent_country`, `region` | Country of the parent company; US, China, Europe or Japan. Google DeepMind is classed by its US parent, although the lab is headquartered in London |
| `essay_coordination_group` | `us_frontier_company` (covered by the essay's proposed US regulation and democratic coordination), `other_democracy` (democratic coordination only), `china` (reached only by the essay's global coordination levels) |
| `essay_stance` | `author` (Anthropic), `endorsed_publicly` (OpenAI, xAI on 12 Sep 2026, per NYU Shanghai RITS), `none_recorded` (not reported in the cited sources; not researched further, and not evidence of disagreement) |
| `is_author_or_endorser` | `essay_stance` is author or endorsed_publicly |
| `stance_date`, `stance_quote`, `stance_source_url` | The recorded statement and its source |

## `marts_dev.rpt_release_gaps`

One row per pair of consecutive days with at least one counted release (19 rows). `gap_days` is the distance between the two days and `quiet_days` the days with no release in between. `gap_position` is `within_before`, `within_after` or `across_essay`.

## `marts_dev.rpt_rate_tests`

One row per before/after comparison (17 rows), for example all counted releases, top tier, US labs or open weights. `before_count`, `after_count`, `change` and `rate_ratio` describe the comparison. `p_value_two_sided` is an exact conditional binomial test of equal rates: given n = before + after, the after count is Binomial(n, 0.5) under the null, and the p-value doubles the smaller tail, capped at 1. `p_value_bonferroni` multiplies it by the number of comparisons. Both are rounded to 4 decimals.

## `marts_dev.metricflow_time_spine`

One row per day of 2026, the calendar MetricFlow needs.

## Seeds (`reference_dev`)

| Seed | Rows | What it maps |
|---|---:|---|
| `seed_labs` | 17 | Lab geography and recorded essay stance |
| `seed_release_type_map` | 29 | Each `release_type` string to access level, open-weights status and rollout flags |
| `seed_tier_map` | 15 | Each `tier` string to a tier band and rank |
| `seed_source_domains` | 17 | Each source domain to the METHODOLOGY 5 source hierarchy |
| `seed_date_sensitivity` | 4 | The disputed dates in METHODOLOGY 7.1 |

Relationship tests guarantee that every developer, tier, release type and source domain in the research maps to a seed row, and that every date-sensitivity row names a real candidate.

## Semantic layer

Defined in `pace_the_frontier/models/semantic/`. Four semantic models (`release_candidates`, `labs`, `release_gaps`, `rate_tests`) and 42 metrics. Metric families follow one pattern: `<metric>` (both windows), `<metric>_before`, `<metric>_after`, `<metric>_change` (after minus before) and `<metric>_change_pct` (change over before). Every simple metric fills missing values with 0, so a lab with nothing in one window reports 0 rather than null. Run `uv run dex explore semantic list --local` for the live catalog, with each metric's filter, measures and groupable dimensions.
