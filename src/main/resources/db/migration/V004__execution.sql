-- LL-0.3.0 execution: routings, serial registers, work orders, clocking.

CREATE TABLE IF NOT EXISTS serial_registers (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id        BIGINT       NOT NULL REFERENCES orgs(id),
    register_code VARCHAR(40)  NOT NULL,
    prefix        VARCHAR(20)  NOT NULL DEFAULT '',
    pad_length    INTEGER      NOT NULL DEFAULT 5,
    suffix        VARCHAR(20)  NOT NULL DEFAULT '',
    current_seq   INTEGER      NOT NULL DEFAULT 0,
    end_seq       INTEGER      NOT NULL DEFAULT 99999,
    active        BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_reg_org_code UNIQUE (org_id, register_code)
);
CREATE INDEX IF NOT EXISTS idx_reg_org ON serial_registers(org_id);

CREATE TABLE IF NOT EXISTS wo_sequence (
    org_id   BIGINT PRIMARY KEY REFERENCES orgs(id),
    next_seq INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS routings (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id          BIGINT       NOT NULL REFERENCES orgs(id),
    part_id         BIGINT       NOT NULL REFERENCES parts(id),
    routing_number  VARCHAR(80)  NOT NULL,
    revision        INTEGER      NOT NULL DEFAULT 1,
    revision_label  VARCHAR(20)  NOT NULL,
    status          VARCHAR(12)  NOT NULL DEFAULT 'DRAFT'
                    CHECK (status IN ('DRAFT','APPROVED','SUPERSEDED')),
    created_by      BIGINT       REFERENCES users(id),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    approved_at     TIMESTAMPTZ,
    CONSTRAINT uq_routing_part_rev UNIQUE (part_id, revision)
);
CREATE INDEX IF NOT EXISTS idx_routing_org  ON routings(org_id);
CREATE INDEX IF NOT EXISTS idx_routing_part ON routings(part_id);

CREATE TABLE IF NOT EXISTS routing_operations (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    routing_id  BIGINT       NOT NULL REFERENCES routings(id) ON DELETE CASCADE,
    op_number   VARCHAR(20)  NOT NULL,
    op_name     VARCHAR(200) NOT NULL,
    behaviour   VARCHAR(16)  NOT NULL DEFAULT 'CLOCKING'
                CHECK (behaviour IN ('CLOCKING','NON-CLOCKING')),
    resource_id BIGINT       REFERENCES resources(id),
    sort_order  INTEGER      NOT NULL DEFAULT 0,
    CONSTRAINT uq_routing_op UNIQUE (routing_id, op_number)
);
CREATE INDEX IF NOT EXISTS idx_rop_routing ON routing_operations(routing_id);

CREATE TABLE IF NOT EXISTS work_orders (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id       BIGINT       NOT NULL REFERENCES orgs(id),
    wo_number    VARCHAR(20)  NOT NULL,
    part_id      BIGINT       NOT NULL REFERENCES parts(id),
    routing_id   BIGINT       NOT NULL REFERENCES routings(id),
    control_type VARCHAR(10)  NOT NULL DEFAULT 'SERIAL'
                 CHECK (control_type IN ('SERIAL','LOT')),
    quantity     INTEGER      NOT NULL DEFAULT 1,
    status       VARCHAR(12)  NOT NULL DEFAULT 'OPEN'
                 CHECK (status IN ('OPEN','IN_PROGRESS','COMPLETE','ON_HOLD','CANCELLED')),
    hold_type    VARCHAR(8)   CHECK (hold_type IS NULL OR hold_type IN ('SOFT','HARD')),
    priority     INTEGER      NOT NULL DEFAULT 50,
    notes        TEXT,
    created_by   BIGINT       REFERENCES users(id),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ,
    CONSTRAINT uq_wo_number UNIQUE (wo_number)
);
CREATE INDEX IF NOT EXISTS idx_wo_org    ON work_orders(org_id);
CREATE INDEX IF NOT EXISTS idx_wo_status ON work_orders(status);

CREATE TABLE IF NOT EXISTS serial_numbers (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    org_id         BIGINT       NOT NULL REFERENCES orgs(id),
    wo_id          BIGINT       NOT NULL REFERENCES work_orders(id),
    serial_number  VARCHAR(80)  NOT NULL,
    register_id    BIGINT       REFERENCES serial_registers(id),
    current_op_id  BIGINT       REFERENCES routing_operations(id),
    status         VARCHAR(16)  NOT NULL DEFAULT 'NOT_STARTED'
                   CHECK (status IN ('NOT_STARTED','IN_PROGRESS','COMPLETE','SCRAPPED')),
    CONSTRAINT uq_sn_org UNIQUE (org_id, serial_number)
);
CREATE INDEX IF NOT EXISTS idx_sn_wo ON serial_numbers(wo_id);

CREATE TABLE IF NOT EXISTS wo_active_clocks (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wo_id         BIGINT      NOT NULL REFERENCES work_orders(id),
    serial_id     BIGINT      NOT NULL REFERENCES serial_numbers(id),
    op_id         BIGINT      NOT NULL REFERENCES routing_operations(id),
    user_id       BIGINT      NOT NULL REFERENCES users(id),
    clocked_on_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_clock_user_serial UNIQUE (user_id, serial_id)
);
CREATE INDEX IF NOT EXISTS idx_ac_wo ON wo_active_clocks(wo_id);

CREATE TABLE IF NOT EXISTS clock_events (
    id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wo_id     BIGINT      NOT NULL REFERENCES work_orders(id),
    serial_id BIGINT      NOT NULL REFERENCES serial_numbers(id),
    op_id     BIGINT      NOT NULL REFERENCES routing_operations(id),
    user_id   BIGINT      NOT NULL REFERENCES users(id),
    action    VARCHAR(12) NOT NULL CHECK (action IN ('CLOCK_ON','CLOCK_OFF','COMPLETE')),
    at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ce_wo ON clock_events(wo_id);
