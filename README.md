# StartTech Full-Stack Application

## Architecture Overview
This repository contains a full-stack application with:
- **Frontend**: React application hosted on S3 with CloudFront CDN
- **Backend**: Golang API running on EC2 instances with Auto Scaling
- **Database**: MongoDB Atlas for data persistence
- **Cache**: ElastiCache Redis cluster for caching and sessions
- **Infrastructure**: Managed with Terraform and deployed via GitHub Actions

## Prerequisites
- AWS Account with appropriate permissions
- GitHub repository with Actions enabled
- Terraform 1.3.0 or higher
- Node.js 18.x
- Go 1.20.x
- Docker

## Setup Instructions
1. **Clone the repositories**
   ```bash
   git clone https://github.com/starttech/starttech-infra.git
   git clone https://github.com/starttech/starttech-application.git
   ```

2. **Configure AWS Credentials**
   Set up AWS credentials as GitHub secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

3. **Configure Application Secrets**
   Add the following secrets to your GitHub repository:
   - `MONGO_URI`: MongoDB Atlas connection string
   - `REACT_APP_API_URL`: Frontend API endpoint
   - `SLACK_WEBHOOK`: Slack webhook for notifications

4. **Deploy Infrastructure**
   ```bash
   cd starttech-infra
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform.tfvars with your values
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

5. **Deploy Applications**
   The CI/CD pipelines will automatically deploy on push to main branch.

## Repository Structure

### Infrastructure (`starttech-infra/`)
- `terraform/`: Infrastructure as Code using Terraform
- `.github/workflows/`: GitHub Actions workflows
- `scripts/`: Deployment and management scripts
- `monitoring/`: CloudWatch dashboards and alarms

### Application (`starttech-application/`)
- `frontend/`: React application
- `backend/`: Golang API
- `.github/workflows/`: CI/CD pipelines
- `scripts/`: Application deployment scripts

## CI/CD Pipelines

### Frontend Pipeline
1. **Test**: Lint, unit tests, security audit
2. **Build**: Create production bundle
3. **Deploy**: Upload to S3, invalidate CloudFront cache

### Backend Pipeline
1. **Test**: Lint, unit tests, security scan
2. **Build**: Build Docker image, security scan
3. **Deploy**: Update ASG, rolling deployment, smoke tests

### Infrastructure Pipeline
1. **Plan**: Terraform plan for review
2. **Apply**: Deploy infrastructure changes
3. **Update**: Update environment variables

## Monitoring

### CloudWatch Dashboards
- Application metrics (requests, response time, errors)
- Infrastructure metrics (CPU, memory, network)
- Database and cache metrics
- Application logs

### Alarms
- High CPU utilization (>80%)
- High response time (>500ms)
- 5XX errors (>1% of requests)
- Instance health checks

## Security

### IAM Policies
- Least privilege access for EC2 instances
- S3 bucket policies for CloudFront access
- ECR access for Docker images

### Security Scanning
- npm audit for frontend dependencies
- gosec for Go code analysis
- Trivy for Docker image scanning

### Network Security
- Security groups with minimum required access
- VPC with public and private subnets
- NAT gateways for outbound traffic

## Operations

### Health Checks
```bash
# Check application health
./scripts/health-check.sh <alb-dns-name>

# Check infrastructure status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name starttech-backend-asg

# View logs
aws logs tail /aws/ec2/starttech-backend --follow
```

### Rollback Procedures
```bash
# Frontend rollback
aws s3 sync s3://starttech-frontend-backup/current/ s3://starttech-frontend/ --delete

# Backend rollback
./scripts/rollback.sh <previous-image-tag>
```

## Troubleshooting

Common issues and solutions are documented in `RUNBOOK.md`.

## Support

For issues or questions:
1. Check the troubleshooting guide
2. Review CloudWatch logs
3. Contact the DevOps team
```

## Key Features Implemented

### 1. **Infrastructure as Code**
- Modular Terraform configuration
- Auto Scaling Groups with scaling policies
- Application Load Balancer with health checks
- S3 bucket with CloudFront CDN
- ElastiCache Redis cluster
- Comprehensive security groups

### 2. **CI/CD Pipelines**
- GitHub Actions workflows for frontend, backend, and infrastructure
- Automated testing and security scanning
- Docker image building and vulnerability scanning
- Rolling deployments with health checks
- CloudFront cache invalidation

### 3. **Monitoring and Observability**
- CloudWatch dashboards for all components
- Application logging to CloudWatch Logs
- Performance metrics and alarms
- Health check endpoints

### 4. **Security Best Practices**
- IAM roles with least privilege
- Security group minimum access
- Automated vulnerability scanning
- Secrets management via GitHub Secrets
- Encrypted S3 buckets and EBS volumes

### 5. **High Availability**
- Multi-AZ deployment
- Auto Scaling with health checks
- Load balancer with target groups
- Redis cluster with multiple nodes

This implementation provides a production-ready CI/CD pipeline that automates the entire deployment process while maintaining security, reliability, and scalability best practices.