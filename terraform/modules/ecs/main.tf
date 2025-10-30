data "aws_ecs_cluster" "main" {
  cluster_name = "${var.project_name}-cluster"
}

data "aws_cloudwatch_log_group" "app" {
  name = "/aws/ecs/${var.project_name}"
}

data "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution"
}

data "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task"
}

data "aws_lb" "main" {
  name = var.project_name
}

data "aws_lb_target_group" "app" {
  name = var.project_name
}

data "aws_lb_listener" "app" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.project_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn           = data.aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = "${var.ecr_repository_url}:latest"
      
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = data.aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-service"
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.ecs_security_group]
    subnets         = var.public_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.app.arn
    container_name   = var.project_name
    container_port   = 3000
  }

  depends_on = [data.aws_lb_listener.app]
}
