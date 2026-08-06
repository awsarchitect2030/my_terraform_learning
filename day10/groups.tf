resource "aws_iam_group" "education" {
  name = "Education"
  path = "/group/"
}

resource "aws_iam_group" "sales" {
  name = "Sales"
  path = "/group/"
}

resource "aws_iam_group" "hr" {
  name = "HR"
  path = "/group/"
}

resource "aws_iam_group_membership" "education_team" {
  name  = "education-group-membership"
  users = [for user in aws_iam_user.users : user.name if user.tags.department == "Education"]
  group = aws_iam_group.education.name
}

resource "aws_iam_group_membership" "sales_team" {
  name  = "sales-group-membership"
  users = [for user in aws_iam_user.users : user.name if user.tags.department == "Sales"]
  group = aws_iam_group.sales.name
}

resource "aws_iam_group_membership" "hr_team" {
  name = "hr-group-membership"
  # users = [ for user in aws_iam_user.users : user.name if contains(keys(user.tags), "JobTitle") && can(regex("HR|Assistant", user.tags.JobTitle))]
  users = [
    for user in aws_iam_user.users :
    user.name
    if can(regex("HR|Assistant", user.tags.JobTitle))
  ]
  group = aws_iam_group.hr.name
}