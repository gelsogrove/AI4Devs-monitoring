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

# Download and extract the frontend.zip from S3
aws s3 cp s3://${bucket_name}/frontend.zip /home/ec2-user/app/frontend.zip
cd /home/ec2-user/app
unzip -o frontend.zip

# Build the Docker image for frontend
cd /home/ec2-user/app/frontend
sudo docker build -t lti-recruiter-frontend .

# Run the frontend container
sudo docker run -d --name lti-frontend -p 3000:3000 lti-recruiter-frontend

# Timestamp to force update when needed
echo "Deployment timestamp: ${timestamp}"
