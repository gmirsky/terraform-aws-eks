resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = false
  tags                    = local.common_tags
}
