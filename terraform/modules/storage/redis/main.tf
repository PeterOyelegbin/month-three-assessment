resource "aws_elasticache_subnet_group" "redis" {
    name       = "${var.project_name}-redis-sg"
    subnet_ids = var.private_subnet_ids

    tags = {
        Name      = "${var.project_name}-redis-sg"
        ManagedBy = "terraform"
    }
}

resource "aws_elasticache_replication_group" "redis" {
    replication_group_id          = "${var.project_name}-redis"
    description                   = "Redis for ${var.project_name}"
    engine                        = "redis"
    engine_version                = var.redis_engine_version
    node_type                     = var.redis_node_type
    parameter_group_name          = "default.redis7"
    port                          = 6379

    num_node_groups               = var.redis_num_node_grps
    replicas_per_node_group       = var.redis_replicas_per_node_grp

    automatic_failover_enabled    = true
    multi_az_enabled              = true

    subnet_group_name             = aws_elasticache_subnet_group.redis.name
    security_group_ids            = [var.redis_sg_id]

    at_rest_encryption_enabled    = true
    transit_encryption_enabled    = false

    snapshot_retention_limit      = var.redis_snapshot_retention_limit
    snapshot_window               = var.redis_snapshot_window

    maintenance_window            = var.redis_maintenance_window
    apply_immediately             = true

    log_delivery_configuration {
        destination      = var.cloudwatch_log_grp_name
        destination_type = "cloudwatch-logs"
        log_format       = "text"
        log_type         = "slow-log"
    }

    tags = {
        Name      = "${var.project_name}-redis"
        ManagedBy = "terraform"
    }
}
