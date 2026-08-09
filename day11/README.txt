AWS Elastic Beanstalk Blue/Green Deployment with Terraform

Overview

This project demonstrates a Blue/Green deployment using AWS Elastic Beanstalk, Terraform, S3, IAM, and AWS CLI.

A single Elastic Beanstalk application contains two environments:

🔵 Blue → Application Version 1
🟢 Green → Application Version 2

Both environments share the same IAM roles, S3 bucket, and Elastic Beanstalk application.

Production traffic is switched from Blue to Green using an Elastic Beanstalk CNAME swap.


Architecture


                         Terraform
                            │
                            ▼
                 ┌─────────────────────┐
                 │   Shared Resources  │
                 └──────────┬──────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
         IAM Roles      S3 Bucket     EB Application
              │             │             │
              │       ┌─────┴─────┐       │
              │       │           │       │
              │    app-v1.zip  app-v2.zip │
              │       │           │       │
              │       ▼           ▼       │
              │   ┌───────┐   ┌───────┐  │
              └──►│ BLUE  │   │ GREEN │◄─┘
                  │  v1   │   │  v2   │
                  └───┬───┘   └───┬───┘
                      │           │
                      │ CNAME SWAP│
                      └─────┬─────┘
                            ▼
                     Production URL
					 

### AWS Resources

Shared
======
Elastic Beanstalk Application
S3 Bucket
Elastic Beanstalk Service Role
EC2 IAM Role
EC2 Instance Profile


Blue Environment
================

app-v1.zip
    ↓
Application Version v1
    ↓
Blue Environment

Green Environment
=================

app-v2.zip
    ↓
Application Version v2
    ↓
Green Environment


Elastic Beanstalk manages the underlying EC2, Auto Scaling, and Application Load Balancer resources.

Project Structure
day11/
├── main.tf
├── roles.tf
├── blue.tf
├── green.tf
├── app-v1/
│   └── app-v1.zip
├── app-v2/
│   └── app-v2.zip
└── README.md

Blue runs the first application version:

app-v1.zip → S3 → EB Application Version → Blue

Deploy Green - Green runs the updated application:

app-v2.zip → S3 → EB Application Version → Green

Green is tested independently before production traffic is moved.

4. Swap production traffic
aws elasticbeanstalk swap-environment-cnames `
  --source-environment-name "ebcenv-name" `
  --destination-environment-name "green-ebsenv-name" `
  --region "ap-south-1"

After the swap:

Production URL
      │
      ▼
   GREEN
   v2.0

The previous Blue environment remains available for rollback.

IAM

Two separate IAM roles are used:
The service role is assumed by Elastic Beanstalk to perform service-level operations.

Elastic Beanstalk
      │
      ▼
Elastic Beanstalk Service Role (ebs-service-role)
        │
        ├── AWSElasticBeanstalkEnhancedHealth
        └── AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy


The EC2 role is used by EC2 instances running inside the Elastic Beanstalk environments.

EC2 Instance 
	│ 
	▼ 
EC2 Instance Profile (ebs_test_profile) 
    │ 
	▼ 
EC2 Instance Role (ebs_ec2_role) 
    │ 
	├── AWSElasticBeanstalkWebTier
	├── AWSElasticBeanstalkWorkerTier 
	└── AWSElasticBeanstalkMulticontainerDocker


Key Concepts
============

Terraform Infrastructure as Code
AWS Elastic Beanstalk
Blue/Green deployment
Elastic Beanstalk Application Versions
S3 application artifacts
IAM roles and instance profiles
Auto Scaling and Application Load Balancer
CNAME-based traffic switching
Rollback using the previous environment

### Listing Elastic Beanstalk IAM Policies

The following AWS CLI command lists AWS-managed IAM policies related to Elastic Beanstalk. 
This can be used to identify the appropriate policies for the Elastic Beanstalk service role or EC2 instance role.

```powershell
aws iam list-policies `
  --scope AWS `
  --query "Policies[?contains(PolicyName, 'ElasticBeanstalk')].[PolicyName,Arn]" `
  --output table
```

This returns the policy name and ARN in a table format, making it easier to identify the required Elastic Beanstalk policies.

--------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                     ListPolicies                                                                     |
+------------------------------------------------------+-----------------------------------------------------------------------------------------------+
|  AWSElasticBeanstalkWebTier                          |  arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier                                           |
|  AWSElasticBeanstalkWorkerTier                       |  arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier                                        |
|  AWSElasticBeanstalkMulticontainerDocker             |  arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker                              |
|  AWSElasticBeanstalkEnhancedHealth                   |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth                       |
|  AWSElasticBeanstalkService                          |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService                              |
|  AWSElasticBeanstalkCustomPlatformforEC2Role         |  arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role                          |
|  AWSElasticBeanstalkServiceRolePolicy                |  arn:aws:iam::aws:policy/aws-service-role/AWSElasticBeanstalkServiceRolePolicy                |
|  AWSElasticBeanstalkMaintenance                      |  arn:aws:iam::aws:policy/aws-service-role/AWSElasticBeanstalkMaintenance                      |
|  AWSElasticBeanstalkManagedUpdatesServiceRolePolicy  |  arn:aws:iam::aws:policy/aws-service-role/AWSElasticBeanstalkManagedUpdatesServiceRolePolicy  |
|  AWSElasticBeanstalkRoleWorkerTier                   |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleWorkerTier                       |
|  AWSElasticBeanstalkRoleSNS                          |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleSNS                              |
|  AWSElasticBeanstalkRoleRDS                          |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleRDS                              |
|  AWSElasticBeanstalkRoleECS                          |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleECS                              |
|  AWSElasticBeanstalkRoleCore                         |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCore                             |
|  AWSElasticBeanstalkRoleCWL                          |  arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCWL                              |
|  AWSElasticBeanstalkReadOnly                         |  arn:aws:iam::aws:policy/AWSElasticBeanstalkReadOnly                                          |
|  AdministratorAccess-AWSElasticBeanstalk             |  arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk                              |
|  AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy |  arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy                  |
|  AWSElasticBeanstalkEKSObservability                 |  arn:aws:iam::aws:policy/AWSElasticBeanstalkEKSObservability                                  |
|  AWSElasticBeanstalkEKSTagging                       |  arn:aws:iam::aws:policy/AWSElasticBeanstalkEKSTagging                                        |
|  AWSElasticBeanstalkEKSImageBuild                    |  arn:aws:iam::aws:policy/AWSElasticBeanstalkEKSImageBuild                                     |
+------------------------------------------------------+-----------------------------------------------------------------------------------------------+



