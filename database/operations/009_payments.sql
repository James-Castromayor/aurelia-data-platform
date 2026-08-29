CREATE TABLE operations.payment (
    payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    client_id BIGINT NOT NULL,

    payment_reference VARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,

    payment_amount NUMERIC(18,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'USD',

    payment_method VARCHAR(30),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_payment_reference UNIQUE (payment_reference),

    CONSTRAINT fk_payment_client
        FOREIGN KEY (client_id)
        REFERENCES operations.client (client_id),

    CONSTRAINT chk_payment_amount
        CHECK (payment_amount > 0)
);


CREATE TABLE operations.payment_allocation (
    payment_id BIGINT NOT NULL,
    invoice_id BIGINT NOT NULL,

    allocated_amount NUMERIC(18,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_payment_allocation
        PRIMARY KEY (payment_id, invoice_id),

    CONSTRAINT fk_payment_allocation_payment
        FOREIGN KEY (payment_id)
        REFERENCES operations.payment (payment_id),

    CONSTRAINT fk_payment_allocation_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES operations.invoice (invoice_id),

    CONSTRAINT chk_payment_allocation_amount
        CHECK (allocated_amount > 0)
);