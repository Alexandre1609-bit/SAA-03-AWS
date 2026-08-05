## EC2 instance Storage Section

EBS

Elastic block store (EBS) volume is a network drive you can attach to your instances while they run
Allows your instances to persist data, event after theu termination
thay can onyl be mounted to one instances at a time (CCP LEVEL SO MULTIPLE INSTANCE CAN RUN ON ONAEEBS???)
They are bound to a specific AZ

This of them as a "network USB stick"

It's a network drive (i.a not a physical drive)
it uses the netwrok to communicate the instance, which means there might be a bit of latency
It can be detached from an EC2 instance ans attached to another one quickly
It's locker to an AZ
an EBS volume in us-east-1a cannot be attached to us-east-1b
To move a volume across, you first need to snapshot it
Have a provisioned caacity (size in Gbs, and IOPS?)
Get billed for all the provisioned capacity
Can increase the capacity of the drive over time
EBS delete on termination attribute
Controls the EBS behaviour when an EC2 instance terminates
By default the root EBS volume is deleted (attribute enabled)
By default, any other attached EBS volume is not deleted (attribute disabled)
This can be controlled by the AWS console / AWS CLI
Use case : preserve root volume when instance is terminated

---

EBS snapshot

Make backup (snapshot) of your EBS volume at a point in time
Not necessary to detach volume to do scnapshot, but recommended
Can copy snapshot acreoss AZ or Region

Features :
EBS snapshot Archive

- Move a snapshot to an "archive tier" that is 75% cheaper
- Takes within 24 to 72 hours for restoring the archive

Recycle bin for EBS snapshots

- Setup rules to retain deleted snapshots so you can recover them after an accidental deletion
- Specify retention (from 1 day to 1 year)

Fast Snapshot Rstore (FSR)

- force full initialization of snapshot to have no latency on the first use ($$$)

---

AMI

AMI = Amazon Machine Image
AMI are a customization of an EC2 instance

- You add your own softwate, configuration operatioing system, monitoring...
- Faster boot / configuration tile because all your software is pre-packaged
  AMI are built fot a specific region (and can be copied across region)
  You can lauch EC2 instances from:
- A public AMI: AWS provided
- You own AMI: you make and maintain them yourself
- An AWs marketplace AMI: an AMI someone else made (and potentially sells)

AMI Process (from an EC2 instance)

- Start an EC2 instance and customize it
- Stop the instance (for data integrity)
- Build an AMI (will also create EBS snapshots)
- Launch instances from other AMIs

---

EC2 instnce Store

EBS volumes are network drives with good but "lilmited" performance
If you need a high-performance hardware disk, use EC2 instance Store

- Better I/O performance
- EC2 instance Store lose their storage if they're stopped (ephemeral)
- good for buffer / cache / scratch data / temporary content
- Risk of data loss if hardwxare fails
- Backups and replication are your responsaility

---

EBS volume types

EBS volumes come in 6 types :

- gp2 / gp3 (SSD): General purpose SSD volume that balances price and performance for a wide variety of workloads
- io1/io2 block express (SSD); Highest-performances SSd volume for mission-critical low-latency or high-throughput workloads
- st1 (HDD): Low cost HDD volume designed fot frequently accessed, throughput itensive workloads
- sc1 (HDD): Lowest cost HDD colume designed for less frequently accessed workloads
  EBS volumes are characterized in Size | Throughput | IOPS (I/O Ops Per Sec)
  When in doubt always consult the AWS documentation
  Only gp2/gp3 ans io1/io2 Block Express can bu used as boot volumes

EBS volumes types use canses

**GP2/GP3 (General purpose SSD)**

- Cost effective storage, low-latency
- system boot volumes, virtual desktops, Development and test environments
- 1GiB - 16TiB
- gp3:
  - Baseline of 3,000 IOPS ans throughput of 125MiB/s
  - Can increase IOPS up to 16,000 and throughput up to 1000MiB/s **independently**
- gp2:
  - Small gp2 volumes can burst IOPS to 3,000
  - Size of the volume and IOPS are **linked**, max IOPS is 16,000
  - 3 IOP per GiB, means at 5,334 GiB we are at the max IOPS

**Provisioned IOPS (PIOPS) SSD**

- Critical business applications with sustained IOPS performance
- Or applications tha tneed more than 16,000 IOPS
- Great for databases workloads (sensistive to storage perf and consistency)
- io1 (4GiB - 16TiB):
  - Max PIOPS: 64,000 for nitro EC2 instances & 32,000 for other
  - Can increase PIOPS independently from storage size
- io2 Block Express (4Gib - 64TiB):
  - Sub-milisecond latency
  - Max PIOPS: 256,000 with IOPS:GiB ratio of 1,000:1
- Support EBS **multi-attach**

**Hard Disk Drives (st1 / sc1)**:

- Cannot be a boot volume
- 125 GiB to 16 TiB
- Throughput Optimized HDD (**st1**)
  - Big Data, Data Warehouses, Log processing
  - Max throughput 500 MiB/s - max IOPS 600
- Cold HDD (**sc1**)
  - For data that is infrequently accessed
  - Scenario where lowest cost is important
  - Max throughput 250 MiB/s - max IOPS 250

---

EBS Multi-Attach - io1/io2 family

- Attach the same EBS volume to multiple EC2 instances in the same AZ
- Each instance has full read & write permissions to the high-performance volume
- Use case:
  - Achieve higher application availability in clustured Linux application (ex: Terradata)
  - Applications must manage concurrent write operations
- Up to **16 EC2 instances at a time**
- Must use file systel that's cluster-aware (**not** XFS,EXT4...)

---

EBS encryption

- When you create an encrypted EBS volume, you get the following:
  - Data at rest is encrypted inside the volume
  - All the data in flight moving between the instance and the volume is encrypted
  - All snapshot are encrypted
  - All volumes created from the snapshot
- Encryption and decryption are handled transparently (you have nothing to do)
- Encryption has a minimal impact on latency
- EBS encrpytion leverages keys from KMS (AEZ-256)
- Copying an unencrypted snapshot allows encryption
- Snapshots of encrypted volumes are encrypted

How to encrypt an unencrypted EBS volume

- Create an EBS snapshot of the volume
- Encrypt the EBS snapshot (using copy)
- Create new ebs volume from the snbapshot (the volume will also be encrypted)
- Now you can attach the encrypted volume to the original instance

---

- Amazon EFS - Elastic file System

* Managed NFS (network file system) that can be mounted on many EC2
* EFS works with EC2 instances in multi-AZ
* Highly available, scalable, **expensive** (3\* gp2), pey per use

* Use cases: content management, web serving, data sharing, Wordpress
* Uses NFSv4.1 protocol
* Uses security group to control access to EFS
* **Compatible with Linux AMI (not windows)**
* encryption at rest using KMS
* POSIX file system (~Linux) that has a standard file API
* File system **scale automatically**, pey-per-use, **no capacity planning**

- EFS - Performance & Storage Classes

* EFS Scale
  - 1000S of concurrent NFS client,10GB+/s throughput
  - Grow to **Petabyte**-scale network file system, automatically
* Perfomance Mode (set at EFS creation time)
  - General Purpose (default) : latency-sensitive use cases (web server, CMS, etc..)
  - Max I/O : higher latency, throughput, highly paralled (big data, media processing)
* Throughput mode
  - Bursting: 1TB = 50MiB/s + burst of up to 100MiB/s
  - Provisioned: set your trhoughput up or down bases on your workloads
  - Elastic: **automatically** scales throughput up or down based on your workloads
    - Up to 3GiB/s for reads and 1GiB/s for write
    - Used for unpredictable workloads

- EFS - Stoage Classes

* Storage Tiers (lifecycle management feature: move file after N days)
  - Standard: for frequently accessed files
  - Finfrequent access (EFF-IA): cost to retrive files, lower price to store
  - Archive: rarely accessed data (few time each year), 50% cheaper
  - Implement **lifecycle policies** to move files between storage tiers

* Availability and durability
  - Standard: Multi-AZ, great for prod
  - One zone: One AZ, great for dev, backup enabled by default, compatible with IA (EFS One Zone-IA)

* Over 90% in cost saving if we choose the right one to fulfill our needs

---

EBS vs EFS

- EBS volumes
  - one instance (except multi-attach io1/io2)
  - are locked at the AZ level
  - gp2: IO increases if the disk size increases
  - gp3 & io1: can increase IO independently

- To migrate an EBS volumes across AZ
  - Take a snapshot
  - Restore the snapshot to another AZ
  - EBS backups use IO and you shouldn't run them while your application is handling a lot of traffic

- Root EBS volumes of instances get terminated by default if the EC2 instance gets terminated (you can disable that)

- EFS
  - Mounting 100s (or more) of instances across AZ
  - EFS share website files (Wordpress)
  - Only for linux instances (POSIX)
  - EFS has a higher price point than EBS
  - Can leverage Storage Tiers for cost savingg

EFS vs EBS vs Instance store
