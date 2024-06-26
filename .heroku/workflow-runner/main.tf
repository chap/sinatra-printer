locals {
  cluster_name = "shared-services-18498"
  repo_name = "chap/sinatra-printer"
}

terraform {
    backend "s3"{
        bucket = "tofu-statesb-shared-services-18498"
        key    = "chap/sinatra-printer/.heroku/workflow-runner/tofu_state.json"
        # region = "{{.BackendS3Region}}"
        # dynamodb_table = "{{.BackendDynamoDbTable}}"
        # profile = "backend"
    }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                      = "sinatra-printer-sqs"
}