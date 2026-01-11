resource "aws_lb" "alb" {
    name               = "${var.project_name}-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [var.alb_sg_id]
    subnets            = var.public_subnet_ids

    enable_deletion_protection = false

    # access_logs {
    #     bucket  = var.logs_bucket
    #     prefix  = "alb"
    #     enabled = true
    # }

    tags = {
        Name        = "${var.project_name}-alb"
        ManagedBy   = "terraform"
    }
}

resource "aws_lb_target_group" "target-group" {
    name     = "${var.project_name}-tg"
    port     = 80 # return to 8080 according to system requirements
    protocol = "HTTP"
    vpc_id   = var.vpc_id

    health_check {
        enabled             = true
        interval            = 60
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 10
        healthy_threshold   = 3
        unhealthy_threshold = 5
        matcher             = "200"
    }

    stickiness {
        type            = "lb_cookie"
        cookie_duration = 86400
        enabled         = true
    }

    tags = {
        Name        = "${var.project_name}-tg"
        ManagedBy   = "terraform"
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.target-group.arn
    }
}
