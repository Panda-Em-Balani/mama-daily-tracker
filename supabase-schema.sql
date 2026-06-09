-- ═══════════════════════════════════════════════════════════════
-- Care Companion — Supabase Schema v2
-- Run this once in the Supabase SQL Editor
-- New in v2: schedule_events table
-- ═══════════════════════════════════════════════════════════════

-- Activity Log (meals, medications, snacks, custom tasks)
CREATE TABLE IF NOT EXISTS activity_log (
  id            BIGSERIAL PRIMARY KEY,
  timestamp     TIMESTAMPTZ NOT NULL DEFAULT now(),
  activity_type TEXT NOT NULL,
  status        TEXT NOT NULL CHECK (status IN ('done', 'skip')),
  notes         TEXT
);

-- Symptom Log
CREATE TABLE IF NOT EXISTS symptom_log (
  id        BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  symptom   TEXT NOT NULL,
  severity  SMALLINT NOT NULL CHECK (severity BETWEEN 1 AND 5),
  notes     TEXT
);

-- Water Log
-- amount_ml can be negative (deduction entries)
CREATE TABLE IF NOT EXISTS water_log (
  id        BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  amount_ml INTEGER NOT NULL
);

-- Daily Reflection
CREATE TABLE IF NOT EXISTS daily_reflection (
  id        BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  mood      TEXT NOT NULL CHECK (mood IN ('Good', 'Okay', 'Difficult')),
  notes     TEXT
);

-- Notes
CREATE TABLE IF NOT EXISTS notes (
  id        BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  text      TEXT NOT NULL
);

-- Schedule Events (chemo sessions, checkups, appointments)
CREATE TABLE IF NOT EXISTS schedule_events (
  id           BIGSERIAL PRIMARY KEY,
  timestamp    TIMESTAMPTZ NOT NULL DEFAULT now(),
  event_date   DATE NOT NULL,
  event_time   TIME,
  event_type   TEXT NOT NULL CHECK (event_type IN ('chemo', 'checkup', 'other')),
  title        TEXT NOT NULL,
  notes        TEXT
);

-- Treatment Log (legacy / future use)
CREATE TABLE IF NOT EXISTS treatment_log (
  id             BIGSERIAL PRIMARY KEY,
  treatment_date DATE NOT NULL,
  treatment_type TEXT NOT NULL,
  notes          TEXT
);

-- ─── Row Level Security ───────────────────────────────────────
ALTER TABLE activity_log      ENABLE ROW LEVEL SECURITY;
ALTER TABLE symptom_log       ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_log         ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_reflection  ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes             ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_events   ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_log     ENABLE ROW LEVEL SECURITY;

-- Allow anon key full access (family-internal app, protected by Allowed Origins)
CREATE POLICY "anon_all" ON activity_log     FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON symptom_log      FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON water_log        FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON daily_reflection FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON notes            FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON schedule_events  FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON treatment_log    FOR ALL TO anon USING (true) WITH CHECK (true);

-- ─── Indexes ──────────────────────────────────────────────────
CREATE INDEX idx_activity_ts   ON activity_log    (timestamp DESC);
CREATE INDEX idx_symptom_ts    ON symptom_log     (timestamp DESC);
CREATE INDEX idx_water_ts      ON water_log       (timestamp DESC);
CREATE INDEX idx_reflect_ts    ON daily_reflection(timestamp DESC);
CREATE INDEX idx_notes_ts      ON notes           (timestamp DESC);
CREATE INDEX idx_schedule_date ON schedule_events (event_date ASC);
CREATE INDEX idx_schedule_ts   ON schedule_events (timestamp DESC);
