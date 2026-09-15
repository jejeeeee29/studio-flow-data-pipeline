from pathlib import Path
from io import StringIO
import pandas as pd
import psycopg2

BASE_DIR = Path(__file__).resolve().parent.parent
SEEDS_DIR = BASE_DIR / "seeds"

# PostgreSQL
conn = psycopg2.connect(
    dbname="studioflow",
    user="dennymangalik",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

valid_rows = []
rejected_rows = []

csv_path = SEEDS_DIR / "application_transactions.csv"

with open(csv_path, "r", encoding="utf-8") as f:

    header = f.readline().strip().split(",")

    for line in f:

        raw_line = line.strip()

        parts = raw_line.split(",")

        # Normal row
        if len(parts) == 9:
            valid_rows.append(parts)

        # Malformed amount: 1,250.00
        elif len(parts) == 10:
            fixed_amount = parts[5] + parts[6]

            fixed = (
                parts[:5]
                + [fixed_amount]
                + parts[7:]
            )

            valid_rows.append(fixed)

        # Totally broken row
        else:
            rejected_rows.append(
                [raw_line, "MALFORMED_CSV_ROW"]
            )

# DataFrame
df = pd.DataFrame(valid_rows, columns=header)

# Timestamp validation
df["transaction_ts"] = pd.to_datetime(
    df["transaction_ts"],
    errors="coerce"
)

invalid_ts = df[df["transaction_ts"].isna()]

for _, row in invalid_ts.iterrows():
    rejected_rows.append(
        [
            ",".join(row.fillna("").astype(str)),
            "INVALID_TIMESTAMP",
        ]
    )

df = df[df["transaction_ts"].notna()]

# Load valid rows
cur.execute("TRUNCATE TABLE raw.application_transactions;")
cur.execute("TRUNCATE TABLE raw.rejected_transactions;")

buffer = StringIO()
df.to_csv(buffer, index=False, header=False)
buffer.seek(0)

cur.copy_expert(
    """
    COPY raw.application_transactions
    FROM STDIN
    WITH CSV
    """,
    buffer,
)

# Load rejected rows
if rejected_rows:

    reject_df = pd.DataFrame(
        rejected_rows,
        columns=["raw_line", "reason_code"],
    )

    reject_buffer = StringIO()
    reject_df.to_csv(
        reject_buffer,
        index=False,
        header=False,
    )
    reject_buffer.seek(0)

    cur.copy_expert(
        """
        COPY raw.rejected_transactions
        (raw_line, reason_code)
        FROM STDIN
        WITH CSV
        """,
        reject_buffer,
    )

conn.commit()

print(f"Valid transactions   : {len(df)}")
print(f"Rejected transactions: {len(rejected_rows)}")

cur.close()
conn.close()