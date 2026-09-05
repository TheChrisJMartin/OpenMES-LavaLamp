-- Migration ledger. The Java migrator also creates this table before applying
-- scripts so a brand-new database can record V001 itself.
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS schema_version (
    version     VARCHAR(40)  PRIMARY KEY,
    patch_file  VARCHAR(200) NOT NULL,
    notes       TEXT,
    applied_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
