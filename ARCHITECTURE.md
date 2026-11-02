# DeepShield — System Architecture

**Version:** 1.0  
**Date:** 2026-11-01

---

## 1. System Architecture Overview

```mermaid
graph TB
    User([User / Browser]) -->|HTTP| FE[React Frontend<br/>Port 5173]
    FE -->|REST API calls| BE[Flask Backend<br/>Port 5000]
    BE --> DB[(SQLite Database<br/>deepshield.db)]
    BE --> URL_ML[URL Phishing<br/>Detector<br/>Random Forest]
    BE --> EMAIL_ML[Email Phishing<br/>Detector<br/>TF-IDF + Classifier]
    BE --> RISK[Risk Scoring<br/>Service]
    URL_ML --> MODELS[(Trained Models<br/>.joblib files)]
    EMAIL_ML --> MODELS
    BE -->|Optional| TI[Threat Intelligence<br/>APIs - VirusTotal / GSB]
    
    style User fill:#1e293b,stroke:#3b82f6,color:#f1f5f9
    style FE fill:#1e293b,stroke:#0ea5e9,color:#f1f5f9
    style BE fill:#1e293b,stroke:#3b82f6,color:#f1f5f9
    style DB fill:#1e293b,stroke:#10b981,color:#f1f5f9
    style URL_ML fill:#1e293b,stroke:#8b5cf6,color:#f1f5f9
    style EMAIL_ML fill:#1e293b,stroke:#8b5cf6,color:#f1f5f9
    style RISK fill:#1e293b,stroke:#f59e0b,color:#f1f5f9
    style MODELS fill:#1e293b,stroke:#10b981,color:#f1f5f9
    style TI fill:#1e293b,stroke:#64748b,color:#94a3b8
```

---

## 2. Directory Structure

```
Deep_sheild_final/
├── frontend/                    # React + Vite application
│   ├── public/
│   ├── src/
│   │   ├── api/                 # Axios client + API functions
│   │   ├── components/          # Reusable UI components
│   │   │   ├── Layout/          # AppLayout, Sidebar, Header
│   │   │   ├── UI/              # Badge, Card, Button, Input...
│   │   │   └── Charts/          # recharts wrappers
│   │   ├── pages/               # Route-level page components
│   │   ├── hooks/               # Custom React hooks
│   │   └── utils/               # Formatters, validators
│   ├── package.json
│   └── vite.config.js
│
├── backend/                     # Flask Python backend
│   ├── app/
│   │   ├── __init__.py          # App factory
│   │   ├── database.py          # SQLAlchemy setup
│   │   ├── models.py            # ORM models
│   │   ├── api/                 # Blueprint endpoints
│   │   │   ├── scan.py          # /api/scan/*
│   │   │   ├── dashboard.py     # /api/dashboard/*
│   │   │   ├── analytics.py     # /api/analytics
│   │   │   ├── models_api.py    # /api/models/*
│   │   │   └── health.py        # /api/health
│   │   ├── ml/                  # Machine learning layer
│   │   │   ├── url_features.py  # URL feature extraction
│   │   │   ├── email_features.py # Email NLP features
│   │   │   ├── predictor.py     # Model inference
│   │   │   ├── risk_scorer.py   # Risk assessment
│   │   │   └── models/          # Saved .joblib models
│   │   └── security/
│   │       └── middleware.py    # Rate limiting, headers
│   ├── tests/                   # Backend test suite
│   └── main.py                  # Entry point
│
├── datasets/                    # Training datasets
│   ├── url/                     # URL phishing dataset
│   └── email/                   # Email phishing dataset
│
├── scripts/                     # Training and utility scripts
│   ├── generate_url_dataset.py
│   ├── generate_email_dataset.py
│   ├── train_url_model.py
│   ├── train_email_model.py
│   └── run_training.py
│
├── research/
│   ├── notebooks/               # Analysis documentation
│   └── results/                 # Evaluation outputs
│
├── documentation/
│   ├── diagrams/                # Architecture diagrams
│   └── project_report/          # Academic report
│
├── PROJECT_AUDIT.md
├── IMPLEMENTATION_PLAN.md
├── ARCHITECTURE.md
├── SECURITY.md
├── README.md
├── INSTALLATION_GUIDE.md
└── .gitignore
```

---

## 3. Request/Response Flow

### URL Scan Flow

```mermaid
sequenceDiagram
    participant U as User
    participant FE as React Frontend
    participant API as Flask API
    participant VAL as Input Validator
    participant FEX as Feature Extractor
    participant ML as URL Model
    participant RS as Risk Scorer
    participant DB as SQLite DB

    U->>FE: Enter URL + Click Analyze
    FE->>FE: Client-side URL validation
    FE->>API: POST /api/scan/url {url}
    API->>VAL: Validate URL (scheme, length, SSRF check)
    VAL-->>API: Validated URL
    API->>FEX: Extract 27 features from URL string
    FEX-->>API: Feature vector
    API->>ML: predict_proba(features)
    ML-->>API: [P(legitimate), P(phishing)]
    API->>RS: calculate_risk(classification, confidence)
    RS-->>API: risk_level, explanation
    API->>DB: INSERT scan record
    DB-->>API: Scan ID
    API-->>FE: JSON response (classification, risk, confidence, explanation, scan_id)
    FE->>FE: Render result card
    FE-->>U: Display result with disclaimer
```

### Email Scan Flow

```mermaid
sequenceDiagram
    participant U as User
    participant FE as React Frontend
    participant API as Flask API
    participant PRE as Email Preprocessor
    participant TFIDF as TF-IDF Pipeline
    participant ML as Email Model
    participant RS as Risk Scorer
    participant DB as SQLite DB

    U->>FE: Enter subject + body
    FE->>FE: Validate non-empty, length check
    FE->>API: POST /api/scan/email {subject, body}
    API->>PRE: Strip HTML, normalize text
    PRE->>PRE: Extract rule-based indicators
    PRE-->>API: Cleaned text + indicators
    API->>TFIDF: Transform text to TF-IDF vector
    TFIDF-->>API: Feature vector
    API->>ML: predict_proba(tfidf_vector)
    ML-->>API: [P(legitimate), P(phishing)]
    API->>RS: calculate_risk + generate_explanation
    RS-->>API: risk_level, explanation, top features
    API->>DB: INSERT scan (preview only, not full email)
    DB-->>API: Scan ID
    API-->>FE: JSON response
    FE-->>U: Display result
```

---

## 4. Database Entity Relationship

```mermaid
erDiagram
    SCANS {
        text id PK "UUID"
        text scan_type "url or email"
        text input_preview "first 200 chars"
        text classification "legitimate/phishing/suspicious"
        text risk_level "low/medium/high/critical"
        real confidence "0.0 to 1.0"
        text explanation "JSON array"
        text features "JSON dict"
        text model_version
        integer processing_time_ms
        text created_at "ISO UTC"
    }
    MODEL_VERSIONS {
        integer id PK
        text model_type "url or email"
        text version
        text algorithm
        real accuracy
        real precision_score
        real recall
        real f1_score
        text trained_at
        integer is_active
        text metadata "JSON"
    }
    AUDIT_EVENTS {
        integer id PK
        text event_type
        text ip_address
        text details "JSON"
        text created_at
    }
```

---

## 5. Machine Learning Architecture

### URL Detection Pipeline

```
Raw URL String
     ↓
URL Parser (urllib.parse)
     ↓
Feature Extractor (27 features)
     ↓
StandardScaler
     ↓
Classifier (Random Forest / best CV model)
     ↓
predict_proba() → [P(legit), P(phish)]
     ↓
Risk Scorer → risk_level
     ↓
Feature Importance → Explanation
```

### Email Detection Pipeline

```
Subject + Body Text
     ↓
HTML Stripper (re.sub)
     ↓
Text Normalizer (lowercase, whitespace)
     ↓
Rule Engine → suspicious indicators dict
     ↓
TF-IDF Vectorizer (max_features=5000, ngram=(1,2))
     ↓
Classifier (Logistic Regression / best CV model)
     ↓
predict_proba() → [P(legit), P(phish)]
     ↓
Risk Scorer + Top Features → Explanation
```

---

## 6. Security Architecture

```mermaid
graph LR
    Input([User Input]) --> RateL[Rate Limiter<br/>30 req/min per IP]
    RateL --> SizeL[Request Size Limit<br/>URL: 2KB / Email: 50KB]
    SizeL --> Val[Input Validator<br/>Schema validation]
    Val --> Sanitize[Input Sanitizer<br/>Strip null bytes, encode]
    Sanitize --> Logic[Business Logic]
    Logic --> OutEnc[Output Encoder<br/>JSON serialization]
    OutEnc --> SecH[Security Headers<br/>CSP, XCTO, XFO]
    SecH --> Client([Client Response])
```

**Security measures implemented:**
- Rate limiting (in-memory sliding window, 30 req/min per IP)
- Input validation (Werkzeug + custom validators)
- Output encoding (JSON only, no raw HTML output)
- CORS restricted to known origins
- No automatic URL fetching (SSRF prevention)
- No email attachment execution
- Parameterized DB queries via SQLAlchemy ORM
- Security headers on all responses
- Audit logging for all scan events
- Environment variables for all secrets

---

## 7. Component Interaction Matrix

| Component | Talks To | Protocol |
|-----------|----------|----------|
| React Frontend | Flask Backend | HTTP REST + JSON |
| Flask Backend | SQLite | SQLAlchemy ORM |
| Flask Backend | URL Model | joblib in-process call |
| Flask Backend | Email Model | joblib in-process call |
| URL Model | Feature Extractor | Python function call |
| Email Model | TF-IDF Pipeline | sklearn pipeline |
| Risk Scorer | Predictor | Python function call |
| Audit Logger | SQLite | SQLAlchemy ORM |

---

## 8. Deployment Topology

```
[User Browser]
      |
      | HTTP on port 5173
      |
[Vite Dev Server / Built Static Files]
      |
      | HTTP proxy /api/* to port 5000
      |
[Flask Development Server]
      |
      |--- SQLite file (backend/deepshield.db)
      |--- ML models (backend/app/ml/models/*.joblib)
      |--- Logs (backend/logs/deepshield.log)
```

---

*Architecture reflects actual implementation. Updated as system evolves.*

