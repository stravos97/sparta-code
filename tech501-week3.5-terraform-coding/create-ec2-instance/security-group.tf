# Create a new security group
resource "aws_security_group" "app_sg" {
  name   = var.security_group_name
  vpc_id = data.aws_vpc.default.id

  # Inbound rule: allow SSH access from any IP
  ingress {
    description = "Allow SSH from any IP"
    from_port   = 22
    to_port     = 22
    protocol    = var.protocol
    cidr_blocks = [var.public_access_cidr] # Allow SSH access from any IP
  }

  # Inbound rule: allow ICMP (ping) from any IP
  ingress {
    description = "Allow ICMP (ping) from any IP"
    from_port   = -1 # ICMP type
    to_port     = -1 # ICMP code
    protocol    = "icmp"
    cidr_blocks = [var.public_access_cidr] # Allow ping from any IP
  }

  # Inbound rule: allow internal SSH access within VPC
  ingress {
    description = "Allow internal SSH"
    from_port   = 22
    to_port     = 22
    protocol    = var.protocol
    cidr_blocks = ["172.31.0.0/16"] # VPC CIDR
  }

  # Inbound rule: allow HTTP access
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = var.protocol
    cidr_blocks = [var.public_access_cidr]
  }

  # Inbound rule: allow Node.js app traffic on port 3000
  ingress {
    description = "Allow inbound Node.js traffic"
    from_port   = 3000
    to_port     = 3000
    protocol    = var.protocol
    cidr_blocks = [var.public_access_cidr] # Open for external connections
  }

  # Inbound rule: allow MongoDB traffic
  ingress {
    description = "Allow MongoDB traffic"
    from_port   = 27017
    to_port     = 27017
    protocol    = var.protocol
    cidr_blocks = [var.public_access_cidr] # Allow MongoDB connections
  }

  # Inbound rule: allow Kubernetes Dashboard access on port 8001
  ingress {
    description = "Allow Kubernetes Dashboard access"
    from_port   = 8001
    to_port     = 8001
    protocol    = var.protocol
    cidr_blocks = [var.public_access_cidr] # Allow dashboard access from any IP
  }

  # Outbound rule: allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_access_cidr]
  }
}
