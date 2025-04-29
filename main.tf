data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 1. KMS Key with Policy for DMS Decrypt Access
# 2. IAM Role for DMS Secrets Access
resource "aws_iam_role" "dms_secrets_access_role" {
  name = "DMSScretsAccessRole-01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 3. IAM Policy for DMS Secrets Access
resource "aws_iam_policy" "dms_secrets_access_policy" {
  name        = "DMSSecretsAccessPolicy"
  description = "Policy to allow DMS to access secrets in Secrets Manager and decrypt using KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSecretAccess",
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "${aws_secretsmanager_secret.db_credentials.arn}"
      },
      {
        Sid    = "AllowKMSDecrypt",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "${aws_kms_key.secrets_kms_key.arn}"
      }
    ]
  })
}
# 4. Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "dms_secrets_access_attachment" {
  role       = aws_iam_role.dms_secrets_access_role.name
  policy_arn = aws_iam_policy.dms_secrets_access_policy.arn
}


resource "aws_kms_key" "secrets_kms_key" {
  description             = "KMS key for encrypting Secrets Manager secrets"
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSpecifiedAccount",
        Effect    = "Allow",
        Principal = { AWS = "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action    = "kms:*",
        Resource  = "*"
      },
      {
        Sid       = "AllowDMSDecryptAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.dms_secrets_access_role.name}"
        },
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
              "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.dms_secrets_access_role.name}"
            ]
          }
        }
      }
    ]
  })
  depends_on = [aws_iam_role.dms_secrets_access_role]
}
# 5. Secrets Manager Secret (Example for Database Credentials)
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "dms-db-credentials"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
  description = "Credentials for DMS database endpoint"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowDMSRoleAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.dms_secrets_access_role.name}"
        },
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

# 6. Secret Value (JSON-structured credentials)
resource "aws_secretsmanager_secret_version" "db_credentials_value" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username,
    password = var.db_password,
    port     = var.db_port,
    host     = var.db_host,
  })
}
