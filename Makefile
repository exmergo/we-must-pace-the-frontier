# Reproduce the study end to end: make all
.PHONY: all load

all: load

load:  ## Load data/frontier_models_pace_the_frontier.csv into warehouse/pace_the_frontier.duckdb (schema raw)
	uv run python scripts/load_raw.py
