CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS mart.capacity_summary;

CREATE TABLE mart.capacity_summary AS

SELECT
    period_start,

    team_id,

    SUM(slides_completed) AS total_slides_completed,

    SUM(capacity_points) AS total_capacity_points,

    ROUND(
        SUM(slides_completed)::numeric /
        NULLIF(SUM(capacity_points), 0),
        2
    ) AS utilization_ratio

FROM raw.capacity_records

GROUP BY
    period_start,
    team_id

ORDER BY
    period_start,
    team_id;