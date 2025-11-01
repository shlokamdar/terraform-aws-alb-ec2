

# 🌍 AWS Load Balancer Architecture – *shlo111 Project*

This README describes the AWS infrastructure setup for the `shlo111` web application, featuring an **Application Load Balancer (ALB)** distributing traffic to **EC2 instances** running **Nginx**.

---

## 🧭 Overview

The architecture enables high availability and scalability through an **Application Load Balancer (ALB)** placed in front of EC2 instances inside a **VPC** with a **Public Subnet** and **Internet Gateway**.

---

## 🏗️ Architecture Diagram

```
🌍 INTERNET
        │
        ▼
┌───────────────────────────────────────────────┐
│     Application Load Balancer (ALB)           │
│     Name: shlo111-loadbalancer                │
│     DNS: shlo111-loadbalancer-xxxx.elb.amazonaws.com │
└──────────────────┬────────────────────────────┘
                   │
         forwards HTTP (port 80)
                   │
         via Listener + Target Group
                   │
    ┌──────────────┴──────────────────────────┐
    │                                         │
    ▼                                         ▼
┌────────────────┐                  ┌────────────────┐
│ Target Group   │                  │ Health Check   │
│ Name: shlo111-tg│                 │ Path: "/"      │
│ Protocol: HTTP  │                 │ Interval: 30s  │
└────────────────┘                  └────────────────┘
        │
        ▼
┌────────────────────────────────────────────────────┐
│               EC2 Instance (Nginx)                 │
│ Name: shlo111-web-server                           │
│ AMI: Amazon Linux / Ubuntu                         │
│ User Data: install_nginx.sh (auto-installs NGINX)  │
│ Security Group: shlo111-web-sg                     │
│ Inbound: Ports 22 (SSH), 80 (HTTP)                 │
│ Public IP: 3.110.145.114                           │
└────────────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────┐
│      Public Subnet 1     │
│  CIDR: 10.0.1.0/24       │
│  AZ: ap-south-1a         │
└──────────────────────────┘
        │
        ▼
┌──────────────────────────┐
│     Internet Gateway     │
│     Name: shlo111-igw    │
└──────────────────────────┘
        │
        ▼
┌──────────────────────────┐
│           VPC            │
│     Name: shlo111-vpc    │
│     CIDR: 10.0.0.0/16    │
└──────────────────────────┘
```

---

## ⚙️ Key Components

| Component                           | Description                                                  |
| ----------------------------------- | ------------------------------------------------------------ |
| **VPC**                             | Virtual Private Cloud that contains all resources.           |
| **Subnet**                          | Public Subnet for EC2 instances accessible via the internet. |
| **Internet Gateway**                | Enables external internet access.                            |
| **Application Load Balancer (ALB)** | Distributes incoming traffic across EC2 instances.           |
| **Target Group**                    | Contains EC2 instances for load balancing.                   |
| **Health Check**                    | Periodically checks the EC2 instance health via path `/`.    |
| **EC2 Instance**                    | Runs NGINX web server installed via `User Data` script.      |
| **Security Group**                  | Allows inbound SSH (22) and HTTP (80) traffic.               |

---

## 🚀 Workflow Summary

1. **User Request** → Sent from browser via Internet.
2. **Load Balancer (ALB)** → Receives HTTP traffic on port 80.
3. **Listener & Target Group** → Forwards request to registered EC2 targets.
4. **EC2 Instance (Nginx)** → Serves the web content.
5. **Response** → Sent back to the user through the same route.

---

## 📦 Notes

* Nginx auto-installs via `install_nginx.sh` in EC2 user data.
* Health checks ensure traffic only routes to healthy instances.
* Public subnet + Internet Gateway allows direct access via ALB DNS.


