resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/scripts/backend_user_data.sh", { 
    timestamp = timestamp(),
    bucket_name = var.bucket_name
  })
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  tags = {
    Name = "lti-recruiter-backend"
  }
}

resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/scripts/frontend_user_data.sh", { 
    timestamp = timestamp(),
    bucket_name = var.bucket_name
  })
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  tags = {
    Name = "lti-recruiter-frontend"
  }
}
