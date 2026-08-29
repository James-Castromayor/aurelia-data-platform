CREATE TABLE operations.project_budget (
    project_budget_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    project_id BIGINT NOT NULL,

    budget_version VARCHAR(30) NOT NULL,
    budget_category VARCHAR(50) NOT NULL,

    budget_amount NUMERIC(18,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'USD',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_project_budget_project
        FOREIGN KEY (project_id)
        REFERENCES operations.project (project_id),

    CONSTRAINT uq_project_budget
        UNIQUE (project_id, budget_version, budget_category),

    CONSTRAINT chk_project_budget_amount
        CHECK (budget_amount >= 0),

    CONSTRAINT chk_project_budget_version_not_blank
        CHECK (BTRIM(budget_version) <> ''),

    CONSTRAINT chk_project_budget_category_not_blank
        CHECK (BTRIM(budget_category) <> '')
);