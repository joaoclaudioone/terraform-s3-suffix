/*
 * Commons informations
 */

variable "region" {
  description = "Region that the resources will be created"
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags"
  default = {
    terraform  = "true"
    repository = "" # git config --get remote.origin.url
  }
}

/*
 * Bucket 
 */
variable "bucket_prefix" {
  description = "Value used for bucket prefix"
  type        = string
  default     = "twitter-reality-shows"
}

variable "bucket_config" {
  description = "Map with the bucket config"
  type = any
  default = {
    hourly = {
      bucket_suffix   = "hourly"
      acl             = "private"
      versioning      = false
      lifecycle_rules = [
        {
          id      = "hourly"
          enabled = true
          prefix  = "hourly-data-stream/"

          tags    = {
            rule  = "hourly"
        }

        expired_object_delete_marker = 1 

        transition =[
            {
                days          = 7
                storage_class = "GLACIER"
            }
          ]

        expiration = {
            days = 15
        }
        },
        {
          id      = "temp"
          enabled = true
          prefix  = "temp/"

          tags    = {
            rule  = "temp"
          }
          
          transition =[
            {
                days          = 1
                storage_class = "GLACIER"
            }
          ]

          expiration = {
              days = 7
          }
        }]
#      enable_policy   = true
#      policy = [{
#            effect        = "Allow"
#            actions       = ["s3:*"]
#        }]
    },
    daily = {
      bucket_suffix = "daily"
      acl           = "authenticated-read"
      versioning    = true

      lifecycle_rules = [
        {
          id      = "daily"
          enabled = true
          prefix  = "daily-data-stream/"

          tags    = {
            rule  = "daily"
          }
          
          transition =[
            {
                days          = 15
                storage_class = "GLACIER"
            }
          ]

          expiration = {
              days = 30
          }
        }
      ]
      enable_policy   = true
      policy = [
        {
          effect        = "Allow"
          actions       = ["s3:ListBucket", "s3:GetObject"]
        }]
    },
    weekly = {
      bucket_suffix = "weekly"
      acl           = "public-read"
      versioning    = false

      lifecycle_rules = [
        {
          id      = "weekly"
          enabled = true
          prefix  = "weekly-data-stream/"

          tags    = {
            rule  = "weekly"
          }
          
          transition = [
            {
                days          = 60
                storage_class = "GLACIER"
            }
          ]

          expiration = {
              days = 90
          }
        }
      ]

      enable_policy   = true
      policy = [
        {
            effect        = "Allow"
            actions       = ["s3:ListBucket", "s3:GetObject"]
        },
        {
            effect        = "Deny"
            actions       = ["s3:PutObject"]
        }
        ]      
    }
  }
}