elstic ip

when you stop and start EC2 instacne it can change it's public ip
if you need to have a fixed public ip for your instance, you need an elastic IP
An elastic ip is a PUBLIC IPV4 ip you own as LONG as you don't delete IT
You can attach it to one instance at a time
With elastric ip address you can make the failure of an instance or software bt rapidly remapping the addres to another isntance in your account
you can only have 5 elastic IP in your acocunt (can ask AWS to increase that)
Overall : try to AVOIR using elastric IP :

- They often reflect poor architectural decisions
- Instead, use a random public IP and register a DNS name to it
- Or we can use loead balancer and avoit the use of public IP

Private vs Pulic IP (Ipv4) in AWS EC2

by default your EC2 machine comes with:

- A private IP fot the internal AWS network
- A public IP, for the WWW

When we are doing ssh into our ECé machines:

- We can't use a private Ip, because we are not in the same network
- We can only use the pubic IP

## If your machine is stopped ans then started **the public IP can CHANGE**

placement group

Sometimes you want to control over the EC2 intance placement strategy
That strategy can be defined using placmeent groups
When you create a placement group, you specify one of th efollowing strategies for the gorup:

- cluster: cluster instances into a low-latency group in a single AZ
- Spread: spreads instances across underlying hardware (MAX 7 instances per group per AZ) -> critical applications
- Partition: spreard instances across many different partitions (which rely on different sets of racks) witin an AZ. Scales to 100s ofEC2 instances per group (Hadoop, Cassandra, Kafka...)

**Cluster**: (SAME AZ): Pros: Great networking (10Gpbs bandwidth between instances with Enhanced Networking enabled, recommanded)
Cons: if the AZ fails, all instances fails at the sae time
Use case:

- big data job that needs to comlete fast
- application that needs extremely low latency and high network throughput

**Spread**: Pros: can span across AZ, reduced risk is simultaneous failure, EC2 instances are on DIFFERENT physical hardware
cons: Limited to 7 instances per AZ per placement group
use case: Application that needs to maximize high availability, critical applications where each instance must be isolated from failure from each other

**Partition**: Up to 7 partitions per AZ, Can span across multiple AZs in the same region, up to 100s of EC2 instances, The instances in a partition do not share racks with the instances in the other partitions, a partitions failure can affect many EC2 but won't affect other partitions, EC2 instances get access to the partitions information as metadata
Use cases: HDFS, Hbase, Cassandra, Kafka

---

Elastric Network Interfaces (ENI)

Logical component in a VPC that represent a virtual network card
The ENI can have the following attributes:

- Primary private Ipv4, one or more secondary IPv4
- One elastic Ip (IPv4) per private Ipv4
- One public Ipv4
- One or more security groups
- a MAC address
  you can create ENI independently and attach them on the fly (move them) on EC2 instances for failover
  bound to a specific AZ

---

EC2 Hibernate

WE KNOW:

We can stop, terminate instances:

- Stop: The data on disk (EBS) is kept intact in the next start
- Terminate: any EBS volumes (root) also set-up to be destroyed is LOST

On start, the following happens:

- Fist start: the OS boot & the EC2 User data script is run
- Following starts: the OS boot up
- Then your application starts, caches get warmed up, and that can take TIME

EC2 Hibernate

- The in-memory (RAM) state is preserved
- The instance boot is much faster (the OS is not stopped / restarted)
- Under the hood: RAM state is written to a file in the root EBS volume
- The root EBS volume must be encrypted
  Use cases:
- Long-running processing
- Saving the RAM state
- Services that take time to initialize

Goot to know

- supported instances families (a lot): C3, C4, C5, I3, M3, M4, R3, R4, T2, T3...
- Instance RAM Size: must be less than 150 GB
- Instance Size: not supported for **bare metal** instances
- AMI: Amazon Linux, Linux AMI, Ubuntu, RHEL, CentOS, Windows...
- Root Volume: must be EBS encrypted, not instance store, and large
- Available for On-demande, Reserved and Sport Instances

- An instance can **NOT** be hibernated more than 60 days
