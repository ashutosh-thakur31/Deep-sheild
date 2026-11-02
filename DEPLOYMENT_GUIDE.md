# DeepShield — Production Deployment Guide

This guide details best practices for deploying DeepShield into an institutional or enterprise intranet environment.

---

## 1. Production Architecture Overview

In a production environment, the development servers (`app.run()` and `vite dev`) should be replaced by production WSGI/ASGI application servers and a high-performance reverse proxy (e.g., Nginx):

```
[Clients]
   │ HTTPS :443
   ▼
[Nginx Reverse Proxy]
   ├── /api/*   ──────► [Waitress / Gunicorn WSGI] :5000 (Flask Backend)
   └── /*       ──────► [Static Files] (Built React frontend in /dist)
```

---

## 2. Frontend Production Build

Compile the React frontend into static assets:
```bash
cd frontend
npm run build
```
This produces optimized, minified HTML/CSS/JS bundles inside `frontend/dist/`.

---

## 3. Production WSGI Server

### On Windows Server (Waitress)
Install and run Waitress:
```powershell
python -m pip install waitress
waitress-serve --listen=0.0.0.0:5000 main:app
```

### On Linux Server (Gunicorn)
Install and run Gunicorn:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 --access-logfile - --error-logfile - "main:app"
```

---

## 4. Nginx Reverse Proxy Configuration

Create an Nginx configuration snippet:
```nginx
server {
    listen 80;
    server_name deepshield.example.local;

    # Serve built React frontend
    root /var/www/deepshield/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to Flask WSGI backend
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 1M;
    }
}
```

---

## 5. Database Backup Guidance

DeepShield uses SQLite (`deepshield.db`). To perform an online, non-blocking backup of the database:
```bash
sqlite3 backend/deepshield.db ".backup 'deepshield_backup_$(date +%Y%m%d).db'"
```
Store database backups in an access-restricted archive location.

