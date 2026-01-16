# Create Public Security Group (for resources in public subnets)
resource "aws_security_group" "alb_sg" {
    name        = "${var.project_name}-alb-sg"
    description = "Security group for application load balancer"
    vpc_id      = var.vpc_id

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

# Create Instance Security Group
resource "aws_security_group" "instance_sg" {
    name        = "${var.project_name}-instance-sg"
    description = "Security group for instances"
    vpc_id      = var.vpc_id

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

# Create redis security group
resource "aws_security_group" "redis" {
    name        = "${var.project_name}-redis-sg"
    description = "Security group for redis"
    vpc_id      = var.vpc_id

    # Allow TCP from instance security group only
    ingress {
        from_port       = 6379
        to_port         = 6379
        protocol        = "tcp"
        security_groups = [aws_security_group.instance_sg.id]
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
        Name = "${var.project_name}-redis-sg"
        ManagedBy = "terraform"
    }
}
