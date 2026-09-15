-- ============================================
-- StudioFlow Data Engineering Assessment
-- Raw Layer DDL
-- ============================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;

-- Customers
DROP TABLE IF EXISTS raw.customers;
CREATE TABLE raw.customers (
    customer_id TEXT,
    signup_date DATE,
    acquisition_channel TEXT,
    country_code TEXT
);

-- FX Rates
DROP TABLE IF EXISTS raw.fx_rates;
CREATE TABLE raw.fx_rates (
    month_start DATE,
    currency TEXT,
    usd_per_unit NUMERIC(12,4)
);

-- Application Transactions
DROP TABLE IF EXISTS raw.application_transactions;
CREATE TABLE raw.application_transactions (
    transaction_id TEXT,
    customer_id TEXT,
    transaction_ts TEXT,
    transaction_type TEXT,
    status TEXT,
    amount TEXT,
    currency TEXT,
    provider_reference TEXT,
    ingested_at TEXT
);

-- Manual Adjustments
DROP TABLE IF EXISTS raw.manual_adjustments;
CREATE TABLE raw.manual_adjustments (
    adjustment_id TEXT,
    month_start DATE,
    adjustment_type TEXT,
    amount_usd NUMERIC(12,2),
    reason TEXT
);

-- Capacity Records
DROP TABLE IF EXISTS raw.capacity_records;
CREATE TABLE raw.capacity_records (
    record_id TEXT,
    period_start DATE,
    team_id TEXT,
    designer_id TEXT,
    capacity_points INTEGER,
    slides_completed INTEGER,
    logic_version TEXT,
    updated_at TIMESTAMP
);

-- Finance Control Totals
DROP TABLE IF EXISTS raw.finance_control_totals;
CREATE TABLE raw.finance_control_totals (
    month_start DATE,
    application_net_revenue_usd NUMERIC(14,2),
    manual_net_revenue_usd NUMERIC(14,2),
    expected_net_revenue_usd NUMERIC(14,2),
    expected_application_record_count INTEGER,
    expected_manual_record_count INTEGER
);

-- Rejected Transactions
DROP TABLE IF EXISTS raw.rejected_transactions;
CREATE TABLE raw.rejected_transactions (
    raw_line TEXT,
    reason_code TEXT,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);