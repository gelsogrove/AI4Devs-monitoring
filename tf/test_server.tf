resource "aws_instance" "test_server" {
  ami                    = "ami-09f4814ae750baed6"  # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  
  # Script di user data molto semplice che crea solo un server HTTP base
  user_data = <<-EOF
    #!/bin/bash
    # Update system
    yum update -y
    # Install required packages
    yum install -y httpd

    # Create a simple HTML page
    cat > /var/www/html/index.html << 'HTMLCONTENT'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test Server</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            h1 { color: #333; }
            .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Test Server</h1>
            <p>This is a simple test page to verify HTTP server functionality</p>
            <p>Server timestamp: $(date)</p>
        </div>
    </body>
    </html>
    HTMLCONTENT

    # Start the web server and enable it to start at boot time
    systemctl start httpd
    systemctl enable httpd
    
    # Configure firewall to allow HTTP traffic
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
  EOF
  
  tags = {
    Name = "test-server"
  }
}

# Output for test server
output "test_server_ip" {
  value       = aws_instance.test_server.public_ip
  description = "The public IP of the test server"
}

output "test_server_url" {
  value       = "http://${aws_instance.test_server.public_ip}"
  description = "The URL to access the test server"
} 