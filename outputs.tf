# ---------------------------------------------
# Outputs
# ---------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs across AZs"
  value = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id
  ]
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.app_alb.arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.web_tg.arn
}

output "ec2_instance_id" {
  description = "Web server EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance (for SSH/testing)"
  value       = aws_instance.web_server.public_ip
}
