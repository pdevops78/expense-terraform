# expense-terraform
** terraform console: will generate the timestamp
** destroy only specific resources: terraform destroy -target=aws_instance.web -target=aws_ami.custom_image
to remove from state file we can use terraform state rm "aws_ami_from_image"

├── main.tf               # root module
├── variables.tf          # root variables
├── main.tfvars           # root variable values
└── modules/
└── ec2-instance/
├── main.tf           # module resources
└── variables.tf      # module input variables


1. create server
2. create instance in that severs
3. then pull the secrets
4. elk


load balancer:
==============
- User sends a request to the Load Balancer using its DNS name (e.g., via HTTP or HTTPS).
- Listener on the Load Balancer receives the request based on the protocol and port it's configured to monitor (e.g., HTTP:80 or HTTPS:443).
- The listener evaluates its rules (like path or host conditions) and forwards the request to the matched target group.
- The registered target (like an EC2 instance or Lambda function) in that target group processes the request and returns a response.
- Load Balancer receives the response and sends it back to the user—keeping the backend hidden from the public.


steps: 1
--------
1. create two instances with same name and install nginx on both servers
2. create Target group
3. choose target type: instance
4. with protocol HTTP and Port:80 


1. create Load Balancer
2. select scheme: internal-facing(public) , internal(private)
3. choose internal-facing

steps: 2
--------
1. create a load balancer
2. select scheme: internal(private)

step3:
------
create a target group with instance type is "ip address"
target group (it is a backend process) 
listeners listen protocol and port(http,80)
so here if the http(user hits) sends traffic to target group(https)
http traffic should not convert to https


wide open security group means to allow all ports (0.0.0.0/0)
open application security group (frontend: 80, backend:8080,mysql: 3306) 
=========================================================================
with ALB:
----------
mysql port :3306 
backend port: 8080
frontend port: 80

Load Balancer forward requests to frontend and receive the traffic:
frontend component: app_port is 80 , public subnets can access frontend component
backend component: app_port is 8080, frontend subnets can access backend component and for backend there is another load balancer
load balancer type is private connect to backend itself 
frontend subnets and backend subnets
mysql component: app_port is 3306 , access by backend subnets(for mysql there is no load balancer)

Example Use Case
Your MySQL DB is running on an EC2 instance or RDS with port 3306 open

Your backend EC2 instances (with backend_sg) need to connect to that MySQL DB

Then your rule works perfectly to allow this specific traffic:

From: backend instances (with backend_sg)

To: MySQL server (port 3306)

Using: TCP

--------------------------------------------------------------
applications servers only open in security group:
----------------------------------------------------
loadbalancer can access frontend(means public subnets connects to nginx port 80)
frontend: server_app_port: public subnets
app_port : 80

2. frontend subnets access by backend subnets and itself backend( means nginx port connects nodejs port)
3. backend subnets access by mysql subnets (means backend connects mysql port 3306)

LoadBalancer application ports:
================================
frontend : lb_app_port: [0.0.0.0/0] , load balancer forward to the frontend
backend: frontend subnets access backend subnets


steps to follow to create load balancer:
-----------------------------------------
1. create load balancer
2. Load balancer should be created in public subnets, because required internet
3. user sends the request, request receive by load balancer
4. Load balancer forwards request to frontend instance , not for frontend subnets
5. frontend module provides public subnets to create a loadbalancer, because frontend instance has to expose data out through internet from private subnets
6. create two load balancer , one is for frontend (public) and another one is for backend(private)


Security Group Rules (summary):
Frontend SG → allow outbound to backend LB on port 8080.

Backend LB SG → allow inbound from frontend SG on port 8080.

Backend SG → allow outbound to MySQL SG on port 3306.

MySQL SG → allow inbound from backend SG on port 3306.

┌────────────┐       ┌────────────────────────────┐       ┌────────────┐
│  Internet  │──────▶│ Frontend Load Balancer (public) │────▶ Frontend │
└────────────┘       └────────────────────────────┘       └─────┬──────┘
Port 8080 │
▼
┌────────────────────────────┐       ┌────────────┐
│ Backend Load Balancer (private)│───▶ Backend   │
└────────────────────────────┘       └─────┬──────┘
Port 3306 │
▼
┌────────────┐
│   MySQL    │
└────────────┘

1. Security group rules:
=========================
* backend instances access mysql means backend instance ip  connects to mysql with port 3306 [so mysql allows backend subnets with listen 3306]
* ports are allowed ips' or cidr block in security group

RDS:
----
engine: mysql
engine_version:
availability: singleAZ
username: admin
password: customized
subnets: 
allocated storage: 20
public access : no
security groups:
storage_type: gp3
These custom configuration changes to memory settings were made through a DB parameter group


allocated_Storage: 20
component: rds
engine: mysql
engine_version: 8.0.36
family: mysql8.0
instance_class: db.t3.micro
server_App_port: var.backendServers
skip final snapshot: true
storage type: gp3
subnet_ids = module.vpc.db_subnets
vpc_id = module.vpc.vpc_id

KMS key:  create kms key
========
which is used to encrypt or decrypt the disk in VM's or rds to take backup
rds:
===
to encrypt storage disk device

vm's:
=====
to encrypt storage disk device while creating an instance
here there is a problem while creating a new VM/instance null resource won't execute , so to overcome this problem we use triggers block inside null resource.
this triggers block will work only null resource.

two types of backups are there:
-------------------------------
1. storage backup
2. native backup (mysql dump)


service linked role:  arn:aws:iam::041445559784:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling