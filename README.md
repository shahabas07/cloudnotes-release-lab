# cloudnotes-release-lab

Small, self-contained repo for a Cloud Computing debugging exercise covering
Terraform fundamentals, reusable modules, state/backends, and a containerized
microservice release. Everything here is designed to be validated/built
**locally at ₹0** — no live cloud account, no paid registry, no billing.

This repo is **intentionally broken with three planted faults**. Your job is
to find and fix them, then fill in `release-notes.md` with evidence.

## Intended design (how it should work once fixed)

### Terraform (`terraform/`)

- `main.tf` calls the reusable module in `terraform/modules/storage/` to
  create the bucket metadata resource — it should **not** hand-define a
  duplicate `local_file` resource for the same purpose.
- `variables.tf` / `outputs.tf` reference real, declared variable and module
  output names only.
- State stays local and isolated per environment. `backend.tf` declares an
  empty `local` backend, and each environment supplies its own state path via
  a partial backend config file:
  - `terraform/envs/dev/backend.hcl`
  - `terraform/envs/staging/backend.hcl`

  Each environment's `path` must point at its **own** state file — never
  share a path between environments.
- Only these commands are needed to work through this exercise. **Never run
  `terraform apply`**:

  ```bash
  terraform -chdir=terraform init
  terraform -chdir=terraform fmt -check
  terraform -chdir=terraform validate
  terraform -chdir=terraform plan
  ```

  `init` here only downloads the free `hashicorp/local` provider and sets up
  the default local backend (state stored on disk in `terraform/`) — no
  cloud account, credentials, or cost involved. If you only want to check
  syntax/module wiring without touching any backend/state at all, you can
  use `terraform init -backend=false`, but note `plan` requires a fully
  initialized backend.

- The `local` provider is used everywhere so `init`/`validate`/`plan` need no
  cloud credentials at all.

### Microservice boundary (`app/`)

CloudNotes is conceptually split into two services:

- **notes-service** — the API in `app/` (this repo), owning note CRUD and
  exposing `GET /health`.
- **auth-service** — (out of scope for this exercise) would own
  authentication/token issuance and be consumed by `notes-service` over
  HTTP.

For this lab only `notes-service` is runnable. `GET /health` should return
HTTP 200 with a small JSON body indicating status `ok`.

### Container build (`Dockerfile`)

Multi-stage build:

1. **`deps`** stage — installs npm dependencies.
2. **`runtime`** stage — copies only `node_modules` and app source from the
   `deps` stage, keeping the final image small. The runtime stage's
   `COPY --from=` must reference the `deps` stage by name.

```bash
docker build -t cloudnotes-api:0.1.0 .
docker compose up -d --build
curl http://localhost:8080/health
```

### Secrets

`API_KEY` must **never** be hardcoded in the `Dockerfile` or `compose.yaml`.
Supply it at runtime via `.env` (copied from `.env.example`, gitignored) or a
Compose secret. `security/check.sh` does a quick local grep-based check for
hardcoded secrets and confirms `.env` is gitignored. If you have
[Trivy](https://trivy.dev/) installed you can optionally run
`trivy image cloudnotes-api:0.1.0` for a deeper scan — it is not required.

## The three faults

This repo ships with exactly three planted faults:

1. A Terraform/HCL reference/type fault that breaks `terraform validate`.
2. A reusable-module fault (hand-duplicated resource instead of a module
   call) combined with a state-isolation fault (two environments sharing one
   local backend path).
3. A container build fault (wrong `COPY --from=` stage name) combined with a
   hardcoded fake secret in the Dockerfile.

Fix all three, then document your diagnosis and fix in `release-notes.md`.

## Ground rules

- Local/mock-safe only: no real project IDs, cloud credentials, or live API
  keys anywhere in this repo.
- Use `terraform init -backend=false` / `fmt` / `validate` / `plan` only —
  never `terraform apply`.
- Never push images to a paid container registry. The `registry:2` service
  in `compose.yaml` is a free, local artifact store for practice only.

## tasks
1. fix the terraform / HCL validation ault
2. fix reusable module and state backend fault
3. fix the container build and local artifact fault
// after fix create a simple task submission md and provide the github link, all three task explaination and file changes, add terminal commands for the terraform validate and terraform plan, terraform apply was not done (no resource and no billing), container builds locally and docker compose health check pass, no env secrets commited