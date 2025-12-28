data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] # Canonical
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

# Generate RSA key pair
resource "tls_private_key" "key_pair" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "generated_key" {
    key_name   = "${var.project_name}-key"
    public_key = tls_private_key.key_pair.public_key_openssh
    # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"

    tags = {
        Name = "${var.project_name}-key"
        ManagedBy = "terraform"
    }
}

# Save private key to local file
resource "local_file" "private_key" {
  content  = tls_private_key.key_pair.private_key_pem
  filename = "${path.root}/${aws_key_pair.generated_key.key_name}.pem"
  file_permission = "0400"
}

resource "aws_launch_template" "instance" {
    name_prefix   = "${var.project_name}-"
    image_id      = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name      = aws_key_pair.generated_key.key_name
    # iam_instance_profile {
    #     name = aws_iam_instance_profile.backend.name
    # }

    network_interfaces {
        associate_public_ip_address = false
        security_groups             = [var.instance_sg_id]
    }

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "${var.project_name}-instance"
            ManagedBy   = "terraform"
        }
    }
}

resource "aws_autoscaling_group" "auto-scaling" {
    availability_zones = var.availability_zones
    desired_capacity   = var.desired_capacity
    max_size           = var.max_size
    min_size           = var.min_size

    launch_template {
        id      = aws_launch_template.instance.id
        version = "$Latest"
    }
}
