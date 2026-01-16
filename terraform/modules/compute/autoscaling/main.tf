# data "aws_ami" "ubuntu" {
#     most_recent = true
#     owners      = ["099720109477"] # Canonical
#     filter {
#         name   = "name"
#         values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#     }

#     filter {
#         name   = "virtualization-type"
#         values = ["hvm"]
#     }
# }

data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"] # Amazon Linux 2

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_launch_template" "instance" {
    name_prefix   = "${var.project_name}-amazon-instance"
    image_id      = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type

    iam_instance_profile {
        name = var.instance_profile_name
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups             = [var.instance_sg_id]
    }

    # user_data = base64encode(file("${path.module}/userdata.sh"))
    user_data = base64encode(
        templatefile(
            "${path.module}/userdata.sh",
            {LOG_GROUP_NAME = "/aws/ec2/instance"}
        )
    )

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "${var.project_name}-instance-temp"
            ManagedBy = "terraform"
        }
    }
}

resource "aws_autoscaling_group" "auto-scaling" {
    name                      = var.project_name
    desired_capacity          = var.desired_capacity
    max_size                  = var.max_size
    min_size                  = var.min_size
    vpc_zone_identifier       = var.private_subnet_ids
    health_check_type         = "ELB"
    health_check_grace_period = 300

    target_group_arns = [var.target_group_arn]

    launch_template {
        id      = aws_launch_template.instance.id
        version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "${var.project_name}-asg-instance"
        propagate_at_launch = true
    }
}

# Data source to get instance information from the ASG
data "aws_instances" "asg_instances" {
    instance_tags = {
        "aws:autoscaling:groupName" = aws_autoscaling_group.auto-scaling.name
    }
    
    depends_on = [
        aws_autoscaling_group.auto-scaling
    ]
}
