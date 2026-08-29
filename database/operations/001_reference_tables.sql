-- ============================================================
-- Aurelia Enterprise Cloud Data & Analytics Platform
-- Reference Tables
--
-- Contains:
--   business_unit
--   cost_center
--   service
--   skill
--
-- These are operational reference/master tables used by
-- employees, projects, resource planning, and other domains.
-- ============================================================


-- ============================================================
-- 1. Business Unit
-- ============================================================

CREATE TABLE operations.business_unit (
    business_unit_id BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    business_unit_code VARCHAR(30) NOT NULL,
    business_unit_name VARCHAR(100) NOT NULL,

    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_business_unit_code
        UNIQUE (business_unit_code),

    CONSTRAINT chk_business_unit_code_not_blank
        CHECK (
            BTRIM(business_unit_code) <> ''
        ),

    CONSTRAINT chk_business_unit_name_not_blank
        CHECK (
            BTRIM(business_unit_name) <> ''
        )
);


-- ============================================================
-- 2. Cost Center
-- ============================================================

CREATE TABLE operations.cost_center (
    cost_center_id BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    business_unit_id BIGINT NOT NULL,

    cost_center_code VARCHAR(30) NOT NULL,
    cost_center_name VARCHAR(100) NOT NULL,

    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cost_center_code
        UNIQUE (cost_center_code),

    CONSTRAINT fk_cost_center_business_unit
        FOREIGN KEY (
            business_unit_id
        )
        REFERENCES operations.business_unit (
            business_unit_id
        ),

    CONSTRAINT chk_cost_center_code_not_blank
        CHECK (
            BTRIM(cost_center_code) <> ''
        ),

    CONSTRAINT chk_cost_center_name_not_blank
        CHECK (
            BTRIM(cost_center_name) <> ''
        )
);


-- ============================================================
-- 3. Service
-- ============================================================

CREATE TABLE operations.service (
    service_id BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    service_code VARCHAR(30) NOT NULL,
    service_name VARCHAR(100) NOT NULL,

    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_service_code
        UNIQUE (service_code),

    CONSTRAINT chk_service_code_not_blank
        CHECK (
            BTRIM(service_code) <> ''
        ),

    CONSTRAINT chk_service_name_not_blank
        CHECK (
            BTRIM(service_name) <> ''
        )
);


-- ============================================================
-- 4. Skill
-- ============================================================

CREATE TABLE operations.skill (
    skill_id BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    skill_code VARCHAR(30) NOT NULL,
    skill_name VARCHAR(100) NOT NULL,

    skill_category VARCHAR(50),

    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_skill_code
        UNIQUE (skill_code),

    CONSTRAINT chk_skill_code_not_blank
        CHECK (
            BTRIM(skill_code) <> ''
        ),

    CONSTRAINT chk_skill_name_not_blank
        CHECK (
            BTRIM(skill_name) <> ''
        )
);


-- ============================================================
-- 5. Seed Business Units
-- ============================================================

INSERT INTO operations.business_unit (
    business_unit_code,
    business_unit_name
)
VALUES
    (
        'DATA',
        'Data & Analytics'
    ),
    (
        'CLOUD',
        'Cloud Engineering'
    ),
    (
        'SOFTWARE',
        'Software Engineering'
    ),
    (
        'CONSULTING',
        'Business Consulting'
    ),
    (
        'MANAGED',
        'Managed Services'
    );


-- ============================================================
-- 6. Seed Cost Centers
-- ============================================================

INSERT INTO operations.cost_center (
    business_unit_id,
    cost_center_code,
    cost_center_name
)
VALUES

    (
        (
            SELECT business_unit_id
            FROM operations.business_unit
            WHERE business_unit_code = 'DATA'
        ),
        'DATA-ENG',
        'Data Engineering'
    ),

    (
        (
            SELECT business_unit_id
            FROM operations.business_unit
            WHERE business_unit_code = 'DATA'
        ),
        'DATA-BI',
        'Business Intelligence'
    ),

    (
        (
            SELECT business_unit_id
            FROM operations.business_unit
            WHERE business_unit_code = 'CLOUD'
        ),
        'CLOUD-ENG',
        'Cloud Engineering'
    ),

    (
        (
            SELECT business_unit_id
            FROM operations.business_unit
            WHERE business_unit_code = 'SOFTWARE'
        ),
        'SW-ENG',
        'Application Engineering'
    ),

    (
        (
            SELECT business_unit_id
            FROM operations.business_unit
            WHERE business_unit_code = 'CONSULTING'
        ),
        'CONSULT',
        'Business Consulting'
    ),

    (
        (
            SELECT business_unit_id
            FROM operations.business_unit
            WHERE business_unit_code = 'MANAGED'
        ),
        'MANAGED',
        'Managed Services'
    );


-- ============================================================
-- 7. Seed Services
-- ============================================================

INSERT INTO operations.service (
    service_code,
    service_name
)
VALUES

    (
        'DATA',
        'Data & Analytics'
    ),

    (
        'CLOUD',
        'Cloud Consulting'
    ),

    (
        'SOFTWARE',
        'Software Engineering'
    ),

    (
        'TRANSFORM',
        'Business Transformation'
    ),

    (
        'MANAGED',
        'Managed Services'
    );


-- ============================================================
-- 8. Seed Skills
-- ============================================================

INSERT INTO operations.skill (
    skill_code,
    skill_name,
    skill_category
)
VALUES

    (
        'SQL',
        'SQL',
        'Data'
    ),

    (
        'PYTHON',
        'Python',
        'Data'
    ),

    (
        'POWERBI',
        'Power BI',
        'Analytics'
    ),

    (
        'AZURE',
        'Microsoft Azure',
        'Cloud'
    ),

    (
        'SNOWFLAKE',
        'Snowflake',
        'Data'
    ),

    (
        'DBT',
        'dbt',
        'Data'
    ),

    (
        'DOTNET',
        '.NET',
        'Software'
    ),

    (
        'REACT',
        'React',
        'Software'
    ),

    (
        'POSTGRESQL',
        'PostgreSQL',
        'Data'
    ),

    (
        'AIRFLOW',
        'Apache Airflow',
        'Data'
    ),

    (
        'DEVOPS',
        'DevOps',
        'Engineering'
    ),

    (
        'BUSINESS_ANALYSIS',
        'Business Analysis',
        'Consulting'
    );