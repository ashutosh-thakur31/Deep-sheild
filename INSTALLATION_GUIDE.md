# DeepShield — Installation & Quickstart Guide

This guide details the steps required to set up, configure, train, and run the DeepShield platform on a local workstation.

---

## 1. System Requirements

- **Operating System:** Windows 10/11, macOS, or Linux (Ubuntu 20.04+)
- **Python:** Version 3.10 to 3.14
- **Node.js:** Version 18.x, 20.x, or 24.x
- **Package Managers:** `pip` (or `python -m pip`), `npm`

---

## 2. Repository Setup

Clone or navigate to the repository directory:
```bash
cd "Deep_sheild_final"
```

---

## 3. Backend Setup

### A. Install Python Dependencies
```powershell
python -m pip install -r backend/requirements.txt
python -m pip install flask-sqlalchemy pytest python-docx
```

### B. Configure Environment
A default `.env.example` is located in `backend/.env.example`. Create `backend/.env`:
```powershell
Copy-Item backend\.env.example backend\.env
```

---

## 4. Train the Machine Learning Models

Before running the application, generate the synthetic training datasets and train the classifiers:
```powershell
$env:PYTHONIOENCODING="utf-8"
python scripts/run_training.py
```
This executes end-to-end:
1. Generates 5,000 synthetic URL samples (`datasets/url/phishing_url_dataset.csv`)
2. Generates 3,000 synthetic email samples (`datasets/email/phishing_email_dataset.csv`)
3. Trains and benchmarks the URL classifier (saves `backend/app/ml/models/url_model.joblib`)
4. Trains and benchmarks the Email NLP classifier (saves `backend/app/ml/models/email_model.joblib`)

---

## 5. Frontend Setup

### A. Install Node Dependencies
```powershell
cd frontend
npm install
cd ..
```

---

## 6. Running the Automated Test Suite

To verify all backend endpoints, ML loaders, and security controls before starting servers:
```powershell
python -m pytest backend/tests/ -v
```
Expected result: **14 passed**.

---

## 7. Starting the Application

You can start both servers simultaneously using our provided startup scripts, or in two separate terminal windows.

### Method 1: Using the Windows Batch / PowerShell Script
Double-click `start_deepshield.bat` or run:
```powershell
.\start_deepshield.ps1
```

### Method 2: Manual Two-Terminal Startup

**Terminal 1 — Backend (Flask API on Port 5000):**
```powershell
python main.py
```
*Backend runs on http://localhost:5000*

**Terminal 2 — Frontend (React Vite on Port 5173):**
```powershell
cd frontend
npm.cmd run dev
```
*(Note: Use `npm.cmd` on Windows PowerShell to prevent script execution policy blocks)*
*Frontend runs on http://localhost:5173*

Open your browser and navigate to **http://localhost:5173**.

