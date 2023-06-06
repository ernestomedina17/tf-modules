output "kms_key_id" {
  value = aws_kms_key.key.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.alias.arn
}
