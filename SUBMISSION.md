# StudioFlow Data Engineering Assessment — Submission

## Candidate

**Name:** Jihan Salsabilah

---

## Solution Summary

I implemented an end-to-end ETL pipeline using **Python**, **Pandas**, and **PostgreSQL** with a layered warehouse architecture:

* **Raw** → Source ingestion
* **Staging** → Validation, normalization, and deduplication
* **Mart** → Business-ready analytical tables

The pipeline preserves source data while keeping all transformations reproducible.

## Data Quality Handling

The application transaction dataset contained several malformed records.

Implemented handling includes:

* Invalid timestamps → quarantined
* Malformed currency values (`1,250.00`) → repaired during ingestion
* Duplicate transaction IDs → latest record retained
* Invalid CSV rows → stored in `raw.rejected_transactions`

No source CSV files were modified.

## Deliverables

Implemented marts:

* `mart.revenue_usd`
* `mart.reconciliation_report`
* `mart.capacity_summary`

## Reconciliation Findings

The reconciliation report compares calculated revenue against Finance Control Totals.

Observed results:

* Monthly revenue variance identified
* Application record count variance identified
* Variances are surfaced for investigation instead of being automatically corrected

## Assumptions

* Only `status = 'succeeded'` contributes to revenue.
* FX conversion uses the monthly exchange rate from `fx_rates`.
* Raw data remains immutable; all cleaning occurs in staging or during ingestion.

## Tech Stack

* Python
* Pandas
* PostgreSQL
* Psycopg2
* SQL

