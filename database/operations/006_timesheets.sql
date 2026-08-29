CREATE TABLE operations.timesheet_entry (
    timesheet_entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    employee_id BIGINT NOT NULL,
    project_id BIGINT,
    service_id BIGINT,

    work_date DATE NOT NULL,
    hours_worked NUMERIC(5,2) NOT NULL,

    activity_code VARCHAR(50),
    description VARCHAR(255),

    is_billable BOOLEAN NOT NULL DEFAULT TRUE,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_timesheet_employee
        FOREIGN KEY (employee_id)
        REFERENCES operations.employee (employee_id),

    CONSTRAINT fk_timesheet_project
        FOREIGN KEY (project_id)
        REFERENCES operations.project (project_id),

    CONSTRAINT fk_timesheet_service
        FOREIGN KEY (service_id)
        REFERENCES operations.service (service_id),

    CONSTRAINT chk_timesheet_hours
        CHECK (hours_worked > 0 AND hours_worked <= 24)
);