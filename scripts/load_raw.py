from pathlib import Path
from io import StringIO
import pandas as pd
import psycopg2

# ==========================
# PATH
# ==========================
BASE_DIR = Path(__file__).resolve().parent.parent
SEEDS_DIR = BASE_DIR / "seeds"

# ==========================
# DB CONNECTION
# ==========================
conn = psycopg2.connect(
    dbname="studioflow",
    user="dennymangalik",
    host="localhost",
    port="5432"
)

cur = conn.cursor()


# ==========================
# GENERIC CSV LOADER
# ==========================
def load_csv(csv_name, table_name):

    df = pd.read_csv(SEEDS_DIR / csv_name)

    # Special handling for capacity_records
    if table_name == "capacity_records":
        int_cols = ["capacity_points", "slides_completed"]

        for col in int_cols:
            df[col] = (
                pd.to_numeric(df[col], errors="coerce")
                .fillna(0)
                .astype(int)
            )

    print(f"Loading {csv_name} ({len(df)} rows)...")

    # Make pipeline idempotent
    cur.execute(f"TRUNCATE TABLE raw.{table_name};")

    # DataFrame -> CSV buffer
    buffer = StringIO()
    df.to_csv(buffer, index=False, header=False)
    buffer.seek(0)

    columns = ", ".join(df.columns)

    cur.copy_expert(
        f"""
        COPY raw.{table_name} ({columns})
        FROM STDIN
        WITH CSV
        """,
        buffer
)

    conn.commit()
    print(f"✅ raw.{table_name} loaded")


# ==========================
# RUN PIPELINE
# ==========================
load_csv("customers.csv", "customers")
load_csv("fx_rates.csv", "fx_rates")
load_csv("manual_adjustments.csv", "manual_adjustments")
load_csv("capacity_records.csv", "capacity_records")
load_csv("finance_control_totals.csv", "finance_control_totals")

cur.close()
conn.close()

print("\n RAW ETL FINISHED!")