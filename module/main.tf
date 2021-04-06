/*
 * This locals test if the variable has some values, if true set the 
 * local.encryption with the value of the var.server_side_encryption.
 * If false set local.encryption null.
 * In the section of the resource, the values will be tested and if has no 
 * valid keys, default values will be defined
 */
locals {
  sse_enabled     = length(keys(var.server_side_encryption)) > 0
  encryption      = local.sse_enabled ? [var.server_side_encryption] : []
}
 
/*
 * This resource will create the bucket and iterate through the variables.
 * Using lookup to seek for the values and define a default value to void errors
 */
resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_prefix}-${var.bucket_suffix}"
  acl           = var.acl
  force_destroy = var.force_destroy
 
  versioning {
    enabled = var.versioning
  }
 
  dynamic "server_side_encryption_configuration" {
    for_each = local.encryption
    iterator = sse
 
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = lookup(sse.value, "kms_master_key_id", null)
          sse_algorithm = lookup(sse.value, "sse_algorithm",
            lookup(sse.value, "kms_master_key_id", null) == null ? "AES256" : "aws:kms"
          )
        }
      }
    }
  }
 
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    iterator = rule
 
    content {
      id                                     = lookup(rule.value, "id", null)
      prefix                                 = lookup(rule.value, "prefix", null)
      tags                                   = lookup(rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = rule.value.enabled
 
      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]
 
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }
 
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])
 
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
 
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [rule.value.noncurrent_version_expiration]
        iterator = expiration
 
        content {
          days = lookup(expiration.value, "days", null)
        }
      }
 
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])
        iterator = transition
 
        content {
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }
 
  tags = merge(var.tags, {
    Name        = "${var.bucket_prefix}-${var.bucket_suffix}"
  },)
}
 
/*
 * This data structure retrieve the account id for the current account
 */
 
data "aws_caller_identity" "current" {}
 
/*
 * Data structure that will create a json policy for the bucket
 */
data "aws_iam_policy_document" "s3_default" {
  count = var.enable_policy ? 1 : 0
 
  dynamic "statement" {
    for_each = [ for i in var.bucket_policy :
      {
        effect = i.effect
        actions = i.actions
      }
    ]
 
    content {
      effect = statement.value.effect
      actions = statement.value.actions
      resources = [
        "${aws_s3_bucket.bucket.arn}/*",
         aws_s3_bucket.bucket.arn ]
 
      principals {
        type        = "AWS"
        identifiers = lookup(statement.value, "identifiers", [ "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" ])
      }
    }
  }
}
 
/*
 * This resource will attach the policy created at data structure above
 */
resource "aws_s3_bucket_policy" "default" {
  count = var.enable_policy ? 1 : 0
 
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_default[0].json
}
 
output "bucket_arn" {
  description = "Bucket ARN"
  value = aws_s3_bucket.bucket.arn
}
