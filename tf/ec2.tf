resource "aws_instance" "backend" {
  ami                    = "ami-09f4814ae750baed6"  # Amazon Linux 2 AMI (hardcoded per semplicità)
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = <<-EOF
    #!/bin/bash
    set -e  # Exit immediately if a command exits with a non-zero status
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Redirect output to log file

    echo "===== Starting backend deployment at $(date) ====="

    # Update system
    yum update -y
    # Install required packages
    yum install -y httpd

    # Create a simple HTML page
    cat > /var/www/html/index.html << 'HTMLCONTENT'
    <!DOCTYPE html>
    <html>
    <head>
        <title>LTI Recruiter Backend API</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            h1 { color: #333; }
            .container { max-width: 800px; margin: 0 auto; padding: 20px; }
            .status { padding: 10px; background-color: #f0f0f0; border-radius: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>LTI Recruiter Backend API</h1>
            <p>Backend API service</p>
            <div class="status">
                <p>Server timestamp: $(date)</p>
            </div>
        </div>
    </body>
    </html>
    HTMLCONTENT

    # Create a simple API endpoint
    mkdir -p /var/www/html/api
    cat > /var/www/html/api/index.html << 'APIHTML'
    {
      "status": "online",
      "message": "Backend API is running",
      "timestamp": "$(date)"
    }
    APIHTML

    # Start the web server and enable it to start at boot time
    systemctl start httpd
    systemctl enable httpd

    # Configure port 8080 forwarding to port 80
    cat > /etc/httpd/conf.d/port8080.conf << 'CONF'
    Listen 8080
    <VirtualHost *:8080>
        DocumentRoot /var/www/html
    </VirtualHost>
    CONF

    # Restart Apache to apply changes
    systemctl restart httpd

    # Configure firewall to allow HTTP traffic
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    iptables -I INPUT -p tcp --dport 8080 -j ACCEPT

    echo "===== Backend deployment completed at $(date) ====="
    echo "Deployment timestamp: $(date)"
  EOF
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  tags = {
    Name = "lti-recruiter-backend"
    ForceRecreate = "true"
  }
}

resource "aws_instance" "frontend" {
  ami                    = "ami-09f4814ae750baed6"  # Amazon Linux 2 AMI (hardcoded per semplicità)
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = <<-EOF
    #!/bin/bash
    set -e  # Exit immediately if a command exits with a non-zero status
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Redirect output to log file

    echo "===== Starting frontend deployment at $(date) ====="

    # Update system
    yum update -y
    # Install required packages
    yum install -y httpd

    # Create a simple HTML page
    cat > /var/www/html/index.html << 'HTMLCONTENT'
    <!DOCTYPE html>
    <html>
    <head>
        <title>LTI Recruiter Frontend</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            h1 { color: #333; }
            .container { max-width: 800px; margin: 0 auto; padding: 20px; }
            .status { padding: 10px; background-color: #f0f0f0; border-radius: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>LTI Recruiter Frontend</h1>
            <p>Simple static page served by Apache</p>
            <div class="status">
                <p>Server timestamp: $(date)</p>
                <p>Backend API: http://${aws_instance.backend.private_ip}:8080</p>
            </div>
        </div>
    </body>
    </html>
    HTMLCONTENT

    # Start the web server and enable it to start at boot time
    systemctl start httpd
    systemctl enable httpd

    # Configure port 3000 forwarding to port 80
    cat > /etc/httpd/conf.d/port3000.conf << 'CONF'
    Listen 3000
    <VirtualHost *:3000>
        DocumentRoot /var/www/html
    </VirtualHost>
    CONF

    # Restart Apache to apply changes
    systemctl restart httpd

    # Configure firewall to allow HTTP traffic
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    iptables -I INPUT -p tcp --dport 3000 -j ACCEPT

    echo "===== Frontend deployment completed at $(date) ====="
    echo "Deployment timestamp: $(date)"
  EOF
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  tags = {
    Name = "lti-recruiter-frontend"
    ForceRecreate = "true"
  }
  
  depends_on = [aws_instance.backend] # Assicurarsi che il backend sia creato prima
}
