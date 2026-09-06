Amazon RDS

RDS stands for **Relational Database Service**
It's a managed DB service for DB that use **SQL** as a query language
It allows you to create databases in the cloud that are **managed by AWS**

- Posgres
- MySQL
- MariaDB
- Oracle
- Microsoft SQL Server
- IBM DB2
- Aurora (AWS Proprietary database)

RDS is a managed service:

- Automated provisioning, OS patching
- Continuous backups and restore to specific timestamp (Point in Time Restore)
- Monitoring dashboards
- Read replicas for impoved read performance
- Multi AZ setup for DR (Disaster Recovery)
- Maintenance windows for upgrades
- Scaling capability (vertical and horizontal)
- Storage backed by EBS
- BUT we **can't** SSH into our instances

RDS - Storage Auto scaling

- Help increase storage on our RDS DB instance dynamically
- When RDS detects you are running out of free database storage, it scales automatically
- Avoir manually scaling your database storage
- You have to set **Maximum Storage Threshold** (maximum limit for DB storage)
- Automatically modify storage if:
  - Free storage is less than 10% of allocated storage
  - Low-storage lastsat least 5 minutes
  - 6 hours have passed since last modification
- Useful for aplication with **unpredictable workloads**
- Support all RDS database engines

RDS Read Replicas vs Multi AZ

- Up to 15 Read Replicas
- Within AZ, Cross AZ or Cross Region
- Replicas is **ASYNC**, so reads are eventually consistent
- Replicas can be promoted to their own DB
- Applications must update the connection string leverage read replicas

Use Cases

- You have a production database that is taking on normal load
- You want to run a reporting application to run some analytics
- You create a Read Replica to run the new workload there
- The production application is unaffected
- Read Replicas are used for **SELECT** (read) only kind of statements (not INSERT, UPDATE, DELETE)

Network Cost

- In AWS there's a network cost when data goes from one AZ to another
- **For RDS Read Replicas within the same region, you don't pay that fee**

RDS Multi AZ (Disaster Recovery)

- **SYNC** replication
- One DNS name: automatic app failover to standby
- Increase availability
- Failover in case of loss AZ, loss of network, instance or storage failure
- No manual intervention in apps
- Not used for scaling

(**he Read Replicas can be setup as Multi AZ for Disaster Recovery (DR)**)

RDS: From Single-AZ to Multi-AZ

- Zero downtime operation (no need to stop the DB)
- Just click on "modify" for the database
- The following happens internally:
  - A snapshot is taken
  - A new DB is restored from the snapshot in a new AZ
  - Synchronization is established between the two databases
