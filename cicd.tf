resource "aws_security_group" "cicd" {
  name        = "cicd-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-072cff08f352ca983"

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
   ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cicd"
  }
}

resource "aws_instance" "cicd" {
  ami           = "ami-0aca10934d525a6f0"
  instance_type = "c5.large"
  subnet_id = "subnet-023b24123d4e51578"
  vpc_security_group_ids = [aws_security_group.cicd.id]
  key_name =aws_key_pair.my-key.id
  user_data = <<EOF
#!/bin/bash
 wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum upgrade -y
    amazon-linux-extras install java-openjdk11
    yum install jenkins -y
    systemctl start jenkins
    systemctl enable jenkins


EOF  
  

  
  tags = {
    Name = "cicd"
  }
}