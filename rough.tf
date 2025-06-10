data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 1. Create IAM Roles (unchanged)
resource "aws_iam_role" "target_dms_role" {
  name = "adt-edm-dms-service-target-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "dms.amazonaws.com"
      },
      Action = "stS:AssumeRole"
    }]
  })
}

# 2. Secrets Managers with OrgID Conditions
resource "aws_secretsmanager_secret" "source_db_credentials" {
  name        = "dms-db-credentials-source"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
  description = "Credentials for source database"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSecretsAccesstoDMS",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws-us-gov:iam::198895713261:role/adt-edm-dms-service-atlanta-infobank"
        },
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-a10ef4812"
          }
        }
      },
      {
        Sid    = "AllowListSecretstoDeployRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws-us-gov:iam::198895713261:role/cfs-landing-zone-deploy-role"
        },
        Action = ["secretsmanager:DescribeSecret"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-ai0eff4812"
          }
        }
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "target_db_credentials" {
  name        = "${aws_secretsmanager_secret.source_db_credentials.name}-target"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
  description = "Credentials for target database"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowTargetRoleAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.target_dms_role.arn
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

# 3. KMS Key Policy with OrgID Conditions
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
        Sid       = "AllowSourceAccess",
        Effect    = "Allow",
        Principal = {
          AWS = [
            "arn:aws-us-gov:iam::198895713261:role/adt-edm-dms-service-atlanta-infobank",
            "arn:aws-us-gov:iam::198895713261:role/cfs-landing-zone-deploy-role"
          ]
        },
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-ai0eff4812"
          }
        }
      },
      {
        Sid       = "AllowTargetAccess",
        Effect    = "Allow",
        Principal = {
          AWS = aws_iam_role.target_dms_role.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowKnownAccounts",
        Effect = "Allow",
        Principal = "*",
        Action = "kms:*",
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-ai0eff4812"
          }
        }
      },
      {
        Sid       = "DenyEverythingElse",
        Effect    = "Deny",
        Principal = "*",
        Action    = "kms:*",
        Resource  = "*",
        Condition = {
          "Not": {
            "StringEquals": {
              "aws:PrincipalOrgID": "o-ai0eff4812"
            }
          }
        }
      }
    ]
  })
}

# 4. Secret Values (unchanged)
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