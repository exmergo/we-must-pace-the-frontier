# Frontier model releases around "We Must Pace the Frontier": data provenance and methodology

Companion to `frontier_models_pace_the_frontier.csv`.
Prepared 15–16 October 2026. Data reflects sources as read on 15 October 2026.

---

## 1. Question

How many frontier models were announced in the 30 days before Dario Amodei's essay "We Must Pace the Frontier", and how many in the 30 days after?

## 2. Result

| Measure | 30 days before | 30 days after |
|---|---|---|
| Models counted (main definition) | **15** | **14** |
| Top-tier models only | 7 | 5 |
| Labs with at least one counted model | 9 | 8 |

Counted models by developer:

| Developer | Before | After |
|---|---|---|
| Alibaba (Qwen) | 3 | 2 |
| DeepSeek | 3 | 0 |
| Google DeepMind | 2 | 1 |
| Z.ai (Zhipu) | 2 | 0 |
| Anthropic | 1 | 3 |
| OpenAI | 1 | 3 |
| Meta | 1 | 2 |
| Tencent | 1 | 0 |
| Moonshot AI | 1 | 0 |
| xAI | 0 | 1 |
| MiniMax | 0 | 1 |
| Mistral AI | 0 | 1 |
| ByteDance | 0 | 0 |

## 3. Anchor date and windows

- **Essay publication date: Saturday 12 September 2026.** Published on darioamodei.com and dated 12 September by several independent outlets (NYU Shanghai RITS, VKTR, computingforgeeks, horadecodar). SAN described it as published "Saturday", which matches.
- **Before window: 13 August – 11 September 2026** (essay date minus 30 days through minus 1 day).
- **After window: 13 September – 12 October 2026** (essay date plus 1 day through plus 30 days).
- **12 September itself is in neither window**, so a release on the essay day cannot be called "before" or "after". No counted model fell on that day.
- Dates are calendar days. No time-zone adjustment was made; vendors' own dates were used as published.

## 4. Definition of "frontier model"

The definition was agreed with the requester before data collection:

1. **Approach: "flagship from a leading lab".** This is a judgement-based list of labs, not a compute threshold. Training-compute figures (Epoch AI style, or the 10^26 FLOP threshold in regulation) are rarely disclosed for these models, so a compute rule would have meant estimating most rows.
2. **Scope: global, including Chinese and open-weight labs.**
3. **What counts as "announced"** (all four options selected by the requester):
   - general public release;
   - preview or limited access;
   - point updates and variants (for example x.5 → x.6, Flash or mini tiers);
   - models announced but not yet released.

### 4.1 Labs in scope (13)

OpenAI, Anthropic, Google DeepMind, xAI, Meta, DeepSeek, Alibaba (Qwen), Moonshot AI, Z.ai (Zhipu), MiniMax, Tencent, ByteDance, Mistral AI.

The list was fixed **before** counting, so it was not tuned to the result. It covers the US frontier labs, the Chinese labs most often benchmarked against them, and Europe's leading lab.

**Borderline labs, recorded but not counted:** Xiaomi (MiMo), StepFun, Meituan (LongCat), Sakana AI. They released credible large models in the windows, but they are not on the agreed list. Their rows are in the CSV, so the count can be redone with them included (section 8).

### 4.2 Inclusion rules

A row is counted (`counted = yes`) when **all** of these are true:

- the developer is one of the 13 labs above;
- it is a **general-purpose language model**, multimodal input allowed (text output, reasoning, coding, agents);
- it is **new**: a new model, a new size or tier, or a new dated snapshot or checkpoint with changed weights;
- its first public announcement falls inside one of the two windows.

### 4.3 Exclusion rules

Recorded with `counted = no` and a reason in `notes`:

| Excluded category | Examples in the CSV |
|---|---|
| Image, video, speech, voice, avatar or translation models | GPT Image 2.5, Gemini Nano Banana 2.1, Grok Imagine Video 1.5 Lite, Gemini 3.8 Flash TTS, Gemini 3.8 Live, Grok Voice Transcribe 2.0, Muse Realtime Avatar, Qwen-Audio 3.1 |
| Speed or pricing tiers of an existing model | GLM-5.3 Fast, GLM-5.3-FlashX, Muse Spark 1.3 Contributor |
| Product configurations of an existing model | OpenAI Astra for Law |
| Decision-only endpoints (no text generation) | GPT-6 Luna Decisions |
| Models that were never released or announced as products | GPT-6.1 Astra (release cancelled) |
| Roadmap mentions without a product announcement | MiniMax M3.1 / M3 Pro on the 26 August earnings call |
| Labs outside the agreed list | Xiaomi, StepFun, Meituan, Sakana AI |
| Releases just outside the windows | Grok 4.6 (12 August, one day early) |

### 4.4 Counting unit

- **One row per model.** Sizes or tiers with different weights count separately: GPT-6 Sol and GPT-6 Luna are 2; Muse Wonder and Muse Wonder Full are 2, because Meta describes them as separate checkpoints with different scores and access.
- **One row when the same model ships at two access levels:**
  - Claude Fable 5.1 / Claude Mythos 5.1: Anthropic describes them as one model at two safeguard levels.
  - Gemini 3.8 Flash / Gemini 3.8 Flash Cyber: a gated variant with looser mitigations.
  - Qwen3.8-Flash / Qwen3.8-Flash-Next: the production API build and the open-weight preview of the same model.
- **One row for an announced family:** Qwen4 (Max, Plus, Flash, 27B) was only announced, with no specs or dates, so it is 1 row.
- **One row per model across a staggered rollout:** GLM-5.3 had limited access on 14 August, its API on 19 August and open weights on 28 August. It is counted once, on 14 August.

### 4.5 Dating rule

1. **The vendor's own announcement date is the row date.** For an announced-only model, the announcement date is used.
2. Aggregator listing dates (OpenRouter, LLM Gateway, gateway catalogues) are **corroboration only**. They can lead or lag the real date by days or weeks: LLM Gateway lists Gemini 4 Argon as added on 13 October, against Google's 30 September announcement.
3. When credible sources disagree, the row keeps the best-supported date and the disagreement goes in `notes` (section 7).

### 4.6 The `top_tier` flag

`top_tier = yes` marks a model that was, at announcement, **the developer's most capable model or a new flagship generation**. For example:
- GPT-6 Astra is top-tier; GPT-6 Sol is not.
- Claude Fable 5.1 is top-tier; Claude Opus 5.5 is not, because Fable/Mythos stayed above it.

This is a judgement call and the most subjective field in the dataset.

## 5. Sources and how they were used

Research was done on 15 October 2026 using web search and page fetches. The approach had three steps:

1. **Build a candidate list from release trackers.**
   - Digital Applied's monthly release ledgers for August, September and October 2026. These date each row from the vendor's own page, so they were the main tracker.
   - No Code MBA AI release tracker (August and September 2026).
   - LLM Gateway 2026 model timeline.
2. **Check each lab separately for gaps.** Targeted searches per lab (for example "Kimi new model September 2026", "MiniMax M3.1", "ByteDance Seed September 2026") turned up releases the trackers missed: DeepSeek V4-Pro-0813, Kimi K2.8 Preview, Qwen3.8-Max-0902 and MiniMax M3.1-Flash-Preview.
3. **Confirm the date of each counted model** against at least one source quoting or linking the vendor announcement. Sources included launch coverage from DataNorth, TechCrunch, Caixin, Gigazine and Pasquale Pillitteri, plus vendor documentation (for example platform.claude.com for Claude Haiku 5.5).

**Source hierarchy:**

| Rank | Source type | Use |
|---|---|---|
| 1 | Vendor announcement, documentation or model card | Preferred for dates and release type |
| 2 | Trackers that cite vendor primaries (Digital Applied, No Code MBA) | Candidate list and dates |
| 3 | Trade press and news coverage | Corroboration, access status, cancellations |
| 4 | Aggregator listings (OpenRouter, LLM Gateway) | Corroboration only, never the date |

The `source_url` column holds the single source the row relies on most. In many rows it is a tracker or news article citing the vendor rather than the vendor page itself, because several vendor pages could not be fetched directly or render no text to a fetcher.

## 6. Reproducing the counts

The counts come straight from the CSV. This script checks that every row sits in the right window for its date and recomputes the totals:

```python
import csv, datetime as dt

rows = list(csv.DictReader(open("frontier_models_pace_the_frontier.csv")))
essay = dt.date(2026, 9, 12)

for r in rows:
    delta = (dt.date.fromisoformat(r["date"]) - essay).days
    expected = "before" if -30 <= delta <= -1 else "after" if 1 <= delta <= 30 else "outside"
    assert r["window"] == expected, (r["model"], r["date"])

for w in ("before", "after"):
    counted = [r for r in rows if r["window"] == w and r["counted"] == "yes"]
    print(w, len(counted), "top-tier:", sum(r["top_tier"] == "yes" for r in counted))
```

Output: `before 15 top-tier: 7` and `after 14 top-tier: 5`. All 52 rows are in the correct window for their date.

### CSV columns

| Column | Meaning |
|---|---|
| `window` | `before`, `after` or `outside`, derived from `date` |
| `counted` | `yes` if the row meets the inclusion rules (4.2), `no` otherwise |
| `date` | Announcement date (ISO 8601) under the dating rule (4.5) |
| `developer` | Lab or company |
| `model` | Model name; combined names mark a single counted unit (4.4) |
| `tier` | Position in the developer's lineup at announcement |
| `release_type` | GA, preview, gated, open weights, announced only, and so on |
| `top_tier` | Flag from 4.6; blank for uncounted rows |
| `notes` | Reason for exclusion, date conflicts, counting decisions |
| `source_url` | Main supporting source |

## 7. Uncertainties and sensitivity

### 7.1 Rows where the date decides the window

| Row | Date used | Conflicting date | Effect if the conflicting date is right |
|---|---|---|---|
| DeepSeek-V4-Pro-0813 | 13 Aug | OpenRouter lists 12 Aug | Moves outside the window: before = 14 |
| Kimi K2.8 Preview | 11 Sep | One source says 12 Sep | Lands on the essay day: before = 14 |
| Grok 4.6 (not counted) | 12 Aug | Rollout reportedly began 7 Aug | No effect; outside the window either way |
| Qwen3.8-Omni-Flash | 18 Sep | Some trackers say 20 Sep | No effect; stays in "after" |

**Worst case:** if both DeepSeek and Kimi move, the result is 13 before and 14 after.

### 7.2 How the result changes under other definitions

| Variant | Before | After |
|---|---|---|
| Main definition | 15 | 14 |
| Top-tier models only | 7 | 5 |
| Excluding announced-but-unreleased models (drops Qwen4) | 15 | 13 |
| Including the four borderline labs | 16 | 18 |
| Both date-sensitive rows moved out of "before" | 13 | 14 |

Under every variant the difference is between −2 and +2 models. **The direction of the change depends on the definition, but its size never exceeds 2 models.**

### 7.3 Other limitations

- **Coverage.** Searches were thorough but not exhaustive. A minor Chinese-market release announced only in Chinese, or a quiet API snapshot, could be missing. Chinese releases were checked through English and Japanese coverage plus some Chinese-language sources (DataLearner, AIBase).
- **ByteDance shows zero in both windows.** No new Seed language model was found with a date in either window. This was checked by search but not against ByteDance's own release pages.
- **Most dates come from trackers and news coverage**, not vendor pages fetched directly (section 5).
- **`top_tier` is a judgement call.** The main judgement calls:
  - Muse Spark 1.3 counts as Meta's top model before Muse Wonder existed.
  - Claude Opus 5.5 is not top-tier, because Anthropic positions Fable 5.1 above it.
  - Muse Wonder counts but is not top-tier; Muse Wonder Full is Meta's flagship.
- **Small sample.** Two 30-day windows hold about 15 models each, so a one- or two-model difference is noise. Release schedules are set months in advance, so these counts **cannot show** that the essay changed anyone's release plans.

## 8. Changing the definition

To count differently, edit the `counted` column in the CSV and rerun the script in section 6. For example:
- **To include the borderline labs:** set `counted = yes` on the rows whose notes say "outside the 13-lab list".
- **To count top-tier models only:** filter on `top_tier = yes`.

## 9. Main sources

- Dario Amodei, "We Must Pace the Frontier": https://darioamodei.com/post/we-must-pace-the-frontier
- NYU Shanghai RITS, essay summary and date: https://rits.shanghai.nyu.edu/ai/amodei-calls-to-pace-the-frontier-altman-and-musk-agree/
- Digital Applied, August 2026 ledger: https://www.digitalapplied.com/blog/ai-model-releases-august-2026-tracker
- Digital Applied, September 2026 ledger: https://www.digitalapplied.com/blog/ai-model-releases-september-2026-tracker
- Digital Applied, October 2026 ledger: https://www.digitalapplied.com/blog/ai-model-releases-october-2026-tracker
- No Code MBA, August 2026: https://www.nocode.mba/ai-release-tracker/2026/08
- No Code MBA, September 2026: https://www.nocode.mba/ai-release-tracker/2026/09
- LLM Gateway, 2026 timeline: https://llmgateway.io/timeline/2026
- GPT-6.1 Astra cancellation and DevDay context: https://pasqualepillitteri.it/en/news/19274/openai-devday-2026-keynote-live-launches-expected

The source for each model is in its CSV row.
