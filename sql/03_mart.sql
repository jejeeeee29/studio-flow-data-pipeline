CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS mart.revenue_usd;

CREATE TABLE mart.revenue_usd AS

SELECT
    t.transaction_id,
    t.customer_id,
    DATE_TRUNC('month', t.transaction_ts)::date AS month_start,

    t.currency,
    t.amount,

    fx.usd_per_unit,

    ROUND(t.amount * fx.usd_per_unit, 2) AS revenue_usd,

    t.status,
    t.transaction_type

FROM staging.transactions_clean t

LEFT JOIN raw.fx_rates fx
    ON fx.currency = t.currency
   AND fx.month_start = DATE_TRUNC('month', t.transaction_ts)::date

WHERE t.status = 'succeeded';