data "aws_caller_identity" "current" {}
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
        Principal =  { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }, 
        Action    = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}
# resource "aws_iam_policy" "dms_secrets_access_policy" {
#   name        = var.dms_policy_name
#   description = "Policy to allow DMS to access secrets in Secrets Manager"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "AllowSecretAccessDMS",
#         Effect = "Allow",
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ],
#         Resource = var.secret_arns
#       }
#     ]
#   })
# }
# resource "aws_iam_role" "dms_secrets_access_role" {
#   name = "DMSScretsAccessRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "dms.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "dms_secrets_access_attachment" {
#   role       = aws_iam_role.dms_secrets_access_role.name
#   policy_arn = aws_iam_policy.dms_secrets_access_policy.arn
# }

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
        Principal =  { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }, 
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
    username = var.db_username,
    password = var.db_password,
    port     = var.db_port,
    host     = var.db_host,
  })
}

# 4. DMS Endpoint Configuration
# resource "aws_dms_endpoint" "dms_endpoint" {
#   endpoint_id   = "dms-target-endpoint"
#   endpoint_type = "target" # or "source"
#   engine_name   = var.engine_name

#   secrets_manager_access_role_arn = aws_iam_role.dms_secrets_access_role.arn 
#   secrets_manager_arn            = aws_secretsmanager_secret.db_credentials.arn
#   kms_key_arn                    = aws_kms_key.secrets_kms_key.arn

  
#   database_name = "mydatabase"
#   ssl_mode      = "require"
#   tags = var.tags
# }