data "archive_file" "lambda_zip_file_int" {
  type        = "zip"
  output_path = "/tmp/docker_host_mgmt.zip"
  source {
    content  = file("${path.module}/assets/lambda_function.py")
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "docker_host_mgmt" {
  filename                       = data.archive_file.lambda_zip_file_int.output_path
  source_code_hash               = data.archive_file.lambda_zip_file_int.output_base64sha256
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.9"
  function_name                  = "docker_host_mgmt_lambda"
  reserved_concurrent_executions = 10
  vpc_config {
    subnet_ids         = data.aws_subnets.private_subnets.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tracing_config {
    mode = "Active"
  }

}

resource "aws_cloudwatch_event_rule" "ec2_state_changed" {
  name = "capture-ec2-state-changed-events"

  event_pattern = <<PATTERN
        {
            "source": [
                "aws.ec2"
            ],
            "detail-type": [
                "EC2 Instance State-change Notification"
            ],
            "detail": {
                "state": [      
                    "stopped",
                    "running"  
                ]
            }
        }
    PATTERN
}

resource "aws_cloudwatch_event_target" "ec2_mgmt_lambda_target" {
  arn  = aws_lambda_function.docker_host_mgmt.arn
  rule = aws_cloudwatch_event_rule.ec2_state_changed.name
}

resource "aws_lambda_permission" "allow_to_call_docker_host_mgmt_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.docker_host_mgmt.function_name
  source_arn    = aws_cloudwatch_event_rule.ec2_state_changed.arn
}
