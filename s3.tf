resource "aws_s3_bucket" "awsS3" {
  bucket = "pbn-udg"

  tags = {
    Name        = "met infa"
    Environment = "Dev"
  }
}