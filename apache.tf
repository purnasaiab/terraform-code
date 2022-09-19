resource "aws_security_group" "apache" {
  name        = "allow_tls"
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
    from_port        = 80
    to_port          = 80
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
    Name = "apache_sg"
  }
}

resource "aws_instance" "apache" {
  ami           = "ami-0aca10934d525a6f0"
  instance_type = "t2.micro"
  subnet_id = "subnet-023b24123d4e51578"
  vpc_security_group_ids = [aws_security_group.apache.id]
  key_name =aws_key_pair.my-key.id
user_data = <<EOF
#!/bin/bash
 yum update -y
 yum install httpd -y
	systemctl start httpd
	systemctl enable httpd

EOF  
  
    tags = {
    Name = "apache"
  }
}