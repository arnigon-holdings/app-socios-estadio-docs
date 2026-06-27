# `app-socios-estadio-docs`

Documentación del proyecto App Socios Estadio. Repositorio markdown-only.

> **Este repo se lee primero** al arrancar en el proyecto. Contiene las reglas operativas (AGENTS.md), la verdad funcional (SPEC.md), los boundaries (ARCHITECTURE.md), y referencias a todos los demás subsistemas.

## Contenido

| Doc | Propósito | Cuándo leerlo |
|---|---|---|
| [`AGENTS.md`](./AGENTS.md) | Reglas operativas del agente: workflow, comunicación, principios de implementación, regla de UX "ocultar capa tecnológica", harness engineering, mapa de docs | **Siempre primero** |
| [`SPEC.md`](./SPEC.md) | Verdad funcional: qué hace el producto (registro, admin, búsqueda, puntos) | Al entender alcance |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | Boundaries por componente (frontend ↔ backend ↔ Go service), capas (domain/application/infrastructure), diagramas | Al diseñar features nuevas |
| [`INFRASTRUCTURE.md`](./INFRASTRUCTURE.md) | Principios de infra, Terraform, IAM, deploy (GCP Cloud Run, Cloud SQL) | Al tocar infra o deploy |
| [`CHECKLIST.md`](./CHECKLIST.md) | Estado de fases M0-M5 + Phase 2, qué falta, prioridades | Al planificar trabajo |
| [`ENVIRONMENT.md`](./ENVIRONMENT.md) | Variables de entorno backend (referencia) | Al configurar entorno |
| [`HARNESS.md`](./HARNESS.md) | Marco de harness engineering (feedforward/feedback) | Contexto conceptual |
| `Makefile` | Validación de docs (markdown lint + link check) — `make validate` | Al correr validaciones |

## Mapa de repos del proyecto

Este repo es uno de los 6 que componen el proyecto:

| Repo | Contenido | Polyrepo path |
|---|---|---|
| [`app-socios-estadio-infra`](https://github.com/arnigon-holdings/app-socios-estadio-infra) | Root: README, AGENTS (raíz, versión corta), docs/, `infrastructure/` (Terraform) | raíz |
| [`app-socios-estadio-docs`](https://github.com/arnigon-holdings/app-socios-estadio-docs) | **Este repo**: AGENTS (versión completa), ARCHITECTURE, SPEC, INFRASTRUCTURE, CHECKLIST, ENVIRONMENT, HARNESS, Makefile | (markdown only) |
| [`app-socios-estadio-backend`](https://github.com/arnigon-holdings/app-socios-estadio-backend) | Rails 8 API | `backend/` |
| [`app-socios-estadio-frontend`](https://github.com/arnigon-holdings/app-socios-estadio-frontend) | React SPA socios | `frontend/` |
| [`app-socios-estadio-admin`](https://github.com/arnigon-holdings/app-socios-estadio-admin) | React SPA admin | `admin/` |
| [`app-socios-estadio-face-search`](https://github.com/arnigon-holdings/app-socios-estadio-face-search) | Go service (búsqueda facial) | `face-search-service/` |

> **Convencion polyrepo**: cada subsistema tiene su propio `.git`. El root tiene docs/AGENTS/README + `infrastructure/`. Las apps viven en sus propios repos y se referencian desde acá.

## Para LLMs que arrancan en el proyecto

1. **Leé este README** (orientación general).
2. **Leé [`AGENTS.md`](./AGENTS.md)** (reglas operativas — no negociables).
3. **Leé [`SPEC.md`](./SPEC.md)** (qué hace el producto).
4. **Leé [`ARCHITECTURE.md`](./ARCHITECTURE.md)** (boundaries — qué puede tocar tu subsistema).
5. **Si vas a tocar `frontend/`**: leé [`app-socios-estadio-frontend/CLAUDE.md`](https://github.com/arnigon-holdings/app-socios-estadio-frontend/blob/main/CLAUDE.md).
6. **Si vas a tocar `admin/`**: leé [`app-socios-estadio-admin/CLAUDE.md`](https://github.com/arnigon-holdings/app-socios-estadio-admin/blob/main/CLAUDE.md).
7. **Si vas a tocar infra (Terraform)**: leé [`INFRASTRUCTURE.md`](./INFRASTRUCTURE.md) y explorá [`app-socios-estadio-infra/infrastructure/`](https://github.com/arnigon-holdings/app-socios-estadio-infra/tree/main/infrastructure).
8. **Antes de commitear**: corré `git status` + `git diff` para verificar qué entra, especialmente buscar secrets (`git grep -E "AKIA|AIza"`).

**Output esperado del agente** (per AGENTS.md):

> Cambios pequeños, locales y reversibles. Sin sobreingeniería. Sin comentarios obvios. Tests cuando aplica. Reportar qué se hizo, qué se verificó, qué queda pendiente.

## Convenciones

- **Markdown only**: este repo no tiene código. Si necesitás agregar lógica, va en el repo del subsistema correspondiente.
- **Sin emojis**: salvo que el usuario los pida explícitamente (regla de AGENTS.md).
- **Changelog implícito por git**: no mantenemos CHANGELOG.md, los commits cuentan la historia.