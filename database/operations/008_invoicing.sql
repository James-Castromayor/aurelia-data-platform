CREATE TABLE operations.invoice (
    invoice_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    client_id BIGINT NOT NULL,
    project_id BIGINT,

    invoice_number VARCHAR(30) NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE,

    currency_code VARCHAR(3) NOT NULL DEFAULT 'USD',
    invoice_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',

    total_amount NUMERIC(18,2) NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_invoice_number UNIQUE (invoice_number),

    CONSTRAINT fk_invoice_client
        FOREIGN KEY (client_id)
        REFERENCES operations.client (client_id),

    CONSTRAINT fk_invoice_project
        FOREIGN KEY (project_id)
        REFERENCES operations.project (project_id),

    CONSTRAINT chk_invoice_total_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_invoice_dates
        CHECK (
            due_date IS NULL
            OR due_date >= invoice_date
        )
);


CREATE TABLE operations.invoice_line (
    invoice_line_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    invoice_id BIGINT NOT NULL,

    line_number INTEGER NOT NULL,
    description VARCHAR(255) NOT NULL,

    quantity NUMERIC(12,2) NOT NULL DEFAULT 1,
    unit_price NUMERIC(18,2) NOT NULL,
    line_amount NUMERIC(18,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_invoice_line_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES operations.invoice (invoice_id),

    CONSTRAINT uq_invoice_line
        UNIQUE (invoice_id, line_number),

    CONSTRAINT chk_invoice_line_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_invoice_line_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_invoice_line_amount
        CHECK (line_amount >= 0)
);