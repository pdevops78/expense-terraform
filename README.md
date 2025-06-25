# expense-terraform

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

