output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = data.aws_lb.main.dns_name
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = data.aws_ecs_cluster.main.cluster_name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}
