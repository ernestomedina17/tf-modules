resource "aws_kms_key" "key" {
  description = "kms key"
}

resource "aws_kms_key_policy" "policy" {
  key_id = aws_kms_key.key.id
  policy = jsonencode({
    Id = "kms_resource_policy"
    Statement = [
      {
        # Resource policy
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }

        Resource = "*"
        Sid      = "Allows IAM policies to allow access to the KMS key."
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.key.key_id
}
