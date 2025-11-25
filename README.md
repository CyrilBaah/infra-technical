# Deploying a Containerised API on AWS ECS Using Terraform via Github Actions

## Solution Overview

This repository contains a containerized API built with fast api. The solution demonstrates clean, reproducible infrastructure using Terraform and automated deployment via GitHub Actions.

### Architecture
- **FastAPI** containerized application
- **AWS ECS Fargate** for serverless container hosting
- **Application Load Balancer** for public access
- **Amazon ECR** for container registry
- **Terraform** for Infrastructure as Code
- **GitHub Actions** with OIDC authentication for CI/CD

## 🚀 Setup and Deploy Instructions

### Step 1: Configure GitHub Secrets
Add these secrets to your GitHub repository:
```
AWS_ACCESS_KEY_ID     # Your AWS access key (temporary, for bootstrap only)
AWS_SECRET_ACCESS_KEY # Your AWS secret key (temporary, for bootstrap only)
AWS_REGION           # You preferred AWS Region
AWS_ACCOUNT_ID       # Your 12-digit AWS account ID
```

### Step 2: Bootstrap Infrastructure
1. Navigate to **Actions** → **Bootstrap Infrastructure**
2. Click "Run workflow"
3. Enter `bootstrap` in the confirmation field
4. Wait for completion
5. **Important**: Remove `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets after bootstrap

### Step 3: Deploy Infrastructure
1. Navigate to **Actions** → **Create Infrastructure**
2. Click "Run workflow"
3. Enter `create` in the confirmation field
4. Wait for completion and note the Load Balancer URL in the output

### Step 4: Deploy Application
```bash
# Create and push a git tag to trigger deployment
git tag v1.0.0
git push origin v1.0.0
```

## 🌐 Endpoint URL

After successful deployment, your API will be available at:
```
https://hello-api-<random-id>.eu-west-1.elb.amazonaws.com
```

**Test the endpoints:**
```bash
# Hello endpoint
curl https://your-alb-url/hello
# Returns: "hello world"

# Health check
curl https://your-alb-url/health
# Returns: {"status": "healthy"}
```

## Local Development

Run the API locally for development:
```bash
cd api
docker build -t hello-api .
docker run -p 3000:3000 hello-api

# Test locally
curl http://localhost:3000/hello
curl http://localhost:3000/health
```

## 🔄 Deployment Workflow

The CI/CD pipeline automatically triggers on git tag creation:

1. **Tag Creation**: `git tag v1.0.0 && git push origin v1.0.0`
2. **Build**: Docker image built from `/api` directory
3. **Push**: Image tagged and pushed to ECR
4. **Deploy**: ECS service updated with new image
5. **Verify**: Health checks confirm successful deployment


### Assumptions Made
- **Single Region**: Deployed to single region for simplicity
- **Public Access**: ALB is internet-facing for demo purposes
- **Single Environment**: No preprod/prod separation (time constraint)
- **Minimal API**: Simple FastAPI with two endpoints sufficient
- **GitHub Actions**: Adequate CI/CD platform for this scope

### Limitations
- **Single AZ**: Not highly available (cost optimization)
- **No Monitoring**: CloudWatch dashboards not implemented
- **Basic Security**: No WAF or advanced security features
- **No Database**: Stateless API only
- **Manual Cleanup**: Destroy requires manual workflow trigger 

### Cleanup
To destroy all resources:
1. Navigate to **Actions** → **Destroy Infrastructure**
2. Enter `destroy` in the confirmation field
3. Or run `./cleanup.sh` locally with AWS credentials

