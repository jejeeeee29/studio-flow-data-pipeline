CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS mart.reconciliation_report;

CREATE TABLE mart.reconciliation_report AS

SELECT
    f.month_start,

    ROUND(COALESCE(SUM(r.revenue_usd), 0), 2)
        AS calculated_net_revenue_usd,

    f.expected_net_revenue_usd,

    ROUND(
        COALESCE(SUM(r.revenue_usd), 0)
        - f.expected_net_revenue_usd,
        2
    ) AS variance_usd,

    COUNT(r.transaction_id)
        AS calculated_application_record_count,

    f.expected_application_record_count

FROM raw.finance_control_totals f

LEFT JOIN mart.revenue_usd r
    ON r.month_start = f.month_start

GROUP BY
    f.month_start,
    f.expected_net_revenue_usd,
    f.expected_application_record_count

ORDER BY f.month_start;