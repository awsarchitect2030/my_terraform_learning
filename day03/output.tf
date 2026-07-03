output "aws_instance" {
    description = "AMI of instance"
    value = aws_instance.example[*].ami
}