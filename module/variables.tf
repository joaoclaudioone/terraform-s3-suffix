/*
 * Common
 */
variable "tags" {
  description = "Common tags"
  type        = map(string)
}
 
/*
 * Bucket
 */
variable "bucket_prefix" { 
  description = "Value used for bucket prefix"
  type        = string
}
 
variable "bucket_suffix" {
  description = "Value used for bucket suffix"
  type        = string
}
 
variable "acl" {
  description = "The canned ACL to apply"
  type        = string
  default     = "private"
}
 
variable "versioning" {
  description = "Enable objects versioning"  
  type        = bool
  default     = false
}
 
variable "force_destroy" {
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  type        = bool
  default     = false
}
 
variable "server_side_encryption" {
  description = "Map containing server-side encryption configuration"
  type        = map(string)
  default     = {
    sse_algorithm = "AES256"
  }
}
 
variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management"
  type        = any
  default     = []
}
 
variable "enable_policy" {
  description = "Enable the creation of policy"
  type        = bool
  default     = false
}
 
variable "bucket_policy" {
  description = "Rules for the bucket policy"
  type        = any
  default     = []
}