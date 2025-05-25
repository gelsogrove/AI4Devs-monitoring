resource "aws_s3_bucket" "code_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "code_bucket_ownership" {
  bucket = aws_s3_bucket.code_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "code_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.code_bucket_ownership]
  bucket     = aws_s3_bucket.code_bucket.id
  acl        = "private"
}

resource "null_resource" "generate_zip" {
  provisioner "local-exec" {
    command     = "cd .. && sh ./generar-zip.sh"
    working_dir = path.module
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_s3_object" "backend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "backend.zip"
  source     = "${path.module}/../backend.zip"
  depends_on = [null_resource.generate_zip]
}

resource "aws_s3_object" "frontend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "frontend.zip"
  source     = "${path.module}/../frontend.zip"
  depends_on = [null_resource.generate_zip]
}
