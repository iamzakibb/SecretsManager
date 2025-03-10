# terraform.tfvars

dms_role_arn     = "arn:aws:iam::123456789012:role/dms-service-role"
kms_key_description = "KMS key for DMS secrets"
secret_name      = "prod-dms-db-credentials"
db_username      = "admin"
db_password      = "s3cur3P@ssw0rd"
db_host          = "db.example.com"
db_port          = 5432 # Example for PostgreSQL
endpoint_id      = "prod-dms-endpoint"
endpoint_type    = "source"
engine_name      = "postgres"
database_name    = "production_db"
dms_role_name   = "Prod-DMS-Secrets-Role"
dms_policy_name = "Prod-DMS-Secrets-Policy"
secret_arns     = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:prod-db-credentials"]
tags = 