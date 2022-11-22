resource "aws_iam_role" "ec2admin" {
  name = "ec2admin_role"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-ec2admin" {
  role       = aws_iam_role.ec2admin.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secretsmanager-ec2admin" {
  role       = aws_iam_role.ec2admin.id
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_instance_profile" "ec2admin" {
  name = "ec2admin"
  role = aws_iam_role.ec2admin.name
}