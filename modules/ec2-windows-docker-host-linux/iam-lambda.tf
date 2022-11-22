resource "aws_iam_role" "lambda_role" {
  name               = "LambdaEC2Managment_Role"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow"
                
            }
        ]
    }
    EOF
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "LambdaEC2Managment_Policy"
  path        = "/"
  description = "IAM Polic for Lmabda function to manage EC2 instances"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeTags",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn

}


resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Allow lambda communication"

  vpc_id = data.aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Egress all"
  }
}