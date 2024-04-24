provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "machinelearningbucket-1234"
  acl    = "private"
}

resource "aws_iam_role" "role" {
  name = "Dazd"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "profile" {
  name = "Dazd"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "policy" {
  name = "MachineLearningPolicy"
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.bucket.arn}"
    }
  ]
}
EOF
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "Machine-Learning-Pipeline"
  description = "My application"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name        = "Machine-Learning-Pipeline-env"
  application = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.1 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.profile.name
  }
}