# DeepShield

> **DeepShield: A Machine Learning-Based Framework for Phishing Website and Suspicious Email Detection**  
> An intelligent, full-stack cybersecurity platform combining lexical feature extraction, natural language processing, explainable predictions, and an operational security dashboard.

[![Tests](https://img.shields.io/badge/tests-20%2F20%20passed-brightgreen.svg)]()
[![Python](https://img.shields.io/badge/python-3.14-blue.svg)]()
[![React](https://img.shields.io/badge/react-19-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

## 1. Overview & Key Capabilities

- **Zero-Network URL Phishing Detection:** Deconstructs arbitrary URL strings into 29 lexical, structural, and statistical (Shannon entropy) features using a trained Random Forest classifier (v2.0.0). Never connects to the target URL, protecting the host against Server-Side Request Forgery (SSRF) and evasion tracking.
- **NLP Email Phishing Scanner:** Combines TF-IDF n-grams (up to 5,000 features) with Multinomial Naive Bayes classification and rule-based heuristic indicator detectors to identify social engineering lures, artificial urgency, and financial coercion.
- **Explainable AI (XAI) Scorecards:** Every prediction generates a transparent attribution breakdown explaining which structural anomalies or linguistic triggers drove the risk classification.
- **Four-Tier Calibrated Risk Scoring:** Translates raw probabilistic model outputs into operational risk severity levels: **Low**, **Medium**, **High**, or **Critical**.
- **Live Database Telemetry:** Operational dashboard with real-time scan volume trends, classification distributions, and threat severity analytics backed by SQLite.
- **Searchable Scan History & CSV Export:** Search, filter by risk or classification, paginate, and stream-export audit logs.
- **Hardened Security Architecture:** In-memory sliding-window rate limiting, RFC 1918 private IP rejection, strict Content Security Policy (CSP), and request payload bounds.

---

## 2. Technology Stack

| Layer | Technologies |
|---|---|
| **Frontend** | React 19, Vite 8, Recharts, Lucide Icons, React Router v7 |
| **Backend API** | Python 3.14, Flask 3.1, Flask-SQLAlchemy 3.1, Flask-CORS |
| **Machine Learning** | scikit-learn 1.9, NumPy 2.5, pandas 3.0, joblib 1.6 |
| **Persistence** | SQLite 3, SQLAlchemy 2.1 ORM |
| **Testing & Quality** | pytest 9.2, Playwright, oxlint |

---

## 3. Quickstart & Installation

### Step 1: Install Python Dependencies
```bash
python -m pip install -r requirements.txt
```

### Step 2: Install Node Dependencies
```bash
cd frontend
npm install
cd ..
```

### Step 3: Run Automated Tests
```bash
python -m pytest backend/tests/ -v
```
*(All 20 unit, integration, and ML validation tests will execute and pass)*

### Step 4: Seed Database (Optional / Out of the Box)
```bash
python scripts/seed_database.py
```
*(Populates initial baseline scan history, trend series, and model metadata)*

### Step 5: Launch Application
Run the one-click launcher:
```bash
.\start_deepshield.bat
# Or on PowerShell:
.\start_deepshield.ps1
```
Or start manually in two terminals:
- **Terminal 1 (Backend):** `python main.py` (Runs on http://localhost:5000)
- **Terminal 2 (Frontend):** `cd frontend && npm.cmd run dev` (Runs on http://localhost:5173)

---

## 4. API Endpoints Reference

| Method | Route | Description |
|---|---|---|
| `GET` | `/api/health` | Comprehensive health check and model loading diagnostics |
| `GET` | `/api/dashboard/stats` | Live aggregate scan metrics, trends, and recent records |
| `POST` | `/api/scan/url` | Lexical feature extraction and URL phishing classification |
| `POST` | `/api/scan/email` | NLP TF-IDF vectorization and email threat detection |
| `GET` | `/api/scans` | Paginated scan history with type, risk, and query filters |
| `GET` | `/api/scans/<id>` | Full scan detail payload including feature dictionary |
| `DELETE` | `/api/scans/<id>` | Delete individual scan audit record |
| `DELETE` | `/api/scans?confirm=true` | Bulk wipe all scan audit records |
| `GET` | `/api/analytics` | Period-based temporal scan trends (7d, 30d, 90d) |
| `GET` | `/api/models/status` | Runtime status of loaded ML and NLP model pipelines |
| `GET` | `/api/models/metrics` | Evaluation telemetry and benchmark metrics |
| `GET` | `/api/export/scans` | Stream scan history records as a downloadable CSV |

---

## 5. Academic Documentation & Reports

- **Academic Project Report (DOCX):** [`documentation/DeepShield_Project_Report.docx`](file:///documentation/DeepShield_Project_Report.docx)
- **Academic Project Report (Markdown):** [`documentation/DeepShield_Project_Report.md`](file:///documentation/DeepShield_Project_Report.md)
- **IEEE-Style Research Paper:** [`research/DeepShield_IEEE_Research_Paper.md`](file:///research/DeepShield_IEEE_Research_Paper.md)
- **All 10 System Diagrams (Mermaid):** [`documentation/diagrams/ALL_DIAGRAMS.md`](file:///documentation/diagrams/ALL_DIAGRAMS.md)
- **Automated Test Report:** [`TEST_REPORT.md`](file:///TEST_REPORT.md)
- **Security Policy & Threat Model:** [`SECURITY.md`](file:///SECURITY.md)

---

## 6. Citation & Attribution

```bibtex
@misc{deepshield2026,
  author = {[STUDENT NAME]},
  title = {DeepShield: A Machine Learning-Based Framework for Phishing Website and Suspicious Email Detection},
  year = {2026},
  publisher = {[COLLEGE/UNIVERSITY]},
  howpublished = {Minor Project Deliverable}
}
```

