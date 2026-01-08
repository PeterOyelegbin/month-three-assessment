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

# Generate RSA key pair
resource "tls_private_key" "key_pair" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "generated_key" {
    key_name   = "${var.project_name}-key"
    public_key = tls_private_key.key_pair.public_key_openssh
    
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
    name_prefix   = "${var.project_name}-amazon-instance"
    image_id      = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    key_name      = aws_key_pair.generated_key.key_name

    iam_instance_profile {
        name = var.instance_profile_name
    }

    network_interfaces {
        associate_public_ip_address = true # Set to false if on private subnet
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
    vpc_zone_identifier       = var.public_subnet_ids
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
