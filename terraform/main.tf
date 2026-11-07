terraform {
  required_version = ">= 1.3.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# No credentials required: the local provider only writes files on disk,
# which is enough to model "infrastructure" for this local-only exercise.
provider "local" {}

# Call the reusable storage module instead of hand-defining the resource
module "storage" {
  source      = "./modules/storage"
  bucket_name = var.bucket_name
  environment = var.environment
  labels      = var.labels
}

# Release manifest for the build the student is shipping.
resource "local_file" "release_manifest" {
  filename = "${path.module}/.generated/${var.environment}-release-manifest.json"
  content = jsonencode({
    # Fixed: reference var.bucket_name (declared in variables.tf).
    bucket      = var.bucket_name
    environment = var.environment
  })
}
