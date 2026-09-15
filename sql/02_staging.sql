DROP TABLE IF EXISTS staging.transactions_clean;

CREATE TABLE staging.transactions_clean AS

SELECT DISTINCT ON (transaction_id)

    transaction_id,
    customer_id,

    transaction_ts,

    LOWER(status) AS status,

    LOWER(transaction_type) AS transaction_type,

    currency,

    CAST(amount AS NUMERIC(12,2)) AS amount,

    provider_reference,

    ingested_at

FROM raw.application_transactions

ORDER BY
    transaction_id,
    ingested_at DESC;