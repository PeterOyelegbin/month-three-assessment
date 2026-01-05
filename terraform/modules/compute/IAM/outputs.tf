output "instance_profile_name" {
    description = "Instance profile name"
  value = aws_iam_instance_profile.instance.name
}
