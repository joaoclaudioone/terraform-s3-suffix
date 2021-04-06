provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "../module"

  for_each = var.bucket_config

  tags            = var.tags
  bucket_prefix   = var.bucket_prefix
  bucket_suffix   = each.value.bucket_suffix
  acl             = lookup(each.value, "acl", "private")
  versioning      = lookup(each.value, "versioning", false)
  lifecycle_rules = lookup(each.value, "lifecycle_rules", null)
  enable_policy   = lookup(each.value, "enable_policy", false)
  bucket_policy   = lookup(each.value, "policy", null)
}

output "bucket_arns" {
  value = { for index, i in module.s3_bucket : index => i.bucket_arn }
}
