-- =====================================================
-- PATIENTS
-- =====================================================

DROP TABLE IF EXISTS patients CASCADE;

CREATE TABLE patients (
    patient_id         INTEGER PRIMARY KEY,
    gender             VARCHAR(10),
    birth_date         DATE,
    region             VARCHAR(50),
    rare_disease_flag  BOOLEAN,
    created_at         TIMESTAMP
);

COPY patients
FROM 'C:\Data\patients.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- PROVIDERS
-- =====================================================

DROP TABLE IF EXISTS providers CASCADE;

CREATE TABLE providers (
    provider_id    INTEGER PRIMARY KEY,
    provider_name  VARCHAR(100),
    specialty      VARCHAR(50),
    hospital       VARCHAR(100),
    region         VARCHAR(50)
);

COPY providers
FROM 'C:\Data\providers.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- CLAIMS
-- =====================================================

DROP TABLE IF EXISTS claims CASCADE;

CREATE TABLE claims (
    claim_id        INTEGER PRIMARY KEY,
    patient_id      INTEGER,
    claim_type      VARCHAR(20),
    service_date    DATE,
    cost            NUMERIC,
    duplicate_flag  BOOLEAN,

    CONSTRAINT fk_claim_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

COPY claims
FROM 'C:\Data\claims.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- VISITS
-- =====================================================

DROP TABLE IF EXISTS visits CASCADE;

CREATE TABLE visits (
    visit_id      INTEGER PRIMARY KEY,
    patient_id    INTEGER,
    provider_id   INTEGER,
    visit_type    VARCHAR(20),
    visit_date    DATE,

    CONSTRAINT fk_visit_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_visit_provider
        FOREIGN KEY (provider_id)
        REFERENCES providers(provider_id)
);

COPY visits
FROM 'C:\Data\visits.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- TREATMENTS
-- =====================================================

DROP TABLE IF EXISTS treatments CASCADE;

CREATE TABLE treatments (
    treatment_id           INTEGER PRIMARY KEY,
    patient_id             INTEGER,
    provider_id            INTEGER,
    drug_name              VARCHAR(50),
    line_of_therapy        INTEGER,
    start_date             DATE,
    end_date               DATE,
    discontinuation_reason VARCHAR(50),

    CONSTRAINT fk_treatment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_treatment_provider
        FOREIGN KEY (provider_id)
        REFERENCES providers(provider_id)
);

COPY treatments
FROM 'C:\Data\treatments.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- DIAGNOSES
-- =====================================================

DROP TABLE IF EXISTS diagnoses CASCADE;

CREATE TABLE diagnoses (
    diagnosis_id    INTEGER PRIMARY KEY,
    patient_id      INTEGER,
    diagnosis_code  VARCHAR(10),
    diagnosis_date  DATE,
    disease_stage   VARCHAR(10),

    CONSTRAINT fk_diagnosis_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

COPY diagnoses
FROM 'C:\Data\diagnoses.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- ADHERENCE
-- =====================================================

DROP TABLE IF EXISTS adherence CASCADE;

CREATE TABLE adherence (
    adherence_id          INTEGER PRIMARY KEY,
    patient_id            INTEGER,
    drug_name             VARCHAR(50),
    days_supply           INTEGER,
    days_taken            INTEGER,
    refill_gap            INTEGER,
    discontinuation_flag  BOOLEAN,

    CONSTRAINT fk_adherence_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

COPY adherence
FROM 'C:\Data\adherence.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- OUTCOMES
-- =====================================================

DROP TABLE IF EXISTS outcomes CASCADE;

CREATE TABLE outcomes (
    patient_id         INTEGER PRIMARY KEY,
    progression_date   DATE,
    death_date         DATE,
    last_followup_date DATE,

    CONSTRAINT fk_outcome_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

COPY outcomes
FROM 'C:\Data\outcomes.csv'
DELIMITER ','
CSV HEADER;



-- =====================================================
-- NOTES
-- =====================================================

DROP TABLE IF EXISTS notes CASCADE;

CREATE TABLE notes (
    note_id     INTEGER PRIMARY KEY,
    patient_id  INTEGER,
    note_text   TEXT,
    note_date   DATE,

    CONSTRAINT fk_note_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);

COPY notes
FROM 'C:\Data\notes.csv'
DELIMITER ','
CSV HEADER;