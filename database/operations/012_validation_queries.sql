-- 1. Row counts

SELECT 'employee' AS table_name, COUNT(*) AS row_count
FROM operations.employee

UNION ALL

SELECT 'client', COUNT(*)
FROM operations.client

UNION ALL

SELECT 'contract', COUNT(*)
FROM operations.contract

UNION ALL

SELECT 'project', COUNT(*)
FROM operations.project

UNION ALL

SELECT 'resource_allocation', COUNT(*)
FROM operations.resource_allocation

UNION ALL

SELECT 'employee_capacity', COUNT(*)
FROM operations.employee_capacity

UNION ALL

SELECT 'timesheet_entry', COUNT(*)
FROM operations.timesheet_entry

UNION ALL

SELECT 'invoice', COUNT(*)
FROM operations.invoice

UNION ALL

SELECT 'payment', COUNT(*)
FROM operations.payment;


-- 2. Projects by client

SELECT
    c.client_name,
    COUNT(p.project_id) AS project_count
FROM operations.client c
JOIN operations.project p
    ON c.client_id = p.client_id
GROUP BY
    c.client_id,
    c.client_name
ORDER BY project_count DESC;

-- 3. Actual hours by project

SELECT
    p.project_number,
    p.project_name,
    SUM(t.hours_worked) AS actual_hours
FROM operations.project p
JOIN operations.timesheet_entry t
    ON p.project_id = t.project_id
GROUP BY
    p.project_id,
    p.project_number,
    p.project_name
ORDER BY actual_hours DESC;



-- 4. Planned allocation by employee

SELECT
    e.employee_number,
    e.first_name,
    e.last_name,
    SUM(r.allocated_hours) AS planned_hours
FROM operations.employee e
JOIN operations.resource_allocation r
    ON e.employee_id = r.employee_id
GROUP BY
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name
ORDER BY planned_hours DESC;



-- 5. Employees allocated more than 40 hours in one week

SELECT
    e.employee_number,
    e.first_name,
    e.last_name,
    r.planning_week,
    SUM(r.allocated_hours) AS allocated_hours
FROM operations.resource_allocation r
JOIN operations.employee e
    ON r.employee_id = e.employee_id
GROUP BY
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    r.planning_week
HAVING SUM(r.allocated_hours) > 40
ORDER BY allocated_hours DESC;



-- 6. Invoice balance

SELECT
    i.invoice_number,
    i.invoice_date,
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
LEFT JOIN operations.payment_allocation pa
    ON i.invoice_id = pa.invoice_id
GROUP BY
    i.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.total_amount
ORDER BY outstanding_amount DESC;



-- 7. Project budget summary

WITH project_budget AS (
    SELECT
        project_id,
        SUM(budget_amount) AS total_budget
    FROM operations.project_budget
    WHERE budget_version = 'BASELINE'
    GROUP BY project_id
),

project_hours AS (
    SELECT
        project_id,
        SUM(hours_worked) AS actual_hours
    FROM operations.timesheet_entry
    GROUP BY project_id
)

SELECT
    p.project_number,
    p.project_name,
    pb.total_budget,
    ph.actual_hours
FROM operations.project p
LEFT JOIN project_budget pb
    ON p.project_id = pb.project_id
LEFT JOIN project_hours ph
    ON p.project_id = ph.project_id
ORDER BY pb.total_budget DESC;


-- 8. Rank projects by actual hours

WITH project_hours AS (
    SELECT
        project_id,
        SUM(hours_worked) AS actual_hours
    FROM operations.timesheet_entry
    GROUP BY project_id
)

SELECT
    p.project_number,
    p.project_name,
    ph.actual_hours,

    RANK() OVER (
        ORDER BY ph.actual_hours DESC
    ) AS hours_rank

FROM project_hours ph

JOIN operations.project p
    ON ph.project_id = p.project_id

ORDER BY hours_rank;


-- 9. Check GL journal balance

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


EXPLAIN ANALYZE

SELECT *
FROM operations.employee_capacity
WHERE employee_id = 10
  AND work_date >= DATE '2026-01-01';


EXPLAIN ANALYZE

SELECT *
FROM operations.payment
WHERE client_id = 10
  AND payment_date >= DATE '2026-01-01';

EXPLAIN ANALYZE

SELECT *
FROM operations.timesheet_entry
WHERE employee_id = 25
  AND work_date BETWEEN DATE '2026-01-01'
                    AND DATE '2026-06-30';