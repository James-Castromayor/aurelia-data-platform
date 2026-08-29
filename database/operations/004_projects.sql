CREATE TABLE operations.project (
    project_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    client_id BIGINT NOT NULL,
    contract_id BIGINT,
    service_id BIGINT,

    project_number VARCHAR(30) NOT NULL,
    project_name VARCHAR(150) NOT NULL,

    project_status VARCHAR(30) NOT NULL DEFAULT 'PLANNED',

    start_date DATE NOT NULL,
    end_date DATE,

    project_manager_employee_id BIGINT,

    is_billable BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_project_number UNIQUE (project_number),

    CONSTRAINT fk_project_client
        FOREIGN KEY (client_id)
        REFERENCES operations.client (client_id),

    CONSTRAINT fk_project_contract
        FOREIGN KEY (contract_id)
        REFERENCES operations.contract (contract_id),

    CONSTRAINT fk_project_service
        FOREIGN KEY (service_id)
        REFERENCES operations.service (service_id),

    CONSTRAINT fk_project_manager
        FOREIGN KEY (project_manager_employee_id)
        REFERENCES operations.employee (employee_id),

    CONSTRAINT chk_project_number_not_blank
        CHECK (BTRIM(project_number) <> ''),

    CONSTRAINT chk_project_name_not_blank
        CHECK (BTRIM(project_name) <> ''),

    CONSTRAINT chk_project_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        )
);


CREATE TABLE operations.project_milestone (
    project_milestone_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    project_id BIGINT NOT NULL,

    milestone_name VARCHAR(150) NOT NULL,
    milestone_status VARCHAR(30) NOT NULL DEFAULT 'PLANNED',

    planned_date DATE,
    completed_date DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_project_milestone_project
        FOREIGN KEY (project_id)
        REFERENCES operations.project (project_id),

    CONSTRAINT chk_project_milestone_name_not_blank
        CHECK (BTRIM(milestone_name) <> '')
);