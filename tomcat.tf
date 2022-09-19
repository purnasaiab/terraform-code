resource "aws_security_group" "tomcat-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-072cff08f352ca983"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "tomcat_sg"
  }
}

resource "aws_instance" "tomcat" {
  ami                    = "ami-0aca10934d525a6f0"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-023b24123d4e51578"
  vpc_security_group_ids = [aws_security_group.tomcat-sg.id]
  key_name               = aws_key_pair.my-key.id
  user_data              = <<EOF
#!/bin/bash
yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
cd /opt
wget -O /opt/apache-tomcat-9.0.65-windows-x64.zip https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65-windows-x64.zip
unzip apache-tomcat-9.0.65-windows-x64.zip
mv apache-tomcat-9.0.65 tomcat9
rm -fr apache-tomcat-9.0.65-windows-x64.zip
cd tomcat9/
cd bin
chmod 755 *.sh
./startup.sh
# cd /tmp
# wget https://www.oracle.com/webfolder/technetwork/tutorials/obe/fmw/wls/10g/r3/cluster/session_state/files/shoppingcart.zip
# unzip shoppingcart.zip
# cp shoppingcart.war /opt/tomcat9/webapps

EOF  

  tags = {
    Name = "tomcat"
  }
}