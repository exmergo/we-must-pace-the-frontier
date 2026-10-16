"""Load the raw research CSV into the DuckDB warehouse, untouched.

Every column lands as VARCHAR on purpose. DuckDB's type sniffer would turn
`counted` and `top_tier` into BOOLEAN and `date` into DATE; the dbt staging
layer owns those casts, so the raw table stays a faithful copy of the file.

Usage: uv run python scripts/load_raw.py
"""

from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent.parent
CSV = ROOT / "data" / "frontier_models_pace_the_frontier.csv"
WAREHOUSE = ROOT / "warehouse" / "pace_the_frontier.duckdb"


def main() -> None:
    WAREHOUSE.parent.mkdir(exist_ok=True)
    con = duckdb.connect(str(WAREHOUSE))
    con.execute("create schema if not exists raw")
    con.execute(
        """
        create or replace table raw.frontier_model_candidates as
        select
            *,
            ? as _source_file,
            current_timestamp as _loaded_at
        from read_csv(?, header = true, all_varchar = true)
        """,
        [CSV.relative_to(ROOT).as_posix(), str(CSV)],
    )
    rows = con.execute("select count(*) from raw.frontier_model_candidates").fetchone()[0]
    con.close()
    print(f"loaded {rows} rows into raw.frontier_model_candidates ({WAREHOUSE.relative_to(ROOT)})")


if __name__ == "__main__":
    main()
