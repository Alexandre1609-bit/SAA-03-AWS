Scalability & High Availability

- Scalability means that an application / system can handle greater loads by adapting.
- There are two kinds of scalability:
  - Vertical Scalability
  - Horizontal Scalability (= elasticity)
- Scalability is linked but different to High Availability

Vertical Scalability

- Vertically scalability means increasing the size of the instance
- For example, your application runs on a t2.micro
- Scaling that application vertically means running it on a t2.large
- Vertical scalability is very common for non distributed system, such as a database
- RDS, ElastiCache are services that can scale vertically
  There's usually a limit to how much you can vertically scale (hardware limit)

Horizontal Scalability

- Horizontal Scalability means increasing the number of instances / system for your application
- Horizontal scaling implies distributed systems
- This is very common for web applications / modern applications
- It's easy to horizontally scale thanks to the cloud offerings such as Aamzon EC2

High Availability

- High Availability usually goas hand in hand with horizontal scaling
- High avaialbility means running your application / system in at least 2 data centers (== AZ)
- The goal of high availability is to survive a data center loss
- The high availability can be passive (for RDS multi AZ for example)
- The high availability can be active (for horizontal scaling)

High Avaialbility & Scalability for EC2

- Vertical Scaling: Increase instance size (= scale up / down)
  - from: t2.nano - 0.5G of RAM, 1 cCPU
  - to: u-12tb1.metal - 12.3TB of RAM, 448 vCPUs

- Horizontal Scaling: Increase number of instances (= scale out / in)
  - Auto Scaling Group
  - Load Balancer
- High Availability: Run instances for the same application across multi AZ
  - Auto Scaling Group multi AZ
  - Load Balancer multi AZ

---

Elastic Load Balancing (ELB) Overview

What is load balancing ?

- Load balances are servers that forward traffic to multiple servers (e.g., EC2 instances) downstream

Why use a load balancer ?

- Spread load across multiple downstream instances
- Expose a single point of access (DNS) to your application
- Seaslessly handle failures of downstream instances
- Do regular health checks to your instances
- Provide SSL termination (HTTPS) for your websites
- Enforce stickiness with cookes
- High availability across zones
- Separate public traffic from private traffic

Why use an Elastic Load Balancer ?

- An Elastic Load Balancer is a **managed load balancer**
  - AWS guarantees that it will be working
  - AWS takes care of upgrades, maintenance, high availability
  - AWS provides only few configuration knobs
- It costs less to setup your own load balancer but it will be a lot more effort on your end
- It is integrated with many AWS offerings / services
  - EC2, EC2 Auto Scaling Groups, Amazon ECS
  - AWS Certificate Manager (ACM), CloudWatch
  - Route 53, AWS WAF, AWS Global Accelerator

Health Checks

- Health Checks are crucial for Load Balancers
- They enable the load balancer to know if instances it forwards traffic to are available to reply to requests
- The health check is done on a port and a route (/health is common)
- If the response is not 200 (OK), then ths instance is unhealthy

Types of load balancer on AWS

- AWS has **4 kinds of managed Load Balancers**
  - **Classic Load Balancer** (v1 - old generation, _dprecated_) - 2009 - CLB \* HTTP, HTTPS, TCP, SSL (secure TCP)
  - **Application Load Balancer** (v2 - new generation) - 2016 - ALB \* HTTP, HTTPs, WebSocket
  - **Network Load Balancer** (v2 - new generation) - 2017 - NLB \* TCP, TLS (secure TCP), UDP
  - **Gateway Load Balancer** - 2020 - GWLB \* Operates at layer 3 (Network Layer) - IP protocol
- Overall, it is recommended to use the newer generation load balancers as they provide more features
- Some load balancers can be setup as **internal** (private) or **external** (public) ELBs

Load Bakancer Security group

- Link Load Balancer security group to EC2 (only accept traffic from laod balancer)

---

Application Load Balancer (v2)

- Application load balancers is Layer 7 (HTTP)
- Load balancing to multiple HTTP applications across machines (target groups)
- Load balancing to multiple applications on the same machine (ex: containers)
- Support for HTTP/2 and WebSocket
- Support redirects (from HTTP to HTTPS for example)

- Routing tables to differents target groups:
  - Routing based on path in URL (example.com/users & example.com/posts)
  - Routing based on hostname in URL (one.example.com & other.example.com)
  - Routing based on Query String Headers (example.com/users?id=123&order=false)

- ALB are great fir for micro services & container-based application (ex: Docker & amazon ECS)
- Has a port mapping feature to redirect to a dynamic port in ECS
- In comparison, we'd need multiple Classic Load balancer per Application

target Groups

- EC2 instances (can be managed by an Auto Scaling Group) - HTTP
- ECS tasks (managed by ECS itself) - HTTP
- Lambda functions - HTTP request is translated into a JSON event
- IP Addresses - must be private IPs

- ALB can route to multiple target groups
- Health checks are at the target group level

Good to know

- fixed hostname (XXX.region.elb.amazonaws.com)
- the application server don't see the IP of the client directly
  - the true IP of the client is insterted in the header X-Forwarded-For
  - We can also get Port (X-Forwarded-Port) ans protocol (proto) X-Forwarded-Proto

---

Network LoadBalancer(v2)

Network load balqncers (L4) allow to:

- Forward TCP & UDP traffic to your instances
- Handle millions of request per seconds
- ultra-low latency

- NLB has **one static IP per AZ**, and **supports assigning Elastic IP**. (helpful for whitelisting specific IP)
- NLB are used for extreme performance, TCP or UDP traffic

NLB - Target Groups

- ECS instances
- IP addresses - must br private IPs (static srv...)
- Application Load Balancer
- Health Checks support the TCP, HTTP and HTTPS Protocols

---

Gateway Load Balancer

- Deply, scalen and manage a fleet of 3rd party network virtual applicances in AWS
- Example: Firewalls, intrusion detection and prevention system, deep packet inspection system, payload manipulation...
- Operate at L3 (network) - IP Packet
- Combines the following functions:
  - Transparent network gateway - single entry/exit for all traffic
  - Load balancer - ditribute traffic to yout virtual apliances
- Uses the **GENEVE** protocol on port **6081**

Target groups :

- EC2 instances
- IP addresses (must be private IPs)

---

Sticky Sessions (session Affinity)

- It is possible to implemenjt stickiness so that the same client is alwys redirected to the same instance behind a load balancer
- This works for Classic Load Balancer, ALB, NLB
- The "cookie" used for stickines has an expiration date you control
- Use case: make sure the user doesn't lose his session data
- Enabling stickiness may bring imbalance to the load over backend EC2 instances

Cookie Names

- Application-based Cookies
  - Custom cookie
    - Generated by the target
    - Can include any custom attributes required by the application
    - Cookie name must be specified individually for each target group
    - Don't use **AWSALB**, **AWSALBAPP**, or **AWSALBTG** (reserved for use by the ELB)
  - Application cookie
    - Generated by the load valancer
    - Cookie name is **AWSALBAPP**
- Duration-based cookies
  - Cookie generated by the load balancer
  - Cookie name is **AWSALB** for ALB, **AWSELB** for CLB

---

Elastic Load Balancer : Cross zone load Balancing

- With Cross Zone Load Balancing
  - Each load balancer instance distribute evenly across all registered instances in all AZ
- Without Cross Zone Load Balancing
  - Request are distributed in the instances of the node of the Elastic Load Balancer

- Application Load Balancer
  - Enabled by default (can be disabled at the target group Level)
  - No charges for inter AZ data

- Network Load Balancer & Gateway Load Balancer
  - Disabled by default
  - You pay charges ($) for inter AZ data if enabled

- Classic Load Balancer
  - Disavled by default
  - No charges for inter AZ data if enabled

---

Elastic Load Balancer - SSL Certificates

SSL/TLS - Basics

- An SSL Certificate allows traffic between your clients and your load balancer to be encrypted in transit (in-flight encryption)
- SSL refer to Secure Socket Layer, used to encrypt connections
- TLS refers to Transport Layer Security, which is a newer version
- Nowdays, TLS certificates are mainly used, but people still refer as SSL
- Public SSL certificates are issued by Certificate Authorities (CA)
- Comodo, Symantec, GoDaddy, GlobalSign, Digicert, Letsencrypt...
- SSL certificates have an expiration date (you set) and must be renewed

Load Balancer - SSL Certificates

- The load balancer uses an X.509 certificate (SSL/TLS server certificate)
- You can manage certificates using ACM (AWS Certificate Manager)
- You can create upload your own certificates alternatively
- HTTPS listener:
  - You must specify a default certificate
  - You can add an optional list of certs to support multiple domains
  - Clients can use SNI (Server Name Indication) to specify the hostname they reach
  - Ability to specify a security policy to support older versions of SSL/TLS (legecy clients)

SSL -Server Name Indication (SNI)

- SNI solves the problem of loading multiple SSL certificates onto one web server (to serve multiple websites)
- It's a "newer" protocol, and requires the client to indicate the hostname of the target server in the initial SSL handshake
- The server will then find the correct certificate, or return the default one

Note:

- Only works for ALB & NLB (newer generation), CloudFront
- Does not work for CLB (Older generation)

* Classic Load Balancer (v1)
  - Support only one SSL certificate
  - Must use mutiple CLB for multiple hostname with multiple SSL certificates

* Application Load Balancer (v2)
  - Supports multiple listeners with mumtiple SSL certificates
  - Uses Server Name Indication (SNI) to make it work

* Network Load Balancer (v2)
  - Supports multiple listeners with multiple SSL certificates

Elastic Load Balancer - Connection Draining

- Feature naming:
  - "Connection Draining": for **CLB**
  - "Deregistration Delay": for **ALB** & **NLB**

- Time to complete "in-flight requests" while the instance is de-registering or unhealthy
- Stop sending new requests to the ECS instance which is de-registering
- Between 1 to 3600 seconds (default: 300 seconds)
- Can be disabled (set value to 0)
- Set to a low value if your requests are short
