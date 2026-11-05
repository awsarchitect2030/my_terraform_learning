resource "aws_iam_role" "backend_ec2_iam_role" {
  name = "backend_ec2_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "EC2AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "backend_ec2_iam_role"
  }
}

resource "aws_iam_policy" "secret_manager_policy" {
  name = "secret_manager_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = aws_db_instance.postgres_instance.master_user_secret[0].secret_arn
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "secret_manager_db_iam_attachment" {
  role       = aws_iam_role.backend_ec2_iam_role.name
  policy_arn = aws_iam_policy.secret_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_ec2_iam_attachment" {
  role       = aws_iam_role.backend_ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "iam_instance_profile"
  role = aws_iam_role.backend_ec2_iam_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.backend_ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}