# Partial backend config for the staging environment.
# Usage: terraform -chdir=terraform init -backend-config=envs/staging/backend.hcl
#
# This should point at its own state file, isolated from dev.
path = "envs/staging/terraform.tfstate"
