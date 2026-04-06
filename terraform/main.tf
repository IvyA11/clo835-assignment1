provider "aws" {
  region = "us-east-1"
}

# 1. ECR Repositories
resource "aws_ecr_repository" "webapp" {
  name         = "webapp-repo"
  force_delete = true
}

resource "aws_ecr_repository" "mysql" {
  name         = "mysql-repo"
  force_delete = true
}

# 2. IAM Role for EC2-to-ECR Access
resource "aws_iam_role" "ecr_role" {
  name = "ec2_ecr_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_ecr_profile"
  role = aws_iam_role.ecr_role.name
}

# 3. Security Group
resource "aws_security_group" "app_sg" {
  name        = "clo835_assignment1_sg"
  description = "Allow SSH and App Ports"

  ingress {
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-0c101f26f147fa7fd" # Amazon Linux 2023
  instance_type          = "t2.micro"
  key_name               = "vkey" # Ensure this exists in your AWS Console!
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = { Name = "Assignment1-Server" }
}

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

# Proof of branch protection test