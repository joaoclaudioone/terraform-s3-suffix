# S3-suffix
Terraform module that will create S3 bucket with parameters like
- bucket policy
- versioning
- server side encryption
- lifecycle rules
 
This solution uses a map object and parses the values to the module. This README covers the use of this module. For detailed information, the resources have some comments above the code. 
 
## Example of use
Inside infra directory has an example of the usage that creates three buckets with the same prefix and different suffixes.
```
.
├── main.tf
└── variables.tf
```
#### `main.tf`
It's a module structure that will iterate through the `bucket_config` variable. To keep the creation flexible, it's used the `lookup` function to pass the default values case the value was not declared.
 
#### `variables.tf`
Has few variables with common values like tags and bucket_prefix. The variable `bucket_config` is a map with all the values that will be needed in the module. 
 
## Module directory
The module folder that has the creation of the resources. 
```
.
├── main.tf
└── variables.tf
```
 
#### `main.tf`
This file creates the bucket and bucket policy. In this bucket we can configure ACL, versioning, encryption e lifecycle rules. To support the creation of different parameters, maps are used as input variables and for iterations in case of multiple values. 

#### `variables.tf`
The above table shows the values that are expected for this module

#### Inputs
 
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| tags | Common tags | `map(string)` | n/a | yes |
| bucket_prefix | Value used for bucket prefix | `string` | empty | yes |
| bucket_suffix | Value used for bucket suffix | `string` | empty | yes |
| acl | ACL for the bucket | `string` | `"private"` | no |
| versioning | Enable/disable versioning | `bool` | `false` | no |
| force_destroy | A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | `bool` | `false` | no |
| server_side_encryption | Map containing server-side encryption configuration | `map(string)` | `{sse_algorithm = "AES256"}` | no |
| lifecycle_rules | List of maps containing configuration of object lifecycle management | `any` | `[]` | no |
| enable_policy | Enable the creation of policy | `bool` | `false` | no |
| bucket_policy | Rules for the bucket policy | `any` | `[]` | no |
 
 
## Outputs
 
| Name | Description |
|------|-------------|
| bucket_arn | Arn of the created buckets |
