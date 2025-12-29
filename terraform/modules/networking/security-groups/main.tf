# Create Public Security Group (for resources in public subnets)
resource "aws_security_group" "alb_sg" {
    name        = "${var.project_name}-alb-sg"
    description = "Security group for application load balancer"
    vpc_id      = var.vpc_id

    # Allow SSH from anywhere (restrict in production)
    ingress {
        description = "SSH from bastion hosts"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow HTTP from anywhere
    ingress {
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow HTTPS from anywhere
    ingress {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-alb-sg"
        ManagedBy = "terraform"
    }
}

# Create Private Security Group (for resources in private subnets)
resource "aws_security_group" "instance_sg" {
    name        = "${var.project_name}-instance-sg"
    description = "Security group for instance in private subnets"
    vpc_id      = var.vpc_id

    # Allow SSH from alb security group only
    ingress {
        description     = "SSH from alb instances"
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    # Allow HTTP from alb security group only
    ingress {
        description     = "HTTP from alb instances"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    # Allow all traffic within the private security group
    ingress {
        description = "All traffic within private SG"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        self        = true
    }

    # Allow all outbound traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-instance-sg"
        ManagedBy = "terraform"
    }
}
