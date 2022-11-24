# Create IAM roles

resource "aws_iam_role" "websrv" {
  name        = format("%s%s%s%s", var.customer_code, "iar", var.environment_code, "websrv")
  description = "IAM role for webserver to access S3 hosted web files"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    name         = format("%s%s%s%s", var.customer_code, "iar", var.environment_code, "websrv")
    resourcetype = "identity"
    codeblock    = "codeblock04"
  }
}

resource "aws_iam_role_policy" "websrvs3" {
  name = format("%s%s%s%s", var.customer_code, "irp", var.environment_code, "websrvs3")
  role = aws_iam_role.websrv.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.websrv.arn}",
          "${aws_s3_bucket.websrv.arn}/*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "websrvs3ec2describe" {
  name = format("%s%s%s%s", var.customer_code, "irp", var.environment_code, "websrvs3ec2describe")
  role = aws_iam_role.websrv.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "websrvs3secrets" {
  name = format("%s%s%s%s", var.customer_code, "irp", var.environment_code, "websrvs3secrets")
  role = aws_iam_role.websrv.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "websrvssm" {
  role       = aws_iam_role.appsrv.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "websrvmmad" {
  role       = aws_iam_role.appsrv.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_instance_profile" "websrv" {
  name = format("%s%s%s%s", var.customer_code, "iap", var.environment_code, "websrv")
  role = aws_iam_role.websrv.name

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "iap", var.environment_code, "websrv")
    resourcetype = "identity"
    codeblock    = "codeblock04"
  }
}
