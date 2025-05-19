resource "aws_instance" "WebServer1" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.nw-interface1.id
    device_index         = 0
  }

  key_name = "my-ec2-key"

  tags = {
    Name = "WebServer1"
  }
}

# for key create using below command
# aws ec2 create-key-pair --key-name my-ec2-key --query 'KeyMaterial' --output text > /root/my-ec2-key.pem
# chmod 600 /root/my-ec2-key.pem

resource "aws_instance" "WebServer2" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.nw-interface2.id
    device_index         = 0
  }

  key_name = "my-ec2-key"

  tags = {
    Name = "WebServer2"
  }
}

output "instance1_id" {
  value = aws_instance.WebServer1.id
}

output "instance2_id" {
  value = aws_instance.WebServer2.id
}



