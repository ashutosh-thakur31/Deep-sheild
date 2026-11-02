# DeepShield — Automated Test Execution Report

**Date of Execution:** 2026-11-01  
**Environment:** Windows 11, Python 3.14.7, pytest-9.2.0, Node.js v24.21.0, npm 11.19.0  
**Test Suite:** `backend/tests/`  
**Overall Status:** **14 / 14 PASSED (100% Pass Rate)**

---

## 1. Summary of Execution

| Category | Total | Passed | Failed | Skipped | Pass Rate |
|---|---|---|---|---|---|
| API & Health Tests | 2 | 2 | 0 | 0 | 100% |
| URL Scanner & Validation | 3 | 3 | 0 | 0 | 100% |
| Email NLP Scanner & Validation | 3 | 3 | 0 | 0 | 100% |
| History, Pagination & Filtering | 2 | 2 | 0 | 0 | 100% |
| Dashboard & Analytics | 2 | 2 | 0 | 0 | 100% |
| Model Telemetry & CSV Export | 2 | 2 | 0 | 0 | 100% |
| **Total** | **14** | **14** | **0** | **0** | **100%** |

---

## 2. Detailed Test Log

| # | Test Name | Target Module | Expected Outcome | Actual Outcome | Status |
|---|---|---|---|---|---|
| 1 | `test_health_endpoint` | `api/health.py` | HTTP 200, status="healthy", database="ok", models="loaded" | HTTP 200, all components healthy | ✅ PASS |
| 2 | `test_url_scan_legitimate` | `api/scan.py` | HTTP 200, classification="legitimate", risk="low" | HTTP 200, classification="legitimate", risk="low" | ✅ PASS |
| 3 | `test_url_scan_phishing` | `api/scan.py` | HTTP 400 or HTTP 200 with SSRF block or phishing flag | HTTP 400 (Private IP blocked by SSRF filter) | ✅ PASS |
| 4 | `test_url_scan_invalid_inputs` | `api/scan.py` | HTTP 400/422 on empty, non-HTTP, or malformed inputs | HTTP 400/422 properly returned | ✅ PASS |
| 5 | `test_email_scan_legitimate` | `api/scan.py` | HTTP 200, classification="legitimate", indicators extracted | HTTP 200, legitimate classification | ✅ PASS |
| 6 | `test_email_scan_phishing` | `api/scan.py` | HTTP 200, classification="phishing", risk="high"/"critical" | HTTP 200, phishing flagged, confidence 1.0 | ✅ PASS |
| 7 | `test_email_scan_validation` | `api/scan.py` | HTTP 400/422 on empty subject and body | HTTP 400 with validation message | ✅ PASS |
| 8 | `test_scan_history_and_pagination` | `api/scan.py` | HTTP 200, list of scans with pagination metadata | HTTP 200, scans list + pagination dict | ✅ PASS |
| 9 | `test_scan_filtering` | `api/scan.py` | HTTP 200, filtered results by scan_type="url" | HTTP 200, only URL scans returned | ✅ PASS |
| 10 | `test_dashboard_stats` | `api/dashboard.py`| HTTP 200, stats aggregated from SQLite database | HTTP 200, live database metrics returned | ✅ PASS |
| 11 | `test_analytics_endpoint` | `api/analytics.py` | HTTP 200, daily activity and classification breakdown | HTTP 200, summary + period distribution returned | ✅ PASS |
| 12 | `test_models_status_and_metrics` | `api/models_info.py` | HTTP 200, all_models_loaded=True, metrics populated | HTTP 200, telemetry from joblib/metadata | ✅ PASS |
| 13 | `test_export_scans_csv` | `api/scan.py` | HTTP 200, text/csv content-type, valid CSV headers | HTTP 200, attachment CSV payload | ✅ PASS |
| 14 | `test_security_headers` | `security/middleware.py` | X-Content-Type-Options: nosniff, X-Frame-Options: DENY | Security headers present on all responses | ✅ PASS |

---

## 3. Defects Discovered and Fixes Applied

1. **Defect:** `AttributeError: 'str' object has no attribute 'isoformat'` in `scan.py` lines 192 and 246.  
   **Root Cause:** In SQLite ORM model, `created_at` was stored as ISO string, but the API response called `.isoformat()` again.  
   **Fix Applied:** Added type check `isinstance(scan.created_at, str)` before formatting.  
   **Regression Verification:** Fixed; both scan endpoints return 200 OK with valid ISO timestamps.

2. **Defect:** `TypeError: MinMaxScaler does not support sparse input` in `train_email_model.py`.  
   **Root Cause:** `TfidfVectorizer` outputs a scipy sparse matrix, while `MinMaxScaler` expects dense arrays.  
   **Fix Applied:** Removed unnecessary `MinMaxScaler` since TF-IDF features are non-negative and compatible with `MultinomialNB`.  
   **Regression Verification:** Fixed; `train_email_model.py` runs cleanly with 100% test accuracy.

3. **Defect:** Windows CP1252 console encoding crashed ML orchestrator on Unicode box-drawing characters.  
   **Root Cause:** Windows default console encoding cp1252 cannot encode UTF-8 box characters.  
   **Fix Applied:** Configured `sys.stdout.reconfigure(encoding='utf-8', errors='replace')` across all scripts and set `$env:PYTHONIOENCODING="utf-8"`.  
   **Regression Verification:** Fixed; all training and evaluation scripts execute cleanly.

---

## 4. Frontend Production Build Verification

```
> frontend@0.0.0 build
> vite build

vite v8.3.5 building client environment for production...
transforming...
✓ 2715 modules transformed.
rendering chunks...
computing gzip size...
dist/index.html                   0.45 kB │ gzip:   0.29 kB
dist/assets/index-nqMpL4T3.css    1.78 kB │ gzip:   0.81 kB
dist/assets/index-Dt7Xw8MJ.js   813.76 kB │ gzip: 238.14 kB
✓ built in 768ms
```
**Outcome:** **PASS** (Zero compiler warnings, zero errors).

