# Variables
AWS_REGION ?= eu-west-1
APP_NAME = hello-api

# Build the application
build: 
	@echo "Building $(APP_NAME)..."
	@cd api && docker build -t $(APP_NAME) .
	@echo "Build complete!"
	
	
# Run the application 
run: build
	@echo "Running $(APP_NAME)..."
	docker run -p 3000:3000 $(APP_NAME)


# Clean up all stopped containers and images
clean:
	@echo "Cleaning up Docker containers and images..."
	@docker stop $(shell docker ps -aq) || true
	@docker rm $(shell docker ps -aq) || true
	@docker rmi $(shell docker images -aq) || true
	@echo "Cleanup complete!"