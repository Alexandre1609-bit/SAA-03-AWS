ingress: {
port: - name: postgres
port: 5432
namespace: prod
matchLabel:
app-backend
}

egress: {}

---

EC2 purchasing options

- **on-demand instances** : pay by seconds
  pay for what you use
  highest cost but no upfront payment
  no long-term commitment
  recommended for short-term and un-interrupted workloads, where you can't predict how the application will behave

- **reserverd** (1 & 3 years)
  long workloads
  up to 72% discount to on demand
  reserve specifif instance attributes (instance type, region..)
  reseervation persion
  Payment option (upfront, partial upfront, all upfront)
  reserved instance's scope (regional or Zonal)
  recommended for steady state usage aplications (think database)
  can buy and sell in the reserved instance marketplace
  **convertible reserved instances**
  Can change the EC2 instance type, instance family, OS, scope and tenancy

- **Saving Plan** (1 & 3 years)
  commitment to an amount of usage, long workload
  get discount based onn longterm usage (up to 72%)
  commit to a certiain type of usage (ie: 10$/hour for i or 3 year)
  Usage beyond EC2 savings Plan is billed at the on demand price
  Locked to a specific instance family & AWS region (ie: M5 in us-east-1)
  flexible accros:
  Instance Size (ie: m5.xlarge, m5.2xlarge...)
  OS -(inux, windows...)
  Tenance (Host, dedicated, default...)

- **Spot instances**
  short workloads, cheap, can lose instances (less reliable)
  Can get discount of op to 90% compared to on-demand
  Instance that you can "lose" at any point of time if your max price is less than the current sport price
  MOST cost-efficient instances in AWS
  Useful for workloads that are resilient to failure
  batch jobs, data analysis, image processing, any distributed workloads, workloads with a flexible start and end time
  NOT suitabl for critical job or database

- **Dedicated Host**
  book an entire physical server, control instance placement
  Physical server with EC2 instance capacity fully dedicated to your use
  Allow your address compliance requirements and use your existing server-bound software licenses (per-socket, per-core, per-VM software licences)
  Purchasing Options:
  On-demand: pay per second for active dedicated host
  Reserverd: 1 or 3 years (no upfront, partial upfront, All upfront)
  Most expensive option
  Useful for software that have complicated licensing model (BYOL: bring your own licence)
  Or for companies that have strong regulatory or compliance need

- **Dedicated instances**
  no other customers will share your hardware
  instances run on hardware that's dedicated yo you
  May share hardware with other instances in same account
  No control over instance placment (can move hardware after Stop/ Start)
  Per instance Biling

- **Capacity Reservations**
  reserve capacity in a specifiv AZ for any duration
  Reserve On demand instances capacity in a specific AZ for any duration
  Always have acces to EC2 capacity when you need it
  No Time commitment (create/cancel anytime), **no billing discount**
  Combine with regional reserved instances and savings plan to benefit from biling discounts
  You're charged at On-demand rate wheter you run instances or not
  Suitable for short-term, uninterrupted workloadd that needs to be in a specifig AZ

Which purchasing option is right for me ?

(Resort analogy)

**On demand** : Coming and staying in resort whenever we like, we pay the full price

**Reserved** : like planning ahead and if we plan to stay for a long time (1 or 3 years) we may get a good discount

**Saving plans** : pay a certain amount per hour for certain period and stay in any room type (ie: king suite, sea view...)

**Spot instances** : the hotel allows people to big for the empty rooms and the highest bidder keeps the rooms. you can get kicked out at any time

**Dedicated Hosts** : We book an entire building of the resort

**Capacity Reservations** : You book a room for a period with full price even you don't stay in it

---

EC2 sport instances Requests

-Can get a discount of op to 90% compared to On-demand
-Define max spot price and get the instance while current sport price < max

- the hourly sport price varies on offer and capacity
- If the current sport price > your max price you can choose to stop or terminate your instance with a 2 minutes grace period

* Used for batch jobs, data analysis or workloads that are resilient to failures.
* Not great for critical jobs or databases

---

how to terminate spot instances ?

- Spot request:
  - Maximum price
  - desired number of instances
  - launch specification
  - request type : one time (as soon as ou spot request is fullfiled our instances are launched and our sport request will GO AWAY)| persistent (If our instances do get stop/interrupted based on the spot price then our spot request will go back into actions and will launch instances BACK)
  - valid from, valid until
- **You can only cancel spot instance request that are open, active or disabled.**
  - Canceling a spot request does NOT terminate instances
  - You must first cancel a spot request, and then terminate the associated spot instances

- Spot Fleets
  - Spot fleet = set of Spot instances + (optional) On-demand Instances
  * The spot fleet will try to meet the target capacity with price constaints
    - define possible launch pools: instance type (M5.large), OS, AZ
    - Can have multiple launch pools, so that the fleet can choose
    - Spot fleet stops launching instances when reaching capacity or max cost
  * Stategies to allocate Spot instances:
    - lowestPrice: from the pool with the lower price (cost optimization, short workload)
    - diversified: distributed across all pools (great for availability, long workloads)
    - capacityOptimized: pool with the optimal capacity for the number of instances
    - priceCapcityOptimied (reommended): pools with highest capacity available, then select the pool with the lowest price (best choice for most workloads)
  * **Spot Fleets allow us to automatically request Spot Instances with the lowest price**
