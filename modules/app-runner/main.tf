terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "apprunner_role" {
  name = "apprunner-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : [
            "build.apprunner.amazonaws.com",
            "tasks.apprunner.amazonaws.com"
          ]
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_policy_attachment" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}


resource "aws_apprunner_service" "apprunner_service" {
  service_name = var.apprunner_service_name

  source_configuration {
    image_repository {
      image_configuration {
        port = var.image_port
      }
      image_identifier      = "${var.image_repository}:${var.image_tag}"
      image_repository_type = var.repository_type
    }
    auto_deployments_enabled = false
    /*
    # Needed if the image_repository_type is ECR
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    */
  }
}
