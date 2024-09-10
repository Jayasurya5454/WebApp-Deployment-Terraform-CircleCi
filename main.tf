provider "aws" {
  region = "us-east-1"  
}


terraform {
  backend "s3" {
    bucket = "tf-rp-states"
    key    = "jayasurya/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "reactClient_sg"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "ReactQuotes" {
  ami                    = "ami-08a0d1e16fc3f61ea"  
  instance_type          = "t2.micro"
  key_name               = "jaya"  
  security_groups        = [aws_security_group.instance_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo docker run -d -p 80:80 jayasurya5454/quotes
              EOF

  tags = {
    Name = "example-instance"
  }
}

output "public_ip" {
  value = aws_instance.ReactQuotes.public_ip
}


