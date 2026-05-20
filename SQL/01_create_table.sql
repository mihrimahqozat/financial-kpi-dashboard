DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    invoice_no      TEXT,
    stock_code      TEXT,
    description     TEXT,
    quantity        INTEGER,
    invoice_date    TEXT,
    unit_price      NUMERIC(10, 2),
    customer_id     TEXT,
    country         TEXT
);