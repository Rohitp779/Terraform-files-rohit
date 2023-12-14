provider "aws" {
  region     = var.region
  access_key = var.acckey
  secret_key = var.seckey
}

resource "aws_instance" "terraform_way" {
  ami                     = "ami-018ba43095ff50d08"
  instance_type           = "t2.micro"
   
tags = {
    Name = "terraform_way"
  }
}

resource "aws_eip"  "terraform_eip"{
instance= "${aws_instance.terraform_way.id}"
}

output "pri_ip" {
value= "${aws_instance.terraform_way.private_ip}"
}

