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
