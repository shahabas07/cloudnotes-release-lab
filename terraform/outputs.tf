output "bucket_metadata_path" {
  description = "Path to the generated bucket metadata file."
  value       = module.storage.bucket_path
}

output "release_manifest_path" {
  description = "Path to the generated release manifest file."
  value       = local_file.release_manifest.filename
}
