
# Terraform IAM User and Policy Management

This project demonstrates how to manage AWS IAM users and policies using Terraform. It includes modules to define custom policies for development and quality assurance (QA) users, as well as the creation of IAM users and their associated policies.

## Prerequisites

- Terraform installed on your local machine.
- AWS account with appropriate IAM permissions (to create users, policies, etc.).
- AWS CLI configured with access credentials.
- Ensure the AWS region is set to `ap-south-1` in your environment.

## Project Structure

- `modules/IamPolicyDev`: Defines the IAM policy for development users.
- `modules/IamPolicyQA`: Defines the IAM policy for QA users.
- `modules/IamUser`: Manages IAM user creation and policy attachment.

### File Descriptions

#### `modules/IamPolicyDev/main.tf`

This file defines a custom IAM policy for development users. The policy has two primary rules:

1. **Deny Actions**: Denies actions such as creating, rebuilding, and deleting environments in AWS Elastic Beanstalk.
2. **Allow EC2 Actions**: Allows the user to launch EC2 instances of type `t2.micro` and `t2.small` in a specific subnet.

```hcl
provider "aws" {
  region = "ap-south-1"
}

data "aws_iam_policy_document" "demo" {
  statement {
    effect    = "Deny"
    actions   = [
      "elasticbeanstalk:CreateEnvironment",
      "elasticbeanstalk:RebuildEnvironment",
      "elasticbeanstalk:TerminateEnvironment"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:ap-south-1:532663929782:instance/*",
      "arn:aws:ec2:ap-south-1:532663929782:subnet/subnet-0ba82347"
    ]
    condition {
      test = "StringEquals"
      variable = "ec2:InstanceType"
      values = ["t2.micro", "t2.small"]
    }
  }
}

resource "aws_iam_policy" "dev" {
  name   = "dev_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.demo.json
}
```

#### `modules/IamPolicyQA/main.tf`

This file defines a read-only IAM policy for QA users. The policy grants read access to various services such as Elastic Beanstalk, EC2, Elastic Load Balancer, Auto Scaling, CloudWatch, S3, SNS, RDS, and CloudFormation.

```hcl
provider "aws" {
  region = "ap-south-1"
}

data "aws_iam_policy_document" "demoqa" {
  statement {
    effect    = "Allow"
    actions   = [
      "elasticbeanstalk:Check*", 
      "elasticbeanstalk:Describe*",
      "ec2:Describe*",
      "s3:Get*", 
      "s3:List*"
      # and many more
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "qa" {
  name   = "qa_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.demoqa.json
}
```

#### `modules/IamUser/main.tf`

This file manages IAM user creation, policy attachment, and IAM access key generation. It also integrates the development and QA IAM policies defined in the respective modules.

- Creates IAM users based on whether `devuser` or `qauser` is set to true.
- Attaches the appropriate IAM policy to the user (Development or QA).
- Optionally creates an IAM access key for the user.

```hcl
provider "aws" {
  region = "ap-south-1"
}

module "IamPolicyDev" {
  source = "../IamPolicyDev"
}

module "IamPolicyQA" {
  source = "../IamPolicyQA"
}

resource "aws_iam_user" "demo" {
  name          = var.name
  path          = var.path
  force_destroy = var.force_destroy
  tags = {
    "testuser" = var.name
  }
}

resource "aws_iam_access_key" "demo" {
  user = aws_iam_user.demo.name
}

resource "aws_iam_user_policy" "demo" {
  user   = aws_iam_user.demo.name
  policy = var.devuser ? module.IamPolicyDev.policy : module.IamPolicyQA.policy
}
```

## Variables

#### `modules/IamUser/variables.tf`

- `devuser`: A boolean flag to specify whether to create a development user.
- `qauser`: A boolean flag to specify whether to create a QA user.
- `name`: The desired name for the IAM user.
- `path`: The IAM path for the user (default is `/`).
- `force_destroy`: Whether to allow force destruction of the IAM user.
  
### Example:

```hcl
variable "devuser" {
  description = "Whether to create the dev user"
  type        = bool
  default     = false
}

variable "qauser" {
  description = "Whether to create the QA user"
  type        = bool
  default     = false
}
```

## Usage

### Step 1: Initialize Terraform

1. Navigate to the directory where the `main.tf` file for user management is located:
   ```bash
   cd modules/IamUser
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

### Step 2: Customize Variables

In `variables.tf`, configure the following:

- Set `devuser` or `qauser` to `true` depending on which user you'd like to create.
- Set the `name`, `path`, and `force_destroy` variables as per your needs.

### Step 3: Apply the Configuration

1. Review the plan:
   ```bash
   terraform plan
   ```

2. Apply the changes:
   ```bash
   terraform apply
   ```

   This will create the IAM user, assign the appropriate policy (development or QA), and optionally create access keys.

### Step 4: Cleanup

To destroy the resources created by Terraform, run:

```bash
terraform destroy
```

## Outputs

Each module exports its created policy:

- **Development Policy**: Available through the `IamPolicyDev` module.
- **QA Policy**: Available through the `IamPolicyQA` module.

```hcl
output "policy" {
  value       = aws_iam_policy.dev.policy
  description = "`policy` exported from `aws_iam_policy`"
}
```

## Additional Notes

- **IAM Policy Management**: The project modularizes IAM policy management for both development and QA users. 
- **User Flexibility**: The `devuser` and `qauser` flags allow you to choose which users and policies to create dynamically.
- **Policy Attachment**: IAM policies are attached to users based on their role (development or QA).

## Resources

- [Terraform IAM Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)
- [AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
