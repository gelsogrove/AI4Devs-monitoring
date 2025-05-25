#!/bin/bash
# Update system and install dependencies
sudo yum update -y
sudo yum install -y docker unzip aws-cli

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Create app directory
mkdir -p /home/ec2-user/app

# Download and extract the backend.zip from S3
aws s3 cp s3://${bucket_name}/backend.zip /home/ec2-user/app/backend.zip
cd /home/ec2-user/app
unzip -o backend.zip

# Build the Docker image for backend
cd /home/ec2-user/app/backend
sudo docker build -t lti-recruiter-backend .

# Run the backend container
sudo docker run -d --name lti-backend -p 8080:8080 lti-recruiter-backend

# Timestamp to force update when needed
echo "Deployment timestamp: ${timestamp}"
