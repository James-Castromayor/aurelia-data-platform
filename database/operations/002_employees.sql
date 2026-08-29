CREATE TABLE operations.employee (
    employee_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    employee_number VARCHAR(30) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,

    business_unit_id BIGINT,
    cost_center_id BIGINT,

    hire_date DATE NOT NULL,
    termination_date DATE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_employee_number UNIQUE (employee_number),
    CONSTRAINT uq_employee_email UNIQUE (email),

    CONSTRAINT fk_employee_business_unit
        FOREIGN KEY (business_unit_id)
        REFERENCES operations.business_unit (business_unit_id),

    CONSTRAINT fk_employee_cost_center
        FOREIGN KEY (cost_center_id)
        REFERENCES operations.cost_center (cost_center_id),

    CONSTRAINT chk_employee_number_not_blank
        CHECK (BTRIM(employee_number) <> ''),

    CONSTRAINT chk_employee_first_name_not_blank
        CHECK (BTRIM(first_name) <> ''),

    CONSTRAINT chk_employee_last_name_not_blank
        CHECK (BTRIM(last_name) <> ''),

    CONSTRAINT chk_employee_dates
        CHECK (
            termination_date IS NULL
            OR termination_date >= hire_date
        )
);


CREATE TABLE operations.employee_skill (
    employee_id BIGINT NOT NULL,
    skill_id BIGINT NOT NULL,

    proficiency_level SMALLINT,
    years_experience NUMERIC(4,1),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_employee_skill
        PRIMARY KEY (employee_id, skill_id),

    CONSTRAINT fk_employee_skill_employee
        FOREIGN KEY (employee_id)
        REFERENCES operations.employee (employee_id),

    CONSTRAINT fk_employee_skill_skill
        FOREIGN KEY (skill_id)
        REFERENCES operations.skill (skill_id),

    CONSTRAINT chk_employee_skill_proficiency
        CHECK (
            proficiency_level IS NULL
            OR proficiency_level BETWEEN 1 AND 5
        ),

    CONSTRAINT chk_employee_skill_experience
        CHECK (
            years_experience IS NULL
            OR years_experience >= 0
        )
);