resource "aws_vpc" "example" {
    cidr_block = "172.18.0.0/16"


    tags = {
        Name = "terraform_vpc1"
    }
}


resource "aws_subnet" "example_subnet_1a" {
    vpc_id = aws_vpc.example.id
    cidr_block = "172.18.1.0/24"
    availability_zone = "ap-northeast-1a"
# 어느 zone 에 배치되는가? 
}


resource "aws_subnet" "example_subnet_1b" {
    vpc_id = aws_vpc.example.id
    cidr_block = "172.18.2.0/24"
    availability_zone = "ap-northeast-1a"
}


resource "aws_subnet" "example_subnet_1c" {
    vpc_id = aws_vpc.example.id
    cidr_block = "172.18.3.0/24"
    availability_zone = "ap-northeast-1c"

}

resource "aws_internet_gateway" "example_igw" {
    vpc_id = aws_vpc.example.id
}



resource "aws_route_table" "example_rt" {
    vpc_id = aws_vpc.example.id


    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.example_igw.id
    }
}

resource "aws_route_table_association" "example_subnet_1a_association" {
    subnet_id = aws_subnet.example_subnet_1a.id
    route_table_id = aws_route_table.example_rt.id
}

resource "aws_route_table_association" "example_subnet_1b_association" {
    subnet_id = aws_subnet.example_subnet_1b.id
    route_table_id = aws_route_table.example_rt.id
}



