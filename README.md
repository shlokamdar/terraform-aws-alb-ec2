# Terraform-Based AWS ALB with EC2

## Project Overview
This project demonstrates provisioning a scalable AWS web infrastructure using **Terraform**. An **Application Load Balancer (ALB)** distributes HTTP traffic across multiple **EC2 instances** running Nginx, ensuring high availability and fault tolerance.

The entire infrastructure is managed as code, following Infrastructure as Code (IaC) principles.

---

## Architecture Overview

### Components
- **VPC**: Isolated networking environment for all resources
- **Public Subnet**: Hosts the Application Load Balancer and EC2 instances
- **Internet Gateway**: Enables inbound and outbound internet connectivity
- **Application Load Balancer**: Distributes HTTP traffic across EC2 instances
- **Target Group**: Registers EC2 instances for load balancing
- **EC2 Instances**: Run Nginx web server configured using user data
- **Security Groups**:
  - Allow HTTP (80) access via ALB
  - Allow SSH (22) for administrative access

### Architecture Diagram
![Terraform ALB Architecture](terraform-alb-ec2-architecture.png.png)

---

## Traffic Flow
1. Client sends an HTTP request.
2. Application Load Balancer receives traffic on port 80.
3. ALB forwards requests to the target group.
4. Target group distributes requests across healthy EC2 instances.
5. Nginx responds with web content.

---

## Terraform Highlights
- Modular resource definition
- Declarative infrastructure provisioning
- Idempotent deployments
- Easy scalability by adjusting instance count
- Clear separation of networking and compute resources

---

## Health Checks and Availability
- ALB performs periodic health checks on EC2 instances.
- Traffic is routed only to healthy targets.
- Ensures uninterrupted service during instance failure.

---

## What This Project Demonstrates
- Infrastructure as Code using Terraform
- AWS load balancing concepts
- High availability web architecture
- Practical EC2 and ALB integration
- Real-world deployment patterns

---

## Future Enhancements
- Add Auto Scaling Group
- Introduce private subnets with NAT Gateway
- Enable HTTPS using ACM
- Terraform state management with remote backend

