# IAM & AWS CLI

## IAM: introduction: Users, Groups, Policies

---

- identity acces management
- root account (default)
- Create users (one user = one person within an org)
- Groups (contain users, not other group)
- User not need to be part of a group
- User can belong to multiple groups
- Implemented via Json document

Important for secuity : apply least privilege principle

---

- Create IAM user via AWS console
- Apply policies to one user directly via group during the creation process
- Can login with 2 account at the same time

---

- policies inheritance
- one user multiple policies
- ## differents ways to implement :
- iam policies structure :
  - version
  - id: identifier for the policy (optional)
  - statement: one or more
    - Sid: indentifier for statment (optional)
    - Effect: whether the statment allows or denies acces
    - Principal: account/suer/role to which this policy appplied to
    - Action : list of actions this policy allows or denies
    - Resources: list of resources to which the actions applied to

---

- Password Policy
  - minimum password lenght
  - special char
  - change passwd after some time...
  - prevent passwd reuse..
- MFA (multi factor authentication)
  - protect all iam and root
  - use mfa on top of the passwd
  - smthg you know and you have
- Virtual MFA device: (google authenticator, Authy...)
- Universal 2nd Factor (U2F) security key : physical device (provided by 3rd party)
- Hardware key fob MFA
- AWS GovCloud (US)

---

- aws console
- aws cli (build sur AWS SDK python (boto))
- aws skd

---

- aws role : role pour service AWS (assign permissions to AWS services with IAM Roles)
- Some Services will ne to perform actions on your behalf
