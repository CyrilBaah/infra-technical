#!/bin/bash

echo "Cleaning up all hello-api resources..."

# Stop ECS service first
echo "Stopping ECS service..."
aws ecs update-service --cluster hello-api-cluster --service hello-api-service --desired-count 0 2>/dev/null || echo "ECS service not found"
sleep 30

# Delete ECS service
echo "Deleting ECS service..."
aws ecs delete-service --cluster hello-api-cluster --service hello-api-service --force 2>/dev/null || echo "ECS service not found"

# Delete ECS cluster
echo "Deleting ECS cluster..."
aws ecs delete-cluster --cluster hello-api-cluster 2>/dev/null || echo "ECS cluster not found"

# Delete load balancer
echo "Deleting load balancer..."
LB_ARN=$(aws elbv2 describe-load-balancers --names hello-api --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null)
if [ "$LB_ARN" != "None" ] && [ "$LB_ARN" != "" ]; then
    aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN
    sleep 60
fi

# Delete target groups
echo "Deleting target groups..."
aws elbv2 describe-target-groups --names hello-api --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null | xargs -I {} aws elbv2 delete-target-group --target-group-arn {} 2>/dev/null || echo "Target group not found"

# Delete security groups
echo "Deleting security groups..."
aws ec2 describe-security-groups --filters "Name=group-name,Values=hello-api-*" --query 'SecurityGroups[].GroupId' --output text | xargs -n1 -I {} aws ec2 delete-security-group --group-id {} 2>/dev/null || echo "Security groups not found"

# Delete VPC
echo "Deleting VPC..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=hello-api-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null)
if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "" ]; then
    aws ec2 delete-vpc --vpc-id $VPC_ID 2>/dev/null || echo "VPC deletion failed"
fi

# Delete ECR repository
echo "Deleting ECR repository..."
aws ecr delete-repository --repository-name hello-api --force 2>/dev/null || echo "ECR repository not found"

# Delete CloudWatch log group
echo "Deleting CloudWatch log group..."
aws logs delete-log-group --log-group-name /aws/ecs/hello-api 2>/dev/null || echo "Log group not found"

# Delete IAM roles
echo "Deleting IAM roles..."
aws iam delete-role-policy --role-name hello-api-ecs-task-execution --policy-name hello-api-ecs-task-execution-policy 2>/dev/null || echo "Task execution policy not found"
aws iam delete-role --role-name hello-api-ecs-task-execution 2>/dev/null || echo "Task execution role not found"
aws iam delete-role-policy --role-name hello-api-ecs-task --policy-name hello-api-ecs-task-policy 2>/dev/null || echo "Task policy not found"
aws iam delete-role --role-name hello-api-ecs-task 2>/dev/null || echo "Task role not found"
aws iam delete-role-policy --role-name hello-api-github-actions --policy-name hello-api-github-actions-policy 2>/dev/null || echo "GitHub actions policy not found"
aws iam delete-role --role-name hello-api-github-actions 2>/dev/null || echo "GitHub actions role not found"

# Delete OIDC provider
echo "Deleting OIDC provider..."
aws iam delete-open-id-connect-provider --open-id-connect-provider-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/token.actions.githubusercontent.com" 2>/dev/null || echo "OIDC provider not found"

# Delete S3 bucket
echo "Deleting S3 state bucket..."
aws s3 rm s3://hello-api-terraform-state --recursive 2>/dev/null || echo "S3 bucket not found"
aws s3 rb s3://hello-api-terraform-state 2>/dev/null || echo "S3 bucket not found"

echo " Cleanup complete!"
