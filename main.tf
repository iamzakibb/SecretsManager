# 1. KMS Key with Policy for DMS Decrypt Access
resource "aws_kms_key" "secrets_kms_key" {
  description             = "KMS key for encrypting Secrets Manager secrets"
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowDMSDecryptAccess",
        Effect    = "Allow",
        Principal = { AWS = "<DMS_ROLE_ARN>" }, # Replace with DMS service role ARN
        Action    = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# 2. Secrets Manager Secret (Example for Database Credentials)
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "dms-db-credentials"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
  description = "Credentials for DMS database endpoint"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSecretAccessDMS",
        Effect = "Allow",
        Principal = { AWS = "<DMS_ROLE_ARN>" }, # Replace with DMS service role ARN
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

# 3. Secret Value (JSON-structured credentials)
resource "aws_secretsmanager_secret_version" "db_credentials_value" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "db_username",
    password = "db_password",
    port     = 3306,
    host     = "db.example.com"
  })
}

# 4. DMS Endpoint Configuration
resource "aws_dms_endpoint" "dms_endpoint" {
  endpoint_id   = "dms-target-endpoint"
  endpoint_type = "target" # or "source"
  engine_name   = "mysql" # Replace with actual engine (e.g., oracle, postgres)

  secrets_manager_access_role_arn = "<DMS_ROLE_ARN>" # Replace with DMS service role ARN
  secrets_manager_arn            = aws_secretsmanager_secret.db_credentials.arn
  kms_key_arn                    = aws_kms_key.secrets_kms_key.arn

  # Additional required fields (example values)
  database_name = "mydatabase"
  ssl_mode      = "none"
}