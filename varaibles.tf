# variables.tf

# DMS Service Role ARN
variable "dms_role_arn" {
  description = "ARN of the IAM role used by DMS to access Secrets Manager and KMS"
  type        = string
}

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
}

variable "db_password" {
  description = "Database password (mark as sensitive)"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port number"
  type        = number
  default     = 3306 # Default for MySQL; adjust as needed
}

variable "db_host" {
  description = "Database host address"
  type        = string
}

# DMS Endpoint Configuration
variable "endpoint_id" {
  description = "Unique identifier for the DMS endpoint"
  type        = string
  default     = "dms-target-endpoint"
}

variable "endpoint_type" {
  description = "Type of DMS endpoint (source/target)"
  type        = string
  default     = "target"
}

variable "engine_name" {
  description = "Database engine (e.g., mysql, oracle, postgres)"
  type        = string
  default     = "mysql"
}

variable "database_name" {
  description = "Name of the target database"
  type        = string
  default     = "mydatabase"
}