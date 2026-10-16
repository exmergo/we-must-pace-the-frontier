[![Built with Dex](https://img.shields.io/badge/Built%20with-Dex-165dfc?style=for-the-badge)](https://github.com/exmergo/dex)

**Built with [Dex](https://github.com/exmergo/dex)**, the agent-native analytics engineering toolkit by [Exmergo](https://exmergo.com). The DuckDB warehouse, the dbt project, the MetricFlow semantic layer and every number on this page were explored, transformed and maintained with Dex. If this study is useful to you, [star Dex on GitHub](https://github.com/exmergo/dex).

# Did "We Must Pace the Frontier" pace the frontier?

*An open-research study by [Exmergo](https://exmergo.com). Data as of 15 October 2026.*

On Saturday 12 September 2026, Anthropic CEO Dario Amodei published ["We Must Pace the Frontier"](https://darioamodei.com/post/we-must-pace-the-frontier), arguing that AI labs must slow the pace at which model capabilities improve. Sam Altman and Elon Musk agreed publicly the same day. This study asks a narrow, measurable question: **what happened to frontier model releases in the 30 days after the essay, compared with the 30 days before?**

## TL;DR

- **No measurable change in how many frontier models shipped.** There were 15 counted releases in the 30 days before the essay and 14 in the 30 days after (exact test, p = 1.0). Under every alternative definition we tried, the difference stays within two models either way.
- **No pause.** Six models shipped in the first 10 days after the essay, the same as in the last 10 days before it. The quiet stretch spanning the essay date (11 to 18 September, 7 days) is no longer than two quiet stretches inside the before window.
- **The same number of new flagships.** Top-tier releases dipped from 7 to 5, but only because the before window held two snapshot refreshes of existing flagships. New flagship models: 5 before, 5 after.
- **The labs behind the essay shipped more, not less.** Anthropic (the author), OpenAI and xAI (public endorsers) went from 2 releases to 7. Six of the seven sit below each lab's own flagship. The seventh is xAI's Grok 4.7, a new flagship released 9 days after Elon Musk posted "Dario is right".
- **The mix moved, but not where the essay pointed.** Chinese labs went from 10 releases to 3, and open-weights releases from 6 to 1. US labs went from 5 to 10. None of these splits survives a correction for the 17 comparisons we ran (smallest p = 0.09), and the Chinese drop falls outside the essay's near-term asks, which target US and other democratic labs.
- **Bottom line:** in this data the essay coincides with no slowdown in frontier releases. This is a descriptive finding, not a causal one. Release schedules are set months in advance, and the essay asked for evaluators, capability checkpoints and coordination rather than a release freeze, so a 30-day release count is a blunt instrument for its impact.

> **[Insert Viz V1: headline, before vs after]** Paired bars for counted releases, top-tier releases, new flagships and labs shipping, before vs after. Data: [`results/gold/g01_headline.csv`](results/gold/g01_headline.csv)

## Contents

1. [The essay in brief](#1-the-essay-in-brief)
2. [Data and definitions](#2-data-and-definitions)
3. [Findings](#3-findings)
4. [What this does and does not show](#4-what-this-does-and-does-not-show)
5. [How this study was built](#5-how-this-study-was-built)
6. [Reproduce it, query it, extend it](#6-reproduce-it-query-it-extend-it)
7. [Repository map](#7-repository-map)
8. [License, citation and credits](#8-license-citation-and-credits)

## 1. The essay in brief

The essay argues that capabilities have been advancing much faster since mid-2026, partly because AI now helps build the next AI. It cites an incident in which a swarm of agents ran unauthorized cyberattacks. Its central line is "We must slow the pace at which we improve the capabilities of AI models", and it states explicitly that pacing "does not mean halting model training or technical progress". Its concrete asks are:

| Ask | Who it binds |
|---|---|
| Embedded third-party evaluators (for example METR) with employee-like access, publishing without editorial control | Anthropic now; other frontier companies urged to follow |
| Common safety standards and limits on the rate of unchecked progress, with regulation covering all US frontier companies and a narrow antitrust waiver for joint safety talks | Companies in democracies |
| Capability checkpoints: pacing tied to what models can do (for example sandbox escape) | Frontier companies |
| Export controls, anti-distillation and model-weight security measures toward China | Governments |
| Four levels of global coordination, from banning narrow dangerous uses up to a full pause (which Amodei supports floating but considers unlikely soon) | Democratic and authoritarian governments |

**Reactions recorded in our sources** (NYU Shanghai RITS, [15 Sep 2026](https://rits.shanghai.nyu.edu/ai/amodei-calls-to-pace-the-frontier-altman-and-musk-agree/)): Sam Altman posted "I agree with Dario that we need to pace the frontier" and said OpenAI would match the evaluator commitment. Elon Musk posted "Dario is right". Both posts are dated 12 September. Responses from Google DeepMind, Meta, Mistral AI and the Chinese labs were not reported in those sources, and we did not research them further.

Because the essay does not ask anyone to stop releasing models, a flat release count would not by itself mean the essay "failed". The question here is narrower: **did the visible release behaviour of frontier labs change?**

## 2. Data and definitions

The release data was collected for this study on 15 October 2026. The file is [`data/frontier_models_pace_the_frontier.csv`](data/frontier_models_pace_the_frontier.csv): 52 candidate rows, 29 of them counted. Its rules are in [`data/METHODOLOGY.md`](data/METHODOLOGY.md). In short:

- **Windows:** before = 13 August to 11 September; after = 13 September to 12 October 2026. The essay day itself, 12 September, belongs to neither window (no counted model fell on it).
- **Frontier model:** a model from one of 13 labs fixed before counting (OpenAI, Anthropic, Google DeepMind, xAI, Meta, DeepSeek, Alibaba (Qwen), Moonshot AI, Z.ai (Zhipu), MiniMax, Tencent, ByteDance, Mistral AI). It must be a general-purpose language model, it must be new (a new model, size, tier or dated snapshot), and its first public announcement must fall in a window. General availability, previews, gated access and announced-only models all count.
- **Top tier:** the researcher's judgement that the model was the lab's most capable model, or a new flagship generation, at announcement.
- **Recorded but not counted:** non-language models (image, video, speech), serving and pricing tiers, configurations, cancelled models, roadmap mentions, four borderline labs (Xiaomi, StepFun, Meituan, Sakana AI) and one release a day outside the window.

**Enrichment.** We added fields derived only from the CSV itself, its methodology, and the essay sources it already cites. No new release data was collected. Each mapping lives in a reviewable seed file under [`pace_the_frontier/seeds/`](pace_the_frontier/seeds/):

| Field | How it is derived |
|---|---|
| `days_from_essay`, `essay_window`, `essay_period` | From the release date; equal 10-day periods, three per window |
| `tier_band` (flagship, upper, mid, small_fast) | From the `tier` wording ([`seed_tier_map.csv`](pace_the_frontier/seeds/seed_tier_map.csv)) |
| `top_tier_kind` (new_flagship, flagship_refresh, below_flagship) | Top-tier rows whose release type names a point or snapshot update are refreshes |
| `access_level` (general_availability, preview_or_limited, gated_or_restricted, announced_only) | From the `release_type` wording on the counted date ([`seed_release_type_map.csv`](pace_the_frontier/seeds/seed_release_type_map.csv)) |
| `open_weights_status` (at_launch, promised_later, none) | Same source |
| `region`, `essay_coordination_group`, `essay_stance` | Lab geography, and the public stance recorded in the cited sources ([`seed_labs.csv`](pace_the_frontier/seeds/seed_labs.csv)). `none_recorded` means not reported in those sources; it is not evidence of disagreement |
| `exclusion_category` | The METHODOLOGY 4.3 category, read from each excluded row's note |
| `essay_window_alt_date` | The window under each disputed date in METHODOLOGY 7.1 (the worst case) |
| `source_type` (vendor, tracker, press, aggregator) | The METHODOLOGY source hierarchy, by the domain of the row's main source ([`seed_source_domains.csv`](pace_the_frontier/seeds/seed_source_domains.csv)) |

The full column-level reference is in [`docs/data_dictionary.md`](docs/data_dictionary.md).

## 3. Findings

Each finding below comes from a governed MetricFlow query in [`semantic/gold_queries.yml`](semantic/gold_queries.yml), exported to [`results/gold/`](results/gold/). Counts are small, so read every difference alongside section [3.8](#38-is-any-of-it-more-than-noise).

### 3.1 Volume: no change

| Measure | 30 days before | 30 days after | Change |
|---|---:|---:|---:|
| Counted frontier releases | 15 | 14 | -1 |
| Labs with at least one release | 9 | 8 | -1 |
| Top-tier releases | 7 | 5 | -2 |
| New flagships (top tier, not a refresh) | 5 | 5 | 0 |
| Generally available at announcement | 10 | 9 | -1 |
| Preview, limited, gated or announced only | 5 | 5 | 0 |
| Open weights (at launch or promised) | 6 | 1 | -5 |

Source: [`g01_headline.csv`](results/gold/g01_headline.csv).

The labs announced one fewer model in the month after the essay than in the month before. A one-model gap between two counts of about 15 is what you would expect from chance alone (p = 1.0, section 3.8).

### 3.2 Timing: no pause around the essay

| 10-day period | Releases | Top tier |
|---|---:|---:|
| 21-30 days before | 5 | 2 |
| 11-20 days before | 4 | 2 |
| 1-10 days before | 6 | 3 |
| 1-10 days after | 6 | 2 |
| 11-20 days after | 4 | 1 |
| 21-30 days after | 4 | 2 |

Source: [`g03_ten_day_periods.csv`](results/gold/g03_ten_day_periods.csv).

If labs had held releases back in reaction to the essay, the first days after it would be the place to look. Instead, the 10 days right after the essay match the 10 days right before it (6 releases each). The first counted release after the essay, Alibaba's Qwen3.8-Omni-Flash, came on 18 September. Within the next four days came Grok 4.7, the Qwen4 family announcement, Claude Opus 5.5, GPT-6 Sol and GPT-6 Luna.

| Gaps between consecutive release days | Gaps | Average (days) | Longest (days) |
|---|---:|---:|---:|
| Inside the before window | 9 | 3.2 | 7 |
| Spanning the essay (11 Sep to 18 Sep) | 1 | 7.0 | 7 |
| Inside the after window | 9 | 2.7 | 6 |

Source: [`g04_release_gaps.csv`](results/gold/g04_release_gaps.csv).

The quiet week across the essay date is exactly as long as two quiet weeks inside the before window (14 to 21 August and 3 to 10 September). Releases came slightly more often after the essay than before it.

> **[Insert Viz V2: release timeline]** Daily counted releases from 13 Aug to 12 Oct with a vertical marker on 12 Sep; optionally overlay top-tier releases and label each release from the ledger. Data: [`results/gold/g02_daily_timeline.csv`](results/gold/g02_daily_timeline.csv) (daily, zero-filled), [`g03_ten_day_periods.csv`](results/gold/g03_ten_day_periods.csv) (10-day bars), [`g17_release_ledger.csv`](results/gold/g17_release_ledger.csv) (one row per release, for labels and tooltips)

> **[Insert Viz V3: gaps between release days]** Bar or dot plot of the 19 gaps, highlighting the one spanning the essay. Data: [`results/gold/g04_release_gaps.csv`](results/gold/g04_release_gaps.csv) (summary by position); the gap-level rows are in the `marts_dev.rpt_release_gaps` table of the warehouse

### 3.3 Capability: the same number of new flagships

The essay is about the pace of capability gains, so the releases that matter most are the flagships.

| Tier band | Before | After |
|---|---:|---:|
| Flagship | 7 | 5 |
| Upper (just below the flagship) | 0 | 2 |
| Mid | 1 | 3 |
| Small or fast | 7 | 4 |

Source: [`g05_by_tier_band.csv`](results/gold/g05_by_tier_band.csv).

Every top-tier release, in order:

| Date | Lab | Model | Kind | Access at announcement |
|---|---|---|---|---|
| 13 Aug | DeepSeek | DeepSeek-V4-Pro-0813 | Flagship refresh | Generally available |
| 14 Aug | Z.ai (Zhipu) | GLM-5.3 | New flagship | Limited (coding plan) |
| 28 Aug | Tencent | Hy4 preview | New flagship | Preview |
| 1 Sep | Anthropic | Claude Fable 5.1 / Claude Mythos 5.1 | New flagship | Generally available, plus a restricted variant |
| 2 Sep | Alibaba (Qwen) | Qwen3.8-Max-0902 | Flagship refresh | Generally available |
| 2 Sep | Meta | Muse Spark 1.3 | New flagship | Generally available |
| 3 Sep | OpenAI | GPT-6 Astra | New flagship | Gated rollout |
| *12 Sep* | | *Essay published* | | |
| 21 Sep | xAI | Grok 4.7 | New flagship | Generally available |
| 22 Sep | Alibaba (Qwen) | Qwen4 family | New flagship | Announced, not released |
| 30 Sep | Google DeepMind | Gemini 4 Argon | New flagship | Gated (cyber defenders) |
| 6 Oct | Mistral AI | Mistral Large 4 | New flagship | Public API preview |
| 12 Oct | Meta | Muse Wonder Full | New flagship | Subscription only |

Source: [`g06_flagship_releases.csv`](results/gold/g06_flagship_releases.csv).

The drop from 7 to 5 top-tier releases comes entirely from two snapshot refreshes in the before window (DeepSeek and Qwen). Counting only new flagship models, the windows are level at 5 each. Two new model generations were announced after the essay (Gemini 4 and Qwen4), and xAI and Mistral both shipped new flagships. Below the top tier, the after window leans toward upper and mid-tier models (Claude Opus 5.5, Muse Wonder, GPT-6 Sol, GPT-6.1 Sol, Claude Sonnet 5.5) and away from small or fast ones.

One data point outside the counts: OpenAI's **GPT-6.1 Astra** was shelved in late September, before it was ever announced as a product. Press reports (WSJ, CNBC via [qcode.cc](https://qcode.cc/gpt-6-1-astra-cancelled)) attribute this to alignment regressions, not to the essay. It is recorded in the data as an excluded row.

> **[Insert Viz V4: tier mix]** 100% stacked bars of tier band by window. Data: [`results/gold/g05_by_tier_band.csv`](results/gold/g05_by_tier_band.csv)

> **[Insert Viz V5: flagship timeline]** One mark per top-tier release on a date axis, coloured by access level, shaped by new flagship vs refresh, with the essay date marked. Data: [`results/gold/g06_flagship_releases.csv`](results/gold/g06_flagship_releases.csv)

### 3.4 Access: flat overall, but open weights fell away

A lab can respect the spirit of pacing without releasing fewer models, for example by gating a release or previewing it to a narrow audience first.

| Share of counted releases | Before | After |
|---|---:|---:|
| Generally available at announcement | 67% | 64% |
| Preview, limited, gated or announced only | 33% | 36% |
| Open weights at launch or promised | 40% | 7% |
| Top tier | 47% | 36% |

Source: [`g07_access_shares.csv`](results/gold/g07_access_shares.csv) and [`g08_access_mix.csv`](results/gold/g08_access_mix.csv).

- **Overall access did not tighten.** The restricted share moved from 5 of 15 releases to 5 of 14.
- **New flagships were slightly more often restricted:** 3 of 5 before (GLM-5.3, Hy4 preview, GPT-6 Astra) and 4 of 5 after (Qwen4, Gemini 4 Argon, Mistral Large 4, Muse Wonder Full). That is a difference of one model. Among all top-tier releases the contrast looks sharper (4 of 7 generally available before, 1 of 5 after), but two of the four generally available "before" flagships were snapshot refreshes, which ship to everyone by nature.
- **Open weights nearly vanished.** All six open-weights releases before the essay came from Chinese labs (Qwen, Z.ai, DeepSeek, Tencent). After it, the only one was Mistral Large 4, whose weights were promised for later. This is the largest proportional change in the study, and it is entirely a story about which labs shipped (section 3.6), not about any lab switching from open to closed.

> **[Insert Viz V6: access mix]** Stacked bars of access level by window, split top tier vs not; a small multiple of open-weights releases by region and window. Data: [`results/gold/g07_access_shares.csv`](results/gold/g07_access_shares.csv), [`g08_access_mix.csv`](results/gold/g08_access_mix.csv), [`g11b_open_weights_by_region.csv`](results/gold/g11b_open_weights_by_region.csv)

### 3.5 Who shipped: the essay's backers shipped more

The sharpest test of the essay's influence is the behaviour of the labs that publicly backed it.

| Lab's recorded stance | Labs | Releases before | Releases after | Change | Top tier before | Top tier after | New flagships before | New flagships after |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Author | Anthropic | 1 | 3 | +2 | 1 | 0 | 1 | 0 |
| Endorsed publicly on 12 Sep | OpenAI, xAI | 1 | 4 | +3 | 1 | 1 | 1 | 1 |
| No response recorded | the other 10 labs | 13 | 7 | -6 | 5 | 4 | 3 | 4 |

Source: [`g09_by_essay_stance.csv`](results/gold/g09_by_essay_stance.csv).

Taken together, the author and endorsers went from **2 releases to 7**. Their after-window releases were:

- **Anthropic:** Claude Opus 5.5 (22 Sep), Claude Sonnet 5.5 (28 Sep), Claude Haiku 5.5 (7 Oct). All three sit below Claude Fable 5.1 / Mythos 5.1, which Anthropic released 11 days before the essay. Anthropic says Opus 5.5 performs at Fable 5.1 level on most work.
- **OpenAI:** GPT-6 Sol and GPT-6 Luna (22 Sep), GPT-6.1 Sol (29 Sep, at DevDay). All sit below GPT-6 Astra; the GPT-6.1 Astra flagship was shelved.
- **xAI:** Grok 4.7 (21 Sep), a new and larger base model and xAI's new flagship.

So the labs behind the essay did not release fewer models. With one exception (xAI), what they released after the essay were smaller or mid-sized models below a flagship that already existed. That pattern fits "keep shipping products, don't push the capability frontier". It also fits the ordinary product cadence that follows any flagship launch, and this data cannot tell those two explanations apart.

> **[Insert Viz V7: essay backers vs everyone else]** Slope chart (before to after) of releases per stance group, with a second panel for top-tier releases. Data: [`results/gold/g09_by_essay_stance.csv`](results/gold/g09_by_essay_stance.csv)

### 3.6 By lab

| Lab | Region | Stance | Before | After | Change | Top tier before | Top tier after |
|---|---|---|---:|---:|---:|---:|---:|
| DeepSeek | China | none recorded | 3 | 0 | -3 | 1 | 0 |
| Z.ai (Zhipu) | China | none recorded | 2 | 0 | -2 | 1 | 0 |
| Alibaba (Qwen) | China | none recorded | 3 | 2 | -1 | 1 | 1 |
| Google DeepMind | US | none recorded | 2 | 1 | -1 | 0 | 1 |
| Moonshot AI | China | none recorded | 1 | 0 | -1 | 0 | 0 |
| Tencent | China | none recorded | 1 | 0 | -1 | 1 | 0 |
| Meta | US | none recorded | 1 | 2 | +1 | 1 | 1 |
| MiniMax | China | none recorded | 0 | 1 | +1 | 0 | 0 |
| Mistral AI | Europe | none recorded | 0 | 1 | +1 | 0 | 1 |
| xAI | US | endorsed | 0 | 1 | +1 | 0 | 1 |
| Anthropic | US | author | 1 | 3 | +2 | 1 | 0 |
| OpenAI | US | endorsed | 1 | 3 | +2 | 1 | 0 |
| ByteDance | China | none recorded | 0 | 0 | 0 | 0 | 0 |

Source: [`g10_by_lab.csv`](results/gold/g10_by_lab.csv). ByteDance has no release in either window, so it does not appear in the query result; it is added here from METHODOLOGY section 2.

> **[Insert Viz V8: change by lab]** Diverging bar chart of after minus before per lab, sorted, coloured by region, with the essay's author and endorsers marked. Data: [`results/gold/g10_by_lab.csv`](results/gold/g10_by_lab.csv)

### 3.7 Geography: the drop is in China, outside the essay's reach

| Region | Labs shipping before | Labs shipping after | Releases before | Releases after | Change | Top tier before | Top tier after |
|---|---:|---:|---:|---:|---:|---:|---:|
| US | 4 | 5 | 5 | 10 | +5 | 3 | 3 |
| China | 5 | 2 | 10 | 3 | -7 | 4 | 1 |
| Europe | 0 | 1 | 0 | 1 | +1 | 0 | 1 |

Source: [`g11_by_region.csv`](results/gold/g11_by_region.csv).

The essay's near-term asks (regulating US frontier companies, coordination among democracies) reach the US and European labs, and US output doubled. The labs the essay reaches only through its hardest, longest-range proposals, the Chinese labs, are where releases fell, from 10 to 3. If the essay had slowed anyone, this is the opposite of the expected pattern. More mundane explanations are available: the before window holds an unusually dense run of Chinese releases (DeepSeek, Qwen and Z.ai shipped eight models between 13 August and 10 September), and China's National Day holiday week begins on 1 October, inside the after window. Without a longer baseline we cannot say which window is the unusual one.

> **[Insert Viz V9: region before vs after]** Grouped bars of releases by region and window, with labs shipping as a secondary series. Data: [`results/gold/g11_by_region.csv`](results/gold/g11_by_region.csv), [`g11b_open_weights_by_region.csv`](results/gold/g11b_open_weights_by_region.csv)

### 3.8 Is any of it more than noise?

For each comparison we ran an exact test of the hypothesis that releases arrived at the same rate in both windows. Given the total number of releases in a segment, the after-window count should then follow a Binomial(n, 0.5) distribution. The model is [`rpt_rate_tests`](pace_the_frontier/models/marts/rpt_rate_tests.sql), and its implementation is pinned against hand-worked values in [`assert_rate_tests_binomial_reference.sql`](pace_the_frontier/tests/assert_rate_tests_binomial_reference.sql).

| Comparison | Before | After | Change | Rate ratio | p (exact) | p (Bonferroni, 17 tests) |
|---|---:|---:|---:|---:|---:|---:|
| All counted releases | 15 | 14 | -1 | 0.93 | 1.000 | 1.000 |
| Top-tier releases | 7 | 5 | -2 | 0.71 | 0.774 | 1.000 |
| New flagships | 5 | 5 | 0 | 1.00 | 1.000 | 1.000 |
| Releases below the top tier | 8 | 9 | +1 | 1.13 | 1.000 | 1.000 |
| Labs that wrote or endorsed the essay | 2 | 7 | +5 | 3.50 | 0.180 | 1.000 |
| Labs with no recorded response | 13 | 7 | -6 | 0.54 | 0.263 | 1.000 |
| US labs | 5 | 10 | +5 | 2.00 | 0.302 | 1.000 |
| Chinese labs | 10 | 3 | -7 | 0.30 | 0.092 | 1.000 |
| Generally available | 10 | 9 | -1 | 0.90 | 1.000 | 1.000 |
| Restricted access | 5 | 5 | 0 | 1.00 | 1.000 | 1.000 |
| Open weights | 6 | 1 | -5 | 0.17 | 0.125 | 1.000 |
| Top tier and generally available | 4 | 1 | -3 | 0.25 | 0.375 | 1.000 |

Source: [`g12_significance.csv`](results/gold/g12_significance.csv), which also holds the European and sensitivity rows.

No comparison reaches conventional significance, even before correcting for the number of tests. The two largest shifts (Chinese labs, open weights) are the same event seen twice, since every open-weights release before the essay was Chinese. With about 15 releases per window, the overall count would need to roughly halve or double to stand out from chance, and smaller segments need even larger swings.

> **[Insert Viz V10: significance overview]** Dot plot of rate ratio (log scale) per comparison, with p-value encoded by fill and a reference line at 1. Data: [`results/gold/g12_significance.csv`](results/gold/g12_significance.csv)

### 3.9 Does the definition change the answer?

| Definition | Before | After | Change |
|---|---:|---:|---:|
| Main definition | 15 | 14 | -1 |
| Top-tier only | 7 | 5 | -2 |
| Excluding announced-only models (drops Qwen4) | 15 | 13 | -2 |
| Including the four borderline labs | 16 | 18 | +2 |
| Both disputed dates moved out of "before" (METHODOLOGY 7.1) | 13 | 14 | +1 |

Source: [`g13_sensitivity_variants.csv`](results/gold/g13_sensitivity_variants.csv) and [`g14_worst_case_dates.csv`](results/gold/g14_worst_case_dates.csv).

The direction of the change depends on the definition, and its size never exceeds two models. This matches METHODOLOGY section 7.2, which the dbt tests reproduce exactly.

> **[Insert Viz V11: sensitivity]** Dumbbell chart of before vs after per definition. Data: [`results/gold/g13_sensitivity_variants.csv`](results/gold/g13_sensitivity_variants.csv), [`g14_worst_case_dates.csv`](results/gold/g14_worst_case_dates.csv)

### 3.10 What the definition leaves out, and how strong the evidence is

| Excluded candidates | Before | After |
|---|---:|---:|
| Image, video, speech, voice or avatar models | 2 | 8 |
| Borderline labs (Xiaomi, StepFun, Meituan, Sakana AI) | 1 | 4 |
| Serving or pricing tiers of an existing model | 1 | 2 |
| Configuration, decision-only endpoint, or cancelled model | 0 | 3 |
| Roadmap mention without a product announcement | 1 | 0 |
| **All candidate rows, counted or not** | **20** | **31** |

Source: [`g15_exclusions.csv`](results/gold/g15_exclusions.csv). One more row (Grok 4.6) sits a day outside the windows.

Counting everything the labs announced, including non-language models and the borderline labs, activity went up after the essay rather than down. The research targeted language models, so this wider list may be less complete, but nothing in it suggests a slowdown hidden by the definition.

| Main source of each row | All candidates | Counted releases |
|---|---:|---:|
| Vendor page or documentation | 1 | 1 |
| Tracker citing vendor primaries | 27 | 13 |
| Trade press | 15 | 13 |
| Aggregator listing | 9 | 2 |

Source: [`g16_evidence_quality.csv`](results/gold/g16_evidence_quality.csv).

Only one counted release rests mainly on a vendor page. Two counted releases (Gemini 3.7 Flash and Qwen3.8-27B) rest mainly on aggregator pages, which METHODOLOGY ranks lowest ("corroboration only, never the date"). Both fall on the first two days of the before window, so a one- or two-day error in either date would move it out of the study. Together with the two disputed dates in section 3.9, four of the 15 "before" releases sit close enough to the window edge to matter.

> **[Insert Viz V12: exclusions and evidence]** Stacked bars of excluded candidates by reason and window; a small bar chart of main source type for counted rows. Data: [`results/gold/g15_exclusions.csv`](results/gold/g15_exclusions.csv), [`g16_evidence_quality.csv`](results/gold/g16_evidence_quality.csv)

## 4. What this does and does not show

**What it shows.** In the 30 days after "We Must Pace the Frontier", frontier labs released as many models as in the 30 days before, at the same cadence, with the same number of new flagships, and no tighter access overall. The labs that wrote or endorsed the essay released more models afterwards, mostly below their existing flagships. The visible shifts (fewer Chinese and open-weights releases, more US releases) are within the range chance produces at these counts, and they run opposite to the essay's sphere of influence.

**What it cannot show.**

- **Cause.** This is a before/after comparison of one event with no control group. Release plans are set months in advance, so a 30-day window mostly measures decisions made before the essay existed.
- **The essay's real asks.** Embedded evaluators, capability checkpoints and coordination agreements leave no trace in a release count. A lab can comply fully with the essay and still ship on schedule.
- **What is normal.** Two 30-day windows of about 15 releases cannot establish a baseline. A longer series (for example, the same rules applied from May 2026) would show whether either window is unusual.
- **Other events in the windows:** OpenAI DevDay (29 Sep), Alibaba's Apsara Conference (22 Sep, where Qwen4 was named) and China's National Day holiday week from 1 October all fall in the after window.
- **Judgement calls.** `top_tier`, the access mapping and the tier bands are judgements, each documented in a seed file. Lab stances come from one secondary source, and the ten labs with no recorded response may well have responded somewhere we did not look.
- **Coverage and dating** limits are listed in METHODOLOGY section 7.3.

A better instrument for the essay's impact would track what it actually asked for: evaluator agreements signed, models held back or gated after a dangerous-capability evaluation, and changes to labs' published safety frameworks.

## 5. How this study was built

Every layer was produced through the Dex loop: **Explore, Transform, Maintain.** Each change to the dbt project went through a Dex plan (`transform plan`, then `transform apply`), which validated it against the real warehouse schema and dbt's own parser before writing it. The plans are kept in [`.dex/plans/`](.dex/plans/).

```text
data/frontier_models_pace_the_frontier.csv
        |  scripts/load_raw.py (all columns as text)
        v
raw.frontier_model_candidates ............................ DuckDB: warehouse/pace_the_frontier.duckdb
        |  stg_research__release_candidates (rename, type, key)
        v
staging_dev  +  reference_dev (5 enrichment seeds)
        |  int_release_candidates__enriched (derived fields)
        v
intermediate_dev
        |
        v
marts_dev: fct_release_candidates, dim_labs, rpt_release_gaps, rpt_rate_tests, metricflow_time_spine
        |  MetricFlow semantic layer (4 semantic models, 42 metrics)
        v
semantic/gold_queries.yml  -->  dex explore semantic query  -->  results/gold/*.csv
```

> **[Insert Viz V13: lineage]** Model lineage from raw to gold queries (the dbt DAG plus the semantic layer). The structure above is the source of truth.

**Explore.** `dex explore map` and `explore profile` on the raw table established the grain (one row per model), confirmed every date parses, and surfaced two problems before any SQL was written. First, `window` is a reserved word in DuckDB, so it has to be renamed and quoted. Second, DuckDB's CSV sniffer would silently cast the yes/no flags to booleans, so the loader keeps every column as text and staging owns the casts. Probes confirmed the window column matches the dates on all 52 rows and that every excluded row carries a reason. Dex's PII screen flagged lab names and research notes; a human reviewed and cleared them in [`.dex/config.yml`](.dex/config.yml), with the reason recorded.

**Transform.** `dex transform init` scaffolded the project with layered schemas. Seeds, staging, enrichment, marts and tests were then authored as Dex plans and built with `transform build --verify`. Singular tests pin every number published in METHODOLOGY: the 15/14 and 7/5 headline counts, the 9/8 labs, the per-lab table and each sensitivity variant. Dex mutation testing (`transform test --mutate`) then found logic the tests did not yet cover, including an inverted rate ratio, an off-by-one in the binomial tail and a dropped `is_counted` filter. On the three models that carry logic (the enrichment model and the two report models), tests were added until every mutant that changes this data was caught. The surviving mutants change nothing on this data (for example, boundary cases on the essay day, when no model was released), so only fixture-based unit tests could catch them.

**Semantic layer.** `dex semantic define` authored the MetricFlow layer, and `dex explore semantic list` confirmed that every metric resolves, including joins from releases to labs. The headline metrics:

| Metric | Meaning |
|---|---|
| `frontier_releases` (`_before`, `_after`, `_change`, `_change_pct`) | Counted releases, the main definition |
| `top_tier_releases`, `new_flagship_releases` (same family) | Top tier; top tier excluding snapshot refreshes |
| `labs_shipping` (same family) | Distinct labs with a counted release |
| `restricted_access_share`, `open_weights_share`, `generally_available_share`, `top_tier_share` | Ratios over `frontier_releases` |
| `frontier_releases_released_only`, `frontier_releases_incl_borderline` | METHODOLOGY 7.2 variants |
| `frontier_releases_daily`, `top_tier_releases_daily` | Joined to the calendar, so quiet days are zeros |
| `release_gaps`, `longest_gap_days`, `average_gap_days` | Cadence between release days |
| `rate_test_*` | The before/after test table |

Dimensions include the essay window and 10-day period, tier band, top-tier kind, access level, open-weights status, exclusion category, source type, and the lab's name, region, coordination group and essay stance. Run `uv run dex explore semantic list --local` for the full catalog.

**Gold queries.** [`semantic/gold_queries.yml`](semantic/gold_queries.yml) declares the 18 published queries. [`scripts/export_gold.py`](scripts/export_gold.py) runs each one through the Dex engine: MetricFlow renders the SQL, and Dex executes it read-only against the warehouse. The script writes [`results/gold/*.csv`](results/gold/) with an index. Dex returns at most 50 rows per query, so the 61-day timeline is fetched in two date ranges and concatenated, as the manifest records.

**Maintain.** `dex maintain verify` checks the whole project against the warehouse, and [`.dex/snapshot.json`](.dex/snapshot.json) is the committed baseline that `dex maintain check` compares against. At publication:

- `verify` reports one finding, by design: the join to `seed_date_sensitivity` leaves 92% of rows unmatched, because that seed is a four-row exception list. A test asserts that each of its rows names a real release.
- `check` reports `launch_event` as mostly null, by design (only two releases are tied to an event). It also reports three dimension-cardinality notes that compare the baseline's approximate distinct counts with exact ones. On a 52-row table, that approximation error alone is a few values.

## 6. Reproduce it, query it, extend it

You need [uv](https://docs.astral.sh/uv/). Everything else is pinned in [`pyproject.toml`](pyproject.toml) and `uv.lock`.

```bash
make all     # load the CSV, build and test the dbt project, export the gold CSVs
make check   # Dex maintain verify + check against the committed baseline
```

Run dbt through the project environment (`cd pace_the_frontier && uv run dbt build --profiles-dir .`) rather than a globally installed `dbt`, which may be a different distribution (for example the dbt Cloud CLI).

**Ask the semantic layer your own question:**

```bash
uv run dex explore semantic list --local --search flagship
uv run dex explore semantic query frontier_releases_change --group-by lab__region,lab__essay_stance --local
uv run dex explore semantic query restricted_access_share --group-by release__essay_window,release__tier_band --local
```

**Or query the warehouse directly.** The built [`warehouse/pace_the_frontier.duckdb`](warehouse/) is committed. Its schemas are `raw`, `reference_dev`, `staging_dev`, `intermediate_dev` and `marts_dev`; start with `marts_dev.fct_release_candidates`.

**Change the definition.** METHODOLOGY section 8 explains how to recount. To recount here, edit the CSV, adjust the expected numbers in [`assert_methodology_counts.sql`](pace_the_frontier/tests/assert_methodology_counts.sql) and [`assert_methodology_per_lab_counts.sql`](pace_the_frontier/tests/assert_methodology_per_lab_counts.sql), then run `make all`. `make check` will show what moved against the baseline.

## 7. Repository map

| Path | What it is |
|---|---|
| [`data/`](data/) | The research CSV and its methodology, as delivered |
| [`scripts/load_raw.py`](scripts/load_raw.py) | Loads the CSV into the `raw` schema |
| [`pace_the_frontier/`](pace_the_frontier/) | The dbt project: seeds, staging, intermediate, marts, tests, semantic layer |
| [`pace_the_frontier/models/semantic/`](pace_the_frontier/models/semantic/) | MetricFlow semantic models and metrics |
| [`semantic/gold_queries.yml`](semantic/gold_queries.yml) | The 18 gold MetricFlow queries |
| [`scripts/export_gold.py`](scripts/export_gold.py) | Runs the gold queries through Dex and writes the CSVs |
| [`results/gold/`](results/gold/) | Gold query results (CSV), with an [index](results/gold/README.md) |
| [`warehouse/pace_the_frontier.duckdb`](warehouse/) | The built DuckDB warehouse |
| [`docs/data_dictionary.md`](docs/data_dictionary.md) | Every table, column and enrichment rule |
| [`.dex/`](.dex/) | Dex config (PII review included), exploration cache, change plans and the maintain baseline |

## 8. License, citation and credits

- **Code** (SQL, YAML, Python, Makefile): [Apache License 2.0](LICENSE).
- **Data and findings** (CSV files, methodology, this README): [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

**Cite as:** Exmergo (2026). *Did "We Must Pace the Frontier" pace the frontier? Frontier model releases in the 30 days before and after Dario Amodei's essay.* Open research, built with Dex.

Built by [Exmergo](https://exmergo.com) with [Dex](https://github.com/exmergo/dex). Questions, corrections and missing releases are welcome as issues.
