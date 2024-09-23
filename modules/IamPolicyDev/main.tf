provider "aws" {
  region = "ap-south-1"
}

#-----------------------------------------------
# GENERATE AN IAM POLICY DOCUMENT IN JSON FORMAT
#-----------------------------------------------
data "aws_iam_policy_document" "demo" {
  #- Deny Creating/Rebuild/Deleting -#
  statement {
    effect    = "Deny"
    actions   = ["elasticbeanstalk:CreateEnvironment",
            "elasticbeanstalk:RebuildEnvironment",
            "elasticbeanstalk:TerminateEnvironment"
                ]
    resources = ["*"]
  }
  
  #- Allow Machines to be created of the type T2.Micro/Small & in the specific Subnet -#
  statement {
    effect    = "Allow"
    actions   = ["ec2:RunInstances"]
    resources = [
         "arn:aws:ec2:ap-south-1:532663929782:instance/*",
         "arn:aws:ec2:ap-south-1:532663929782:subnet/subnet-0ba82347"
         #arn:partition:service:region:account-id:resource-type/resource-id#

      ]
    condition { 
         test = "StringEquals"
         variable = "ec2:InstanceType"
         values = ["t2.micro","t2.small"]
    }
  }
}

# -------------------
# CREATE A IAM POLICY
# -------------------
resource "aws_iam_policy" "dev" {
  name = "dev_policy"
  path = "/"
  policy = data.aws_iam_policy_document.demo.json
}

