# Variables
AWS_REGION ?= eu-west-1
APP_NAME = hello-api

# Generate GitHub OIDC thumbprint
thumbprint: ## Generate GitHub OIDC provider thumbprint
	@echo "Generating GitHub OIDC thumbprint..."
	@echo | openssl s_client -servername token.actions.githubusercontent.com -connect token.actions.githubusercontent.com:443 2>/dev/null | openssl x509 -fingerprint -noout -sha1 | cut -d= -f2 | tr -d : | tr '[:upper:]' '[:lower:]'
	@echo "Use this thumbprint in terraform/modules/github-oidc/main.tf"

# Deploy infrastructure only (no app)
deploy_infra: ## Deploy AWS infrastructure only
	@echo "Deploying infrastructure..."
	@cd terraform && terraform init && terraform apply -auto-approve
	@echo "Infrastructure deployment complete!"
	@$(MAKE) info

# Deploy application only
deploy_app: ## Build and deploy application to existing infrastructure
	@echo "Deploying application..."
	@ECR_URL=$$(cd terraform && terraform output -raw ecr_repository_url) && \
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $$ECR_URL && \
	cd api && \
	docker build -t $(APP_NAME) . && \
	docker tag $(APP_NAME):latest $$ECR_URL:latest && \
	docker push $$ECR_URL:latest
	@echo "Updating ECS service..."
	@CLUSTER_NAME=$$(cd terraform && terraform output -raw ecs_cluster_name) && \
	SERVICE_NAME=$$(cd terraform && terraform output -raw ecs_service_name) && \
	aws ecs update-service --cluster $$CLUSTER_NAME --service $$SERVICE_NAME --force-new-deployment --region $(AWS_REGION)
	@echo "Application deployment complete!"

# Display deployment info
info: ## Show deployment information
	@echo "Deployment Information:"
	@cd terraform && terraform output

# Build the application locally
build: 
	@echo "Building $(APP_NAME)..."
	@cd api && docker build -t $(APP_NAME) .
	@echo "Build complete!"

# Run the application locally
run: build
	@echo "Running $(APP_NAME)..."
	docker run -p 3000:3000 $(APP_NAME)

# Test Endpoint - health
test_health:
	@echo "Testing health endpoint..."
	curl -f http://localhost:3000/health || true

# Test Endpoint - hello
test_hello:
	@echo "Testing hello endpoint..."
	curl -f http://localhost:3000/hello || true

# Clean up local Docker resources
clean:
	@echo "Cleaning up Docker containers and images..."
	@docker container prune -f 2>/dev/null || true
	@docker image prune -f 2>/dev/null || true
	@docker system prune -f 2>/dev/null || true
	@echo "Cleanup complete!"

# Destroy infrastructure
destroy_infra: ## Destroy all infrastructure
	@echo "Destroying infrastructure..."
	@cd terraform && terraform destroy -auto-approve
	@echo "Infrastructure destroyed!"
