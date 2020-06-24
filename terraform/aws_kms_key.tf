resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}
