# ARCHITECTURE.md — App Socios Estadio

## 1. Repositorios y estructura

Polyrepo (7 repos en `perfilamiento/`):

```txt
perfilamiento/
├── app-socios-estadio-infra/      # Terraform (AWS + GCP infra)
├── app-socios-estadio-backend/    # Rails 8 API
├── app-socios-estadio-frontend/   # React SPA usuarios
├── app-socios-estadio-admin/       # React SPA admin
├── app-socios-estadio-face-search/ # Go service (Cloud Run)
├── app-socios-estadio-docs/        # Esta documentación
└── camera-server/                  # Python recognition pipeline + dashboard
```

> Nombres consistentes de repos en GitHub: `app-socios-estadio-<nombre>`.  

## 2. Stack por componente

### 2.1 Backend (`app-socios-estadio-backend/`)

- Rails 8 API-only (Ruby 3.4).
- PostgreSQL 16.
- Auth JWT (access 1h, refresh 7d) vía cookies httpOnly para users; cookie httpOnly separada para admins.
- Rack-attack para rate limiting.
- Puerto dev: **3001**.

### 2.2 Frontend usuarios (`app-socios-estadio-frontend/`)

- React 19 + Vite 8.
- Tailwind v4 + shadcn/ui.
- TanStack Query v5.
- React Hook Form + Zod.
- React Router v7.
- Puerto dev: **5173**.

### 2.3 Admin panel (`app-socios-estadio-admin/`)

- Mismo stack que `frontend/`.
- Puerto dev: **5175**.
- Proxy `/api` → `http://localhost:3001` (Rails dev).

### 2.4 Go service (`app-socios-estadio-face-search/`)

- Go 1.24.
- Cloud Run target.
- Lee de PostgreSQL compartido con backend Rails (sin DB propia).
- Puerto default: 8080, dev: 8081.

### 2.5 Camera server (`camera-server/`)

- Python (FastAPI/NestJS para API REST) + recognition pipeline en Python.
- Dashboard HLS estático (`dashboard/index.html`) + dashboard web React (`dashboard-web/`).
- Puerto dev: **8080** para API REST.
- Streamer: **ZLMediaKit** (reemplazó MediaMTX). Puerto: 8554 (RTSP), 8083 (HTTP API).
- NVR: Hikvision (`192.168.1.13`, admin/simon2323).
- Canales NVR: **2XX = Cámara 01** (192.168.254.3), **3XX = Cámara 02** (192.168.254.4); sufijo par = main stream (alta res), impar = sub stream (baja res).
  - 201 = Cámara 01 main (1920×1080), 202 = sub (640×360)
  - 301 = Cámara 02 main (1920×1080), 302 = sub (640×360)
- DB: PostgreSQL propia (`camserver`) vía Docker Compose.
- Push a ZLMediaKit: `perfilamiento-recognition-1` → streams `live/201` (Cámara 01) y `live/301` (Cámara 02).

---

## 3. Boundaries y dependencias

### 3.1 Capas

A nivel lógico (backend + servicios):

- **Domain**: modelos, reglas de negocio, invariantes.
- **Application**: servicios y casos de uso.
- **Interface**: controllers HTTP / handlers.
- **Infrastructure**: DB, Redis, Rekognition, S3, Twilio, etc.

Regla:
- Interface → Application → Domain.
- Infrastructure depende de Domain/Application, no al revés.

### 3.2 Frontend

- `frontend/` y `admin/` solo hablan con `backend/` (Rails) y, para face search, con Go service.
- No acceden directo a AWS/GCP; todo via APIs backend/Go service.
- State server-side vía TanStack Query, sin inventar client state innecesario.

#### Face search (admin → Go service, bypass Rails)

El panel admin consulta la búsqueda facial **directamente** al Go service, sin pasar por Rails. Esto desacopla la carga de Rekognition del backend principal y evita hop extra.

- Endpoint: `POST {VITE_FACE_SEARCH_URL}/search-face` (default dev: `http://localhost:8081`)
- Auth: header `Authorization: Bearer {VITE_FACE_SEARCH_TOKEN}` (token compartido entre admin y Go service via env vars)
- Request body: `{ "image": "data:image/jpeg;base64,..." }`
- Response: `{ matches: [{ user_id, rut, phone, confidence, face_id, photo_url }], query_time_ms }`
- CORS: Go service valida origin contra allowlist en `CORS_ORIGINS` (comma-separated). Default dev: `http://localhost:5174,http://localhost:5175`. Sin allowlist = sin CORS = bloqueado por browser.

Regla: el admin NUNCA llama `/api/v1/admin/face-search` en Rails. El endpoint Rails para face records (`GET /api/v1/admin/users/:id/face_records`, `POST .../reindex-face`) es solo para consultar/reindexar caras de un user conocido — no para buscar.

### 3.3 Integraciones externas

- AWS Rekognition + S3.
- GCP: Cloud SQL, Cloud Run, Memorystore.
- Twilio (fase 2).

Todas las integraciones deben pasar por capas de infraestructura dedicadas (no llamadas directas desde dominio).

---

## 4. Diagrama simplificado

```txt
frontend (React)    admin (React)    camera-server (Python)
       │                │                  │
       ├────── API REST ┤                  │
       │                │                  ├──── ZLMediaKit (HLS/RTMP)
       │                │                  │
        └─── backend (Rails API)          │
                 │                    ┌────┴────┐
       ┌─────────┴─────────┐         │   NVR   │
       │                   │         │ (Hikvision)
   PostgreSQL         AWS Rekognition  └──────────┘
   (Cloud SQL)        + S3
       │
       └── face-search-service (Go, Cloud Run)
                │
            AWS Rekognition + S3 (presigned URLs)
```

---

## 5. Patrones y decisiones arquitectónicas

- Tres frontends separados por responsabilidad (`frontend`, `admin`, `face-search` UI dentro de admin).
- Go service separado del backend Rails para aislar carga y dependencia de Rekognition.
- AWS se usa solo para biometría y fotos; DB principal vive en GCP.
- Face liveness ya existe como Lambda + API Gateway; este proyecto se conecta a su salida, no la implementa.
- camera-server es un repo separado que corren los guardias; entrega HLS via ZLMediaKit. No depende del backend Rails ni del Go service.
- ZLMediaKit reemplaza MediaMTX para streaming HLS/RTMP.

---

## 6. Escalabilidad y resiliencia (alto nivel)

- Rack-attack para rate limiting en backend Rails.
- Circuit breakers y retry con backoff para:
  - AWS Rekognition
  - S3
  - APIs externas (Twilio, etc).
- Go service stateless en Cloud Run, escalable horizontalmente.
- Health checks para backend y Go service.

---

## 7. Puntos sensibles

- Integración Rekognition (drift de schema en `face_records`).
- Manejo de tokens y cookies entre frontends y backend.
- Consistencia entre IDs de usuario en Rails y Go service.
- Credenciales AWS: en prod, IAM roles (no env vars). En dev, usar `.env` gitignored.
- ZLMediaKit: los streams HLS requieren re-stream si el NVR cambia IPs.
