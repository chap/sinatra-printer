locals {
    foo = "bar"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                      = "sinatra-printer-sqs"
}