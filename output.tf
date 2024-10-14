data "aws_instances" "public" {

  filter {
    name   = "instance-state-name"
    values = ["running"]   # 실행 중인 인스턴스만 필터링

    }
  depends_on = [
    aws_instance.ansible_server,
    aws_instance.web[0],
    aws_instance.web[1]
  ]

}
resource "time_sleep" "wait" {
  create_duration = "30s"
}

data "aws_instances" "private" {

  filter {
    name   = "instance-state-name"
    values = ["running"]   # 실행 중인 인스턴스만 필터링
  }

  depends_on = [
    aws_instance.ansible_server,
    aws_instance.web[0],
    aws_instance.web[1]
  ]
}

output "public_ips" {
  value = ["public = ","${data.aws_instances.public.public_ips}", "private = ","${data.aws_instances.private.private_ips}"]

  depends_on = [
    aws_instance.ansible_server,
    aws_instance.web[0],
    aws_instance.web[1]
  ]
}


resource "local_file" "example_file" {
  filename = "${path.module}/hosts"
  
  # 리스트 요소들이 문자열이어야 하며, join으로 연결
  content  = "\n ${join("\n", data.aws_instances.public.public_ips)}"
}

# web파일 넣기


resource "time_sleep" "wait3" {
  create_duration = "30s"
}

resource "terraform_data" "web" {
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/home/user1/testkey1.pem")}"
    host = aws_instance.ansible_server.public_ip
  }


  provisioner "file" {
    source = "${path.module}/hosts"
    destination = "/home/ubuntu/hosts"

    connection {
        sudo = true
    }
  }

  triggers_replace = [
    aws_instance.ansible_server.public_ip
  ]

}


