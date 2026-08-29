-- ============================================================
-- Aurelia Enterprise Cloud Data & Analytics Platform
-- General Ledger Operational Tables
-- ============================================================


-- ============================================================
-- 1. GL Account
-- ============================================================

CREATE TABLE operations.gl_account (
    gl_account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    account_code VARCHAR(30) NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(30) NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_gl_account_code
        UNIQUE (account_code),

    CONSTRAINT chk_gl_account_code_not_blank
        CHECK (BTRIM(account_code) <> ''),

    CONSTRAINT chk_gl_account_name_not_blank
        CHECK (BTRIM(account_name) <> ''),

    CONSTRAINT chk_gl_account_type
        CHECK (
            account_type IN (
                'ASSET',
                'LIABILITY',
                'EQUITY',
                'REVENUE',
                'EXPENSE'
            )
        )
);


-- ============================================================
-- 2. GL Journal
-- ============================================================

CREATE TABLE operations.gl_journal (
    gl_journal_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    journal_number VARCHAR(30) NOT NULL,
    journal_date DATE NOT NULL,

    journal_description VARCHAR(255),

    journal_status VARCHAR(30)
        NOT NULL
        DEFAULT 'POSTED',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_gl_journal_number
        UNIQUE (journal_number),

    CONSTRAINT chk_gl_journal_number_not_blank
        CHECK (BTRIM(journal_number) <> ''),

    CONSTRAINT chk_gl_journal_status
        CHECK (
            journal_status IN (
                'DRAFT',
                'POSTED',
                'REVERSED'
            )
        )
);


-- ============================================================
-- 3. GL Entry
-- ============================================================

CREATE TABLE operations.gl_entry (
    gl_entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    gl_journal_id BIGINT NOT NULL,
    gl_account_id BIGINT NOT NULL,

    project_id BIGINT,
    cost_center_id BIGINT,

    line_number INTEGER NOT NULL,

    description VARCHAR(255),

    debit_amount NUMERIC(18,2)
        NOT NULL
        DEFAULT 0,

    credit_amount NUMERIC(18,2)
        NOT NULL
        DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_gl_entry_journal
        FOREIGN KEY (gl_journal_id)
        REFERENCES operations.gl_journal (
            gl_journal_id
        ),

    CONSTRAINT fk_gl_entry_account
        FOREIGN KEY (gl_account_id)
        REFERENCES operations.gl_account (
            gl_account_id
        ),

    CONSTRAINT fk_gl_entry_project
        FOREIGN KEY (project_id)
        REFERENCES operations.project (
            project_id
        ),

    CONSTRAINT fk_gl_entry_cost_center
        FOREIGN KEY (cost_center_id)
        REFERENCES operations.cost_center (
            cost_center_id
        ),

    CONSTRAINT uq_gl_entry_line
        UNIQUE (
            gl_journal_id,
            line_number
        ),

    CONSTRAINT chk_gl_entry_line_number
        CHECK (line_number > 0),

    CONSTRAINT chk_gl_entry_debit
        CHECK (debit_amount >= 0),

    CONSTRAINT chk_gl_entry_credit
        CHECK (credit_amount >= 0),

    CONSTRAINT chk_gl_entry_debit_or_credit
        CHECK (
            (
                debit_amount > 0
                AND credit_amount = 0
            )
            OR
            (
                credit_amount > 0
                AND debit_amount = 0
            )
        )
);


-- ============================================================
-- 4. Seed GL Accounts
-- ============================================================

INSERT INTO operations.gl_account (
    account_code,
    account_name,
    account_type
)
VALUES
    (
        '1000',
        'Cash',
        'ASSET'
    ),
    (
        '1100',
        'Accounts Receivable',
        'ASSET'
    ),
    (
        '2000',
        'Accounts Payable',
        'LIABILITY'
    ),
    (
        '3000',
        'Retained Earnings',
        'EQUITY'
    ),
    (
        '4000',
        'Consulting Revenue',
        'REVENUE'
    ),
    (
        '5000',
        'Labor Cost',
        'EXPENSE'
    ),
    (
        '5100',
        'Cloud Cost',
        'EXPENSE'
    ),
    (
        '5200',
        'Software Cost',
        'EXPENSE'
    ),
    (
        '5300',
        'Travel Cost',
        'EXPENSE'
    );