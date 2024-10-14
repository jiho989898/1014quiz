resource "aws_instance" "ansible_server" {
    ami = "ami-0ac6b9b2908f3e20d"
    instance_type = "t2.micro"
    key_name = "testkey1"
    subnet_id = aws_subnet.example_subnet_1a.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.mgmtsg.id]


    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install ansible -y
        EOF
   
    tags = {
        Name = "ansible_server"
    }


    lifecycle {
        create_before_destroy = true
    }

}

resource "terraform_data" "pri_key" {
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("/home/user1/testkey1.pem")}"
        host = aws_instance.ansible_server.public_ip
    }

    provisioner "file" {
        source = "/home/user1/testkey1.pem"
        destination = "/home/ubuntu/testkey1.pem"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod 600 /home/ubuntu/testkey1.pem"
        ]
    }

    triggers_replace = [
        aws_instance.ansible_server.public_ip
    ]
}

resource "aws_instance" "web" {
    ami = "ami-0ac6b9b2908f3e20d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.example_subnet_1b.id
    key_name = "testkey1"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.websg.id]
    count = 2


    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install -y nginx
        sudo systemctl start nginx
        EOF
   
    tags = {
        Name = "terraform-${count.index}"
    }


    lifecycle {
        create_before_destroy = true
    }
}
resource "time_sleep" "wai2" {
  create_duration = "30s"
}
