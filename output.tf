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

data "aws_instances" "public_web" {

  filter {
    name   = "instance-state-name"
    values = ["running"]

    }
  depends_on = [
    aws_instance.ansible_server,
    aws_instance.web[0],
    aws_instance.web[1]
  ]

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

locals {
  # 'terraform-' 으로 시작하는 이름의 인스턴스들의 퍼블릭 IP를 가져옴
  terraform_instances_public_ips = [
    for instance in data.aws_instances.all_running.instances :
    aws_instance.public_ip
    if contains(in stance.tags["Name"], "terraform-")
  ]
}

resource "local_file" "example_file" {
  filename = "${path.module}/web"
  
  # 리스트 요소들이 문자열이어야 하며, join으로 연결
  content  = "[web] \n ${join("\n", terraform_instances_public_ips)}"
}

# web파일 넣기



resource "terraform_data" "web" {
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/home/user1/testkey1.pem")}"
    host = aws_instance.ansible_server.public_ip
  }

    provisioner "file" {
        source = "${path.module}/web"
        destination = "/home/ubuntu/web"

    }

    provisioner "remote-exec" {
        inline = [
            "sudo mv /home/ubuntu/web /etc/ansible/hosts"
        ]
    }



  triggers_replace = [
    aws_instance.ansible_server.public_ip
  ]

  depends_on = [
    aws_instance.ansible_server,
    aws_instance.web[0],
    aws_instance.web[1]
  ]

}


