res on RDS

- Aurora storage automatically growns in increments of **10GB**, up to **256TB**
- Aurora can have up to 15 replicas and the preplication process is faster than MySQL (sub 10 ms replica lag)
- Faliover in Aurora is instantaneous. It's HA narive.
- Aurora cost more than RDS (20% more)

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
- Applications must update the connec, but is more efficient
  tion string leverage read replicas

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

RDS Custom

- Managed **Oracle** and **Microsoft** SQL Server Database with OS and database customization
- RDS: Automates setup, operation and scaling of database in AWS
- Custom: access to the underlying database and OS so you can:
  - Configure settings
  - Install patches
  - Enable native features
  - Access to the underlying EC2 instance using **SSH** or **SSM Session Manager**
- **De-activate Automation Mode** to perform your customization, better to take a DB snapshot before
- RDS vs RDS Custom:
  - RDS: Entire database and the OS to be managed by AWs
  - RDS Custom: full admin access to the underlying OS and the database

Amazon Aurora

- Aurora is a proprietary technology from AWS (not open sourced)
- Postgres and MySQL are both supported as Aurora DB (that mean your drivers will worl as if Aurora was a Postgres or MySQL database)
- Aurora is "AWS cloud optimized" and claims 5x performance improvement over MySQL on RDS, over 3x the performance of Postgres on RDS
- Aurora storage automatically growns in increments of **10GB**, up to **256TB**
- Aurora can have up to 15 replicas and the preplication process is faster than MySQL (sub 10 ms replica lag)
- Faliover in Aurora is instantaneous. It's HA narive.
- Aurora cost more than RDS (20% more), but is more efficient

Aurora high availability and read scaling

- 6 copies of your data across 3 AZ:
  - 4 copies out of 6 needed for writes
  - 3 copies out of 6 need for reads
  - Self healing with peer-to-peer replication
  - Storage is striped across 100s volumes
- One aurora instance takes writes (master)
- Automated failover for master in less than 30 seconds
- Master + up to 15 replicas serve reads (one of the read replicas can become master in case of failover)
- Support for Cross Region Replcation

Aurora DB cluster

- One writer Endpoint pointing to the master
  - Clients are redirected to this endpoint when they want to write (Master write on the Shared Storage Volume which expend form 10gig to 256tb)
- One reader Endpoint (load balancer) which connect to all read replicas (**Read replicas can auto scale too**)
  - Client are redirected to one of the available read replicas when reading data (Read from shared storage volume)

Features of Aurora

- Automatic fail-over
- Backup and Recovery
- Isolation and security
- Industry compliance
- Push-button scaling
- Aotomated Patching with Zero Downtime
- Adanced monitoring
- routine Maintenance
- Backtrack: restore data at any point of time without using backups

Aurora Replicas - Auto Scaling

- Create more read replicas when large amount of read request comes in, scale reader endpoint in order to reduce CPU usage

Aurora - Custom Endpoints

- We can have differents instance types (r3.large, r5.2xlarge...)
- Can have custom endpoint: use only this type of instance for specifif workload...
- Define a subset of Aurora instances as a Custom endpoint
- Example: Run analytical queries on specific replicas
- The reader Endpoint is generally not used after defining Custom Endpoints

Aurora Serverless

- Automated database instantiation and auto-scaling based on actual usage
- Good for infrequent, intermittent or unpredictable workloads
- No capacity planning needed
- Pay **per second**, can be more cost-effective
- Client talk to a proxy fleet (managed by aurora) and scale according to the workloads

Global Aurora

- Aurora Cross Region read Replicas:
  - Useful for disaster recovery
  - Simple to put in place
- Aurora global Database (recommended):
  - 1 primary Region (read / write)
  - Up to 10 secondary (read-only) regions, replication lag is less than 1 second
  - Up to 16 read replicas per secondary region
  - Helps of decreasing latency
  - Promoting another region (for disaster recovery) has an RTO (Recovery time objective) of < 1 minutes
  - **Typical cross-region replication takes less than 1 second**

Aurora Machine Learning

- Enable you to add ML-based predictions to your applications via SQL
- Simple, optmized, and secue integration between Aurora ans AWS ML services
- Suported services:
  - Amazon SageMaker (use with any ML model)
  - Amazon Comprehend (for sentiment analysis)
- You don't nee to have ML experience
- Use cases: fraud detection, ads targeting, sentimlent analysis, product recommendations

Babelfish for Aurora PostgreSQL

- Allow Aurora PostgreSQL to understand commands targeted for MS SQL Server (e.g., T-SQL)
- Therefore Microsoft SQL Server based applications can work on Aurora PostgreSQL
- Requires no to little code changes (using the same MS SQL server client driver)
- the same applications can be used after a migration of your database (using AWS SCT and DMS)

RDS Backups

- Automated backups:
  - Daily full backup of the database (during the backup window)
  - Transaction logs are backed-up by RDS every 5 minutes
  - -> Ability to restore to any point in time (from oldest to 5 minutes ago)
  - 1 to 35 days of retention, set 0 to disable automated backups
- Manual DB Snapshots
  - Manually triggered by the user
  - Retention of backup for as long as you want
- Trick: in a stopped RDS database, you will still pay for storage. If you plan on stopping it for a long time, you should snapshot & restore instead.

Aurora Backups

- Automated bakcups
  - 1 to 35 days (cannot be disabled)
  - point-in-time recovery in that timeframe
- Manual DB Snapshots
  - Manually triggered by the user
  - Retention of backup for as long as you want

RDS & Aurora Restore options

- Restoring a RDS / Aurora backup or a snapshot creates a new database
- Restoring MySQL RDS database from S3
  - Create a backup of your on-premises database
  - Store it on Amazon S3 (object storage)
  - Restore the backup file onto a new RDS instance running MySQL
- Restoring MySQL Aurora cluster from S3
  - Create a backup of your on-premises database using Percona XtraBackup
  - Store the backup file on Amazon S3
  - Restore the backup file onto a new Aurora cluster running MySQL

Aurora Database Cloning

- Create a new Aurora DB cluster form an existing one
- Faster than snapshot & restore
- Uses **copy-on-write** protocol
  - Initially, the new DB cluster uses the same data volume as the original DB cluster (fast and efficient, no copying is needed)
  - When updates are made to the new Db cluster data, then additional storage is allocated ans data is copied to be separated
- Very fast & cost-effective
- **Useful to vreate a "staging" database from a "production" databse without impacting the production database.**

RDS & Aurora Security

- At-rest encryption:
  - Database master & replicas encryption using AWS KMS: must be defined as launch time
  - If the master is not encrypted, the read database cannot be encrypted
  - To encrypt an un-encrypted database, go though a DB snapshot & restore as encrypted
- In-flight encryption: TLS-ready by defaults, use AWS TLS root certificates client-side
- IAM Authentication: IAM roles to connect to your database (instead of username/pw)
- Security groups: Control Netwok access to your RDS / Aurora db
- No SSH available except on RDS Custom
- Audit Logs can be enabled and sent to cloudwatch Logs for longer retention

Amazon RDS Proxy
