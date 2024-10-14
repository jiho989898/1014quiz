terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.13.1"
        }
    }
}


# aws 에 접속하기 위한 정보를 추가해야 한다. (aws configure 로 입력했던 내용들)
provider "aws" {
    region = "ap-northeast-1"
}
