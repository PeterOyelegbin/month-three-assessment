# Create instance role
resource "aws_iam_role" "instance" {
    name = "${var.project_name}-instance-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# Attache policy to IAM role
resource "aws_iam_role_policy_attachment" "ssm" {
    role       = aws_iam_role.instance.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile
resource "aws_iam_instance_profile" "instance" {
    name = "${var.project_name}-ec2-instance-profile"
    role = aws_iam_role.instance.name
}
