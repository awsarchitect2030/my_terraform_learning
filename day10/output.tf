output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "User_list" {
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}

output "password" {

  value = {
    for user, profile in aws_iam_user_login_profile.user_profile : user => "Password created - please reset on first login"
  }
  sensitive = true

}

output "job_titles" {
  value = [
    for user in aws_iam_user.users : {
      name     = user.name
      JobTitle = lookup(user.tags, "JobTitle", "")
    }
  ]
}