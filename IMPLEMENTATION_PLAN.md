# DeepShield — Implementation Plan

**Version:** 1.0  
**Created:** 2026-11-01  
**Status:** Active Development

---

## Phase Overview

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Repository audit and architecture | ✅ Complete |
| 2 | Database design and backend foundation | 🔄 In Progress |
| 3 | URL detection ML pipeline | 🔄 In Progress |
| 4 | Email detection NLP pipeline | 🔄 In Progress |
| 5 | Prediction and risk assessment services | 🔄 In Progress |
| 6 | Frontend design system and responsive layout | 🔄 In Progress |
| 7 | Functional dashboard and scanners | 🔄 In Progress |
| 8 | History, analytics, export, settings | 🔄 In Progress |
| 9 | Security implementation | 📋 Planned |
| 10 | Unit, integration, E2E testing | 📋 Planned |
| 11 | Performance testing and optimization | 📋 Planned |
| 12 | Architecture diagrams and documentation | 📋 Planned |
| 13 | Research paper and project report | 📋 Planned |
| 14 | Final audit and delivery | 📋 Planned |

---

## Phase 1: Repository Audit ✅

**Outcome:** Empty repository confirmed. Greenfield build.

**Decisions:**
- Backend: Flask 3.1.3 (pre-installed, well-suited for academic)
- Database: SQLite + SQLAlchemy 2.1.3
- ML: scikit-learn 1.9.1
- Frontend: React + Vite
- Datasets: Synthetic (documented), with real dataset download scripts

---

## Phase 2: Database Design and Backend Foundation

### Database Schema

```sql
-- scans: stores all scan results
CREATE TABLE scans (
    id TEXT PRIMARY KEY,           -- UUID
    scan_type TEXT NOT NULL,       -- 'url' or 'email'
    input_preview TEXT,            -- first 200 chars only
    classification TEXT NOT NULL,  -- 'legitimate', 'phishing', 'suspicious'
    risk_level TEXT NOT NULL,      -- 'low', 'medium', 'high', 'critical'
    confidence REAL,               -- 0.0 to 1.0
    explanation TEXT,              -- JSON array of strings
    features TEXT,                 -- JSON dict of extracted features
    model_version TEXT,
    processing_time_ms INTEGER,
    created_at TEXT NOT NULL       -- ISO UTC datetime
);

-- model_versions: tracks trained model metadata
CREATE TABLE model_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    model_type TEXT NOT NULL,      -- 'url' or 'email'
    version TEXT NOT NULL,
    algorithm TEXT NOT NULL,
    accuracy REAL,
    precision_score REAL,
    recall REAL,
    f1_score REAL,
    trained_at TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,   -- boolean
    metadata TEXT                  -- JSON
);

-- audit_events: security audit log
CREATE TABLE audit_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT NOT NULL,
    ip_address TEXT,
    details TEXT,                  -- JSON
    created_at TEXT NOT NULL
);
```

### Backend API Endpoints

| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | /api/health | Health check |
| GET | /api/dashboard/stats | Dashboard statistics |
| POST | /api/scan/url | Scan a URL |
| POST | /api/scan/email | Scan an email |
| GET | /api/scans | List scans with filters |
| GET | /api/scans/{id} | Get scan details |
| DELETE | /api/scans/{id} | Delete scan |
| DELETE | /api/scans?confirm=true | Delete all scans |
| GET | /api/analytics | Analytics data |
| GET | /api/models/status | Model status |
| GET | /api/models/metrics | Model metrics |
| GET | /api/export/scans | Export CSV |

---

## Phase 3: URL Detection ML Pipeline

### Feature Engineering (27 features)

| Category | Features |
|----------|---------|
| Length | url_length, domain_length, path_length, query_length |
| Characters | num_dots, num_hyphens, num_slashes, num_question_marks, num_equals, num_at_signs, num_ampersands, num_percent |
| Digits | num_digits_in_url, num_digits_in_domain, digit_ratio_in_url |
| Security | has_ip_address, has_port, has_https, is_shortened_url |
| Structure | num_subdomains, domain_has_hyphen, tld_length, num_underscores |
| Text | has_suspicious_words, num_suspicious_words, letter_ratio_in_url |
| Statistical | special_char_ratio, url_entropy, hostname_entropy |

### Model Comparison

| Model | Expected CV F1 | Strengths |
|-------|----------------|-----------|
| Logistic Regression | ~0.88 | Interpretable, fast |
| Decision Tree | ~0.86 | Interpretable, feature importance |
| Random Forest | ~0.93 | Best accuracy, stable |
| Linear SVC | ~0.90 | Good generalization |

**Selection:** Best CV F1 (expected: Random Forest)

---

## Phase 4: Email NLP Pipeline

### Preprocessing Pipeline
1. Combine subject + body
2. Lowercase
3. Strip HTML tags
4. Normalize whitespace
5. TF-IDF (max_features=5000, ngram_range=(1,2))

### Classifiers
1. Logistic Regression (C=1.0)
2. LinearSVC
3. MultinomialNB (with MinMaxScaler)

---

## Phase 5: Risk Scoring Methodology

| Classification | Confidence | Risk Level |
|----------------|------------|------------|
| legitimate | > 0.85 | low |
| legitimate | 0.65-0.85 | medium |
| legitimate | < 0.65 | medium |
| phishing | < 0.65 | medium |
| phishing | 0.65-0.85 | high |
| phishing | > 0.85 | critical |

**Note:** Risk level is a decision-support tool. The application always displays the disclaimer that predictions are probabilistic.

---

## Phase 6-8: Frontend Architecture

### Component Hierarchy
```
App
├── Landing (public)
└── AppLayout (protected sections)
    ├── Sidebar (navigation)
    ├── Header (status, mobile menu)
    └── Pages:
        ├── Dashboard
        ├── URLScanner
        ├── EmailScanner
        ├── History
        ├── Analytics
        ├── Resources
        ├── Settings
        └── About
```

### Responsive Breakpoints
- xs: 320px (mobile small)
- sm: 375px (mobile standard)
- md: 768px (tablet)
- lg: 1024px (laptop)
- xl: 1280px (desktop)
- 2xl: 1920px (large desktop)

---

## Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Backend | Flask | Pre-installed, simple, academic-appropriate |
| DB | SQLite | Zero-config local deployment |
| ORM | SQLAlchemy | Production-grade, type-safe |
| ML | scikit-learn | Industry standard, reproducible |
| Frontend | React + Vite | Fast HMR, modern ecosystem |
| Charts | recharts | React-native, responsive |
| Icons | lucide-react | Consistent, tree-shakeable |
| Routing | react-router-dom | Standard |
| HTTP | axios | Request/response interceptors |

---

## Known Constraints

1. **Synthetic Dataset:** Real-world datasets (UCI, PhiUSIIL) require download; synthetic data is documented as such.
2. **No External API:** VirusTotal/GSB integration is optional and off by default.
3. **pip.exe blocked:** Using `python -m pip` throughout.
4. **PowerShell script restriction:** Using `cmd /c` for npm commands.
5. **Local only:** No cloud deployment included in scope.

---

*This plan is updated as implementation progresses.*

