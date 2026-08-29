CREATE TABLE operations.resource_allocation (
    resource_allocation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    employee_id BIGINT NOT NULL,
    project_id BIGINT NOT NULL,

    planning_week DATE NOT NULL,
    allocated_hours NUMERIC(6,2) NOT NULL,

    allocation_status VARCHAR(30) NOT NULL DEFAULT 'PLANNED',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_allocation_employee
        FOREIGN KEY (employee_id)
        REFERENCES operations.employee (employee_id),

    CONSTRAINT fk_resource_allocation_project
        FOREIGN KEY (project_id)
        REFERENCES operations.project (project_id),

    CONSTRAINT uq_resource_allocation
        UNIQUE (employee_id, project_id, planning_week),

    CONSTRAINT chk_resource_allocation_hours
        CHECK (allocated_hours >= 0)
);


CREATE TABLE operations.employee_capacity (
    employee_capacity_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    employee_id BIGINT NOT NULL,

    work_date DATE NOT NULL,
    available_hours NUMERIC(5,2) NOT NULL,

    capacity_type VARCHAR(30) NOT NULL DEFAULT 'STANDARD',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_employee_capacity_employee
        FOREIGN KEY (employee_id)
        REFERENCES operations.employee (employee_id),

    CONSTRAINT uq_employee_capacity
        UNIQUE (employee_id, work_date),

    CONSTRAINT chk_employee_capacity_hours
        CHECK (available_hours >= 0)
);