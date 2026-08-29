-- ============================================================
-- Aurelia Enterprise Cloud Data & Analytics Platform
-- Indexes and Operational Views
-- ============================================================


-- ============================================================
-- 1. Employee Indexes
-- ============================================================

CREATE INDEX idx_employee_business_unit
ON operations.employee (
    business_unit_id
);

CREATE INDEX idx_employee_cost_center
ON operations.employee (
    cost_center_id
);


-- ============================================================
-- 2. Contract / Project Indexes
-- ============================================================

CREATE INDEX idx_contract_client
ON operations.contract (
    client_id
);

CREATE INDEX idx_project_client
ON operations.project (
    client_id
);

CREATE INDEX idx_project_contract
ON operations.project (
    contract_id
);


-- ============================================================
-- 3. Resource Planning Indexes
-- ============================================================

CREATE INDEX idx_resource_allocation_employee_week
ON operations.resource_allocation (
    employee_id,
    planning_week
);

CREATE INDEX idx_resource_allocation_project_week
ON operations.resource_allocation (
    project_id,
    planning_week
);

CREATE INDEX idx_employee_capacity_employee_date
ON operations.employee_capacity (
    employee_id,
    work_date
);


-- ============================================================
-- 4. Timesheet Indexes
-- ============================================================

CREATE INDEX idx_timesheet_employee_date
ON operations.timesheet_entry (
    employee_id,
    work_date
);

CREATE INDEX idx_timesheet_project_date
ON operations.timesheet_entry (
    project_id,
    work_date
);


-- ============================================================
-- 5. Finance Indexes
-- ============================================================

CREATE INDEX idx_invoice_client_date
ON operations.invoice (
    client_id,
    invoice_date
);

CREATE INDEX idx_payment_client_date
ON operations.payment (
    client_id,
    payment_date
);

CREATE INDEX idx_gl_entry_project
ON operations.gl_entry (
    project_id
);


-- ============================================================
-- 6. Project Summary View
-- ============================================================

CREATE VIEW operations.vw_project_summary AS

SELECT
    p.project_id,
    p.project_number,
    p.project_name,
    p.project_status,
    p.start_date,
    p.end_date,
    p.is_billable,
    p.is_active,

    c.client_id,
    c.client_number,
    c.client_name,

    s.service_id,
    s.service_code,
    s.service_name,

    p.project_manager_employee_id,

    pm.employee_number AS project_manager_employee_number,
    pm.first_name AS project_manager_first_name,
    pm.last_name AS project_manager_last_name

FROM operations.project p

JOIN operations.client c
    ON p.client_id = c.client_id

JOIN operations.service s
    ON p.service_id = s.service_id

LEFT JOIN operations.employee pm
    ON p.project_manager_employee_id = pm.employee_id;


-- ============================================================
-- 7. Employee Resource Summary View
-- ============================================================

CREATE VIEW operations.vw_employee_resource_summary AS

SELECT
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    e.email,

    e.hire_date,
    e.termination_date,
    e.is_active,

    bu.business_unit_id,
    bu.business_unit_code,
    bu.business_unit_name,

    cc.cost_center_id,
    cc.cost_center_code,
    cc.cost_center_name

FROM operations.employee e

JOIN operations.business_unit bu
    ON e.business_unit_id = bu.business_unit_id

JOIN operations.cost_center cc
    ON e.cost_center_id = cc.cost_center_id;