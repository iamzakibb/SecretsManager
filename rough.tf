data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Variables (Add these to your variables.tf)


# 1. Create two secrets managers
resource "aws_secretsmanager_secret" "source_db_credentials" {
  name        = "dms-db-credentials-source"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
  description = "Credentials for source database"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSourceRoleAccess",
        Effect = "Allow",
        Principal = { AWS = var.source_role_arn },
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "target_db_credentials" {
  name        = "${aws_secretsmanager_secret.source_db_credentials.name}-target"
  kms_key_id  = var.kms_key_arn
  description = "Credentials for target database"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowTargetRoleAccess",
        Effect = "Allow",
        Principal = { AWS = var.target_role_arn },
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

# 2. Secret Values
resource "aws_secretsmanager_secret_version" "source_credentials" {
  secret_id = aws_secretsmanager_secret.source_db_credentials.id
  secret_string = jsonencode({
    username = var.source_db_username
    password = var.source_db_password
    port     = var.source_db_port
    host     = var.source_db_host
  })
}

resource "aws_secretsmanager_secret_version" "target_credentials" {
  secret_id = aws_secretsmanager_secret.target_db_credentials.id
  secret_string = jsonencode({
    username = var.target_db_username
    password = var.target_db_password
    port     = var.target_db_port
    host     = var.target_db_host
  })
}

# 3. KMS Key Policy Update
resource "aws_kms_key" "secrets_kms_key" {
  description         = "KMS key for encrypting Secrets Manager secrets"
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "EnableRootPermissions",
        Effect    = "Allow",
        Principal = { AWS = "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action    = "kms:*",
        Resource  = "*"
      },
      {
        Sid       = "AllowSourceDecryptAccess",
        Effect    = "Allow",
        Principal = { AWS = var.source_role_arn },
        Action    = ["kms:Decrypt", "kms:DescribeKey"],
        Resource  = "*"
      },
      {
        Sid       = "AllowTargetDecryptAccess",
        Effect    = "Allow",
        Principal = { AWS = var.target_role_arn },
        Action    = ["kms:Decrypt", "kms:DescribeKey"],
        Resource  = "*"
      },
      {
        Sid       = "DenyExternalAccess",
        Effect    = "Deny",
        Principal = "*",
        Action    = "kms:*",
        Resource  = "*",
        Condition = {
          ArnNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:root",
              var.source_role_arn,
              var.target_role_arn
            ]
          }
        }
      }
    ]
  })
}