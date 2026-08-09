resource "aws_elastic_beanstalk_application" "ebstest" {
  name        = "ebs-test-name"
  description = "ebs-test-name"
}

resource "aws_elastic_beanstalk_environment" "ebsenv" {
  name                = "ebcenv-name"
  application         = aws_elastic_beanstalk_application.ebstest.name
  solution_stack_name = "64bit Amazon Linux 2023 v6.11.5 running Node.js 24"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ebs_test_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.ebs_service_role.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "8080"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT"
    value     = "blue"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "VERSION"
    value     = "1.0"
  }

  # Deployment Policy
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }
}

resource "aws_s3_bucket" "default" {
  bucket = "ebstest.applicationversion.bucket"
}

resource "aws_s3_object" "default" {
  bucket = aws_s3_bucket.default.id
  key    = "app-v1/app-v1.zip"
  source = "${path.module}/app-v1/app-v1.zip"
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "ebs-test-version-label"
  application = "ebs-test-name"
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.default.id
  key         = aws_s3_object.default.key
}

   