

variable "source_db_username" {}
variable "source_db_password" {}
variable "source_db_port" {}
variable "source_db_host" {}

variable "target_db_username" {}
variable "target_db_password" {}
variable "target_db_port" {}
variable "target_db_host" {}


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

