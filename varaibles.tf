# variables.tf

# KMS Key Configuration
variable "kms_key_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encrypting Secrets Manager secrets"
}

# Secrets Manager Configuration
variable "secret_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
  default     = "dms-db-credentials"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default = "admin"
}

variable "db_password" {
  description = "Database password (mark as sensitive)"
  type        = string
  sensitive   = true
  default = "s3cur3P@ssw0rd"
}

variable "db_port" {
  description = "Database port number"
  type        = number
  default     = 5432 
}

variable "db_host" {
  description = "Database host address"
  type        = string
  default = "db.example.com"
}

# Comment out or remove the DMS-related variables
# variable "endpoint_id" {
#   description = "Unique identifier for the DMS endpoint"
#   type        = string
#   default     = "dms-target-endpoint"
# }

# variable "endpoint_type" {
#   description = "Type of DMS endpoint (source/target)"
#   type        = string
#   default     = "source"
# }

# variable "engine_name" {
#   description = "Database engine (e.g., mysql, oracle, postgres)"
#   type        = string
#   default     = "aurora-postgresql" 
# }

# variable "database_name" {
#   description = "Name of the target database"
#   type        = string
#   default     = "mydatabase"
# }

# variable "dms_role_name" {
#   description = "Name of the IAM role for DMS secrets access"
#   type        = string
#   default     = "DMSScretsAccessRole"
# }

# variable "dms_policy_name" {
#   description = "Name of the IAM policy for DMS secrets access"
#   type        = string
#   default     = "DMSScretsAccessPolicy"
# }

# variable "secret_arns" {
#   description = "List of secret ARNs that DMS can access"
#   type        = list(string)
#   default     = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:prod-db-credentials"] # Replace with specific ARNs for stricter access
# }

variable "tags" {
  description = "Tags for the resources"
  type        = string
  default     = "non-prod"
}