-- ============================================================
-- Aurelia Enterprise Cloud Data & Analytics Platform
-- Phase 2 Business Validation
--
-- Purpose:
--   Validate that the generated operational dataset contains
--   meaningful business scenarios for later analytics work.
-- ============================================================


-- ============================================================
-- 1. Resource Over-Allocation
-- ============================================================

SELECT
    e.employee_number,
    e.first_name,
    e.last_name,
    ra.planning_week,
    SUM(ra.allocated_hours) AS allocated_hours
FROM operations.resource_allocation ra
JOIN operations.employee e
    ON ra.employee_id = e.employee_id
GROUP BY
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    ra.planning_week
HAVING SUM(ra.allocated_hours) > 40
ORDER BY allocated_hours DESC;


-- ============================================================
-- 2. Resource Under-Utilization
-- Compare actual hours against available capacity.
-- ============================================================

WITH weekly_capacity AS (
    SELECT
        employee_id,
        DATE_TRUNC('week', work_date)::date AS planning_week,
        SUM(available_hours) AS available_hours
    FROM operations.employee_capacity
    GROUP BY
        employee_id,
        DATE_TRUNC('week', work_date)::date
),

weekly_actual AS (
    SELECT
        employee_id,
        DATE_TRUNC('week', work_date)::date AS planning_week,
        SUM(hours_worked) AS actual_hours
    FROM operations.timesheet_entry
    GROUP BY
        employee_id,
        DATE_TRUNC('week', work_date)::date
)

SELECT
    e.employee_number,
    e.first_name,
    e.last_name,
    wc.planning_week,
    wc.available_hours,
    COALESCE(wa.actual_hours, 0) AS actual_hours,

    ROUND(
        (
            COALESCE(wa.actual_hours, 0)
            / NULLIF(wc.available_hours, 0)
        ) * 100,
        2
    ) AS utilization_percent

FROM weekly_capacity wc

JOIN operations.employee e
    ON wc.employee_id = e.employee_id

LEFT JOIN weekly_actual wa
    ON wc.employee_id = wa.employee_id
    AND wc.planning_week = wa.planning_week

WHERE
    COALESCE(wa.actual_hours, 0)
    < wc.available_hours * 0.50

ORDER BY
    utilization_percent ASC,
    wc.planning_week;


-- ============================================================
-- 3. Planned vs Actual Hours
-- ============================================================

WITH planned AS (
    SELECT
        employee_id,
        project_id,
        planning_week,
        SUM(allocated_hours) AS planned_hours
    FROM operations.resource_allocation
    GROUP BY
        employee_id,
        project_id,
        planning_week
),

actual AS (
    SELECT
        employee_id,
        project_id,
        DATE_TRUNC('week', work_date)::date AS planning_week,
        SUM(hours_worked) AS actual_hours
    FROM operations.timesheet_entry
    GROUP BY
        employee_id,
        project_id,
        DATE_TRUNC('week', work_date)::date
)

SELECT
    e.employee_number,
    p.project_number,
    pl.planning_week,
    pl.planned_hours,
    COALESCE(ac.actual_hours, 0) AS actual_hours,

    COALESCE(ac.actual_hours, 0)
        - pl.planned_hours AS variance_hours

FROM planned pl

JOIN operations.employee e
    ON pl.employee_id = e.employee_id

JOIN operations.project p
    ON pl.project_id = p.project_id

LEFT JOIN actual ac
    ON pl.employee_id = ac.employee_id
    AND pl.project_id = ac.project_id
    AND pl.planning_week = ac.planning_week

ORDER BY
    ABS(
        COALESCE(ac.actual_hours, 0)
        - pl.planned_hours
    ) DESC;


-- ============================================================
-- 4. Baseline vs Forecast Project Budget
-- ============================================================

WITH budget_summary AS (
    SELECT
        project_id,

        SUM(
            CASE
                WHEN budget_version = 'BASELINE'
                THEN budget_amount
                ELSE 0
            END
        ) AS baseline_budget,

        SUM(
            CASE
                WHEN budget_version = 'FORECAST-01'
                THEN budget_amount
                ELSE 0
            END
        ) AS forecast_budget

    FROM operations.project_budget

    GROUP BY project_id
)

SELECT
    p.project_number,
    p.project_name,
    bs.baseline_budget,
    bs.forecast_budget,

    bs.forecast_budget
        - bs.baseline_budget
        AS budget_variance,

    ROUND(
        (
            (
                bs.forecast_budget
                - bs.baseline_budget
            )
            / NULLIF(bs.baseline_budget, 0)
        ) * 100,
        2
    ) AS variance_percent

FROM budget_summary bs

JOIN operations.project p
    ON bs.project_id = p.project_id

ORDER BY
    ABS(
        bs.forecast_budget
        - bs.baseline_budget
    ) DESC;


-- ============================================================
-- 5. Invoice Line Reconciliation
-- ============================================================

SELECT
    i.invoice_number,
    i.total_amount AS invoice_total,
    SUM(il.line_amount) AS invoice_line_total,

    i.total_amount
        - SUM(il.line_amount)
        AS difference

FROM operations.invoice i

JOIN operations.invoice_line il
    ON i.invoice_id = il.invoice_id

GROUP BY
    i.invoice_id,
    i.invoice_number,
    i.total_amount

HAVING
    i.total_amount
    <> SUM(il.line_amount)

ORDER BY
    ABS(
        i.total_amount
        - SUM(il.line_amount)
    ) DESC;


-- Expected:
-- 0 rows


-- ============================================================
-- 6. Invoice Outstanding Balance
-- ============================================================

SELECT
    c.client_number,
    c.client_name,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.total_amount,

    COALESCE(
        SUM(pa.allocated_amount),
        0
    ) AS paid_amount,

    i.total_amount
        - COALESCE(
            SUM(pa.allocated_amount),
            0
        ) AS outstanding_amount

FROM operations.invoice i

JOIN operations.client c
    ON i.client_id = c.client_id

LEFT JOIN operations.payment_allocation pa
    ON i.invoice_id = pa.invoice_id

GROUP BY
    c.client_id,
    c.client_number,
    c.client_name,
    i.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.total_amount

HAVING
    i.total_amount
    - COALESCE(
        SUM(pa.allocated_amount),
        0
    ) > 0

ORDER BY
    outstanding_amount DESC;


-- ============================================================
-- 7. Unpaid / Late Invoices
-- ============================================================

WITH invoice_balance AS (
    SELECT
        i.invoice_id,
        i.client_id,
        i.invoice_number,
        i.invoice_date,
        i.due_date,
        i.total_amount,

        COALESCE(
            SUM(pa.allocated_amount),
            0
        ) AS paid_amount

    FROM operations.invoice i

    LEFT JOIN operations.payment_allocation pa
        ON i.invoice_id = pa.invoice_id

    GROUP BY
        i.invoice_id,
        i.client_id,
        i.invoice_number,
        i.invoice_date,
        i.due_date,
        i.total_amount
)

SELECT
    c.client_number,
    c.client_name,
    ib.invoice_number,
    ib.invoice_date,
    ib.due_date,
    ib.total_amount,
    ib.paid_amount,

    ib.total_amount
        - ib.paid_amount
        AS outstanding_amount,

    CURRENT_DATE
        - ib.due_date
        AS days_past_due

FROM invoice_balance ib

JOIN operations.client c
    ON ib.client_id = c.client_id

WHERE
    ib.total_amount > ib.paid_amount
    AND ib.due_date < CURRENT_DATE

ORDER BY
    days_past_due DESC;


-- ============================================================
-- 8. Client Receivables
-- ============================================================

WITH invoice_balance AS (
    SELECT
        i.client_id,
        i.invoice_id,
        i.total_amount,

        COALESCE(
            SUM(pa.allocated_amount),
            0
        ) AS paid_amount

    FROM operations.invoice i

    LEFT JOIN operations.payment_allocation pa
        ON i.invoice_id = pa.invoice_id

    GROUP BY
        i.client_id,
        i.invoice_id,
        i.total_amount
)

SELECT
    c.client_number,
    c.client_name,

    SUM(ib.total_amount) AS total_invoiced,

    SUM(ib.paid_amount) AS total_paid,

    SUM(
        ib.total_amount
        - ib.paid_amount
    ) AS total_outstanding

FROM invoice_balance ib

JOIN operations.client c
    ON ib.client_id = c.client_id

GROUP BY
    c.client_id,
    c.client_number,
    c.client_name

ORDER BY
    total_outstanding DESC;


-- ============================================================
-- 9. Revenue by Project
-- ============================================================

SELECT
    p.project_number,
    p.project_name,
    SUM(i.total_amount) AS invoiced_revenue
FROM operations.project p

JOIN operations.invoice i
    ON p.project_id = i.project_id

GROUP BY
    p.project_id,
    p.project_number,
    p.project_name

ORDER BY
    invoiced_revenue DESC;


-- ============================================================
-- 10. GL Journal Balance
-- ============================================================

SELECT
    j.journal_number,

    SUM(e.debit_amount) AS total_debit,

    SUM(e.credit_amount) AS total_credit,

    SUM(e.debit_amount)
        - SUM(e.credit_amount)
        AS difference

FROM operations.gl_journal j

JOIN operations.gl_entry e
    ON j.gl_journal_id = e.gl_journal_id

GROUP BY
    j.gl_journal_id,
    j.journal_number

HAVING
    SUM(e.debit_amount)
    <> SUM(e.credit_amount);


-- Expected:
-- 0 rows


-- ============================================================
-- 11. Referential / Date Sanity:
-- Timesheets Outside Project Dates
-- ============================================================

SELECT
    t.timesheet_entry_id,
    e.employee_number,
    p.project_number,
    t.work_date,
    p.start_date,
    p.end_date

FROM operations.timesheet_entry t

JOIN operations.employee e
    ON t.employee_id = e.employee_id

JOIN operations.project p
    ON t.project_id = p.project_id

WHERE
    t.work_date < p.start_date

    OR (
        p.end_date IS NOT NULL
        AND t.work_date > p.end_date
    )

ORDER BY
    t.work_date;


-- Ideally:
-- 0 rows


-- ============================================================
-- 12. Dataset Summary
-- ============================================================

SELECT
    'Employees' AS metric,
    COUNT(*)::numeric AS value
FROM operations.employee

UNION ALL

SELECT
    'Clients',
    COUNT(*)::numeric
FROM operations.client

UNION ALL

SELECT
    'Contracts',
    COUNT(*)::numeric
FROM operations.contract

UNION ALL

SELECT
    'Projects',
    COUNT(*)::numeric
FROM operations.project

UNION ALL

SELECT
    'Resource Allocations',
    COUNT(*)::numeric
FROM operations.resource_allocation

UNION ALL

SELECT
    'Capacity Records',
    COUNT(*)::numeric
FROM operations.employee_capacity

UNION ALL

SELECT
    'Timesheet Entries',
    COUNT(*)::numeric
FROM operations.timesheet_entry

UNION ALL

SELECT
    'Invoices',
    COUNT(*)::numeric
FROM operations.invoice

UNION ALL

SELECT
    'Payments',
    COUNT(*)::numeric
FROM operations.payment

UNION ALL

SELECT
    'GL Journals',
    COUNT(*)::numeric
FROM operations.gl_journal

ORDER BY metric;