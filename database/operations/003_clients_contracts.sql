CREATE TABLE operations.client (
    client_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    client_number VARCHAR(30) NOT NULL,
    client_name VARCHAR(150) NOT NULL,

    country_code VARCHAR(3),
    industry VARCHAR(100),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_client_number UNIQUE (client_number),

    CONSTRAINT chk_client_number_not_blank
        CHECK (BTRIM(client_number) <> ''),

    CONSTRAINT chk_client_name_not_blank
        CHECK (BTRIM(client_name) <> '')
);


CREATE TABLE operations.contract (
    contract_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    client_id BIGINT NOT NULL,

    contract_number VARCHAR(30) NOT NULL,
    contract_name VARCHAR(150) NOT NULL,

    contract_type VARCHAR(50),

    start_date DATE NOT NULL,
    end_date DATE,

    contract_value NUMERIC(18,2),
    currency_code VARCHAR(3) NOT NULL DEFAULT 'USD',

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_contract_number UNIQUE (contract_number),

    CONSTRAINT fk_contract_client
        FOREIGN KEY (client_id)
        REFERENCES operations.client (client_id),

    CONSTRAINT chk_contract_number_not_blank
        CHECK (BTRIM(contract_number) <> ''),

    CONSTRAINT chk_contract_name_not_blank
        CHECK (BTRIM(contract_name) <> ''),

    CONSTRAINT chk_contract_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        ),

    CONSTRAINT chk_contract_value
        CHECK (
            contract_value IS NULL
            OR contract_value >= 0
        )
);