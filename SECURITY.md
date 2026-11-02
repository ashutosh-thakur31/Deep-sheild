# DeepShield — Security Policy & Threat Model

**Version:** 1.0  
**Status:** Active Security Specification  
**Classification:** Defensive Engineering Documentation

---

## 1. Security Architecture Principles

DeepShield treats security as a core architectural requirement. As a cybersecurity product, DeepShield must remain secure against adversarial inputs, malicious URLs, exploit payloads, and denial-of-service attempts.

### Key Tenets
1. **Zero Outbound Probes (SSRF Elimination):** DeepShield NEVER connects to submitted URLs, downloads remote files, follows redirects, or executes JavaScript. All 29 URL features are computed purely through lexical and syntactic string decomposition.
2. **Data Minimization & Privacy:** Full email message bodies are evaluated strictly in ephemeral RAM and never stored in the database. Only an administrative preview (first 200 characters) is retained for audit tracking.
3. **Defense in Depth:** Input validation, sliding-window rate limiting, request size bounds, parameter binding, and strict response security headers operate across every tier.

---

## 2. Threat Model Assessment (STRIDE)

| Threat Category | Potential Attack Vector | DeepShield Countermeasure | Status |
|---|---|---|---|
| **Spoofing** | Attacker impersonates trusted origin or spoofed client IP. | IP resolution inspects trusted proxy headers; CORS origins whitelist only `http://localhost:5173`. | ✅ Mitigated |
| **Tampering** | Parameter manipulation or database record tampering. | SQLAlchemy parameterized queries prevent SQL injection. Input validators enforce character length limits. | ✅ Mitigated |
| **Repudiation** | User denies performing malicious scans or bulk deletions. | Database-backed `audit_events` table logs all scans and deletion activities with UTC timestamps. | ✅ Mitigated |
| **Information Disclosure** | Stack traces or internal secrets leaked to client on errors. | Global Flask error handlers intercept exceptions and return sanitized generic JSON messages (500, 400). | ✅ Mitigated |
| **Denial of Service** | Flooding scanner with large payloads or rapid requests. | 1MB global payload ceiling, 2,048-char URL limit, 50,000-char email limit, and 30 req/min sliding-window rate limiter per IP. | ✅ Mitigated |
| **Elevation of Privilege** | Server-Side Request Forgery (SSRF) to access private metadata endpoints (`169.254.169.254`, `localhost`). | Outright rejection of loopback and RFC 1918 private IPv4 subnets in URL scanner. Zero socket connections initiated. | ✅ Mitigated |

---

## 3. Server-Side Request Forgery (SSRF) Defense

Many naive phishing detection systems attempt to fetch the target webpage to inspect DOM content or take screenshots. This exposes the hosting infrastructure to catastrophic SSRF vulnerabilities (e.g. AWS/GCP instance metadata theft, internal port scanning).

In DeepShield:
```python
# From backend/app/api/scan.py
def is_private_or_loopback(hostname: str) -> bool:
    loopback_names = {'localhost', 'loopback', '::1', '0.0.0.0'}
    if hostname.lower() in loopback_names:
        return True
    try:
        addr = ipaddress.ip_address(hostname)
        return addr.is_private or addr.is_loopback or addr.is_link_local or addr.is_reserved
    except ValueError:
        pass
    return False
```
If an address resolves to a private or loopback range, the API rejects the request with HTTP 400 immediately.

---

## 4. HTTP Security Headers

Every HTTP response emitted by the Flask API automatically includes defensive security headers applied via `after_request` middleware:

```http
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
```

---

## 5. Vulnerability Reporting & Disclosure

To report a vulnerability or security defect in DeepShield:
1. Do not open public GitHub issues for security vulnerabilities.
2. Submit a detailed report including reproducible proof-of-concept steps to:  
   `[EMAIL ADDRESS / SECURITY CONTACT]`
3. The development team commits to triage and acknowledge valid security reports within 48 hours.

