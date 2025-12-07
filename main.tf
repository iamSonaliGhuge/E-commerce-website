terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------- EC2 Security Group ----------
resource "aws_security_group" "ec2_sg" {
  name        = "springboot-ec2-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
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

# ---------- RDS Security Group ----------
resource "aws_security_group" "rds_sg" {
  name        = "springboot-rds-sg"
  description = "Allow MySQL from EC2"

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- RDS MySQL ----------
resource "aws_db_instance" "spring_db" {
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  identifier           = "springboot-db"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# ---------- EC2 Instance ----------
resource "aws_instance" "spring_app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y openjdk-11-jre git

    mkdir -p /opt/app
    chown ubuntu:ubuntu /opt/app

    cat <<EOT > /etc/systemd/system/springapp.service
    [Unit]
    Description=Spring Boot Application
    After=network.target

    [Service]
    User=ubuntu
    WorkingDirectory=/opt/app
    ExecStart=/usr/bin/java -jar /opt/app/app.jar
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    EOT

    systemctl daemon-reload
    systemctl enable springapp
  EOF

  tags = {
    Name = "springboot-ec2"
  }
}

# ---------- (Optional) S3 ----------
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.artifact_bucket_name
}
