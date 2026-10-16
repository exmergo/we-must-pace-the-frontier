# Reproduce the study end to end: make all
# Needs uv (https://docs.astral.sh/uv/). Everything else is pinned in pyproject.toml / uv.lock.
.PHONY: all load build gold check

all: load build gold

load:  ## Copy data/frontier_models_pace_the_frontier.csv into warehouse/pace_the_frontier.duckdb (schema raw)
	uv run python scripts/load_raw.py

build:  ## Build and test the dbt project (seeds, staging, intermediate, marts, semantic manifest)
	cd pace_the_frontier && uv run dbt build --profiles-dir .

gold:  ## Run the gold MetricFlow queries through Dex and write results/gold/*.csv
	uv run python scripts/export_gold.py

check:  ## Ask Dex whether the project still matches the warehouse and its committed baseline
	uv run dex maintain verify
	uv run dex maintain check
