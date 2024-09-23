provider "aws" {
  region = "ap-south-1"
}

#-----------------------------------------------
# GENERATE AN IAM POLICY DOCUMENT IN JSON FORMAT
#-----------------------------------------------
data "aws_iam_policy_document" "demoqa" {
  #- Read Only Access -#
  statement {
    effect    = "Allow"
    actions   = ["elasticbeanstalk:Check*",
        "elasticbeanstalk:Describe*",
        "elasticbeanstalk:List*",
        "elasticbeanstalk:RequestEnvironmentInfo",
        "elasticbeanstalk:RetrieveEnvironmentInfo",
        "ec2:Describe*",
        "elasticloadbalancing:Describe*",
        "autoscaling:Describe*",
        "cloudwatch:Describe*",
        "cloudwatch:List*",
        "cloudwatch:Get*",
        "s3:Get*",
        "s3:List*",
        "sns:Get*",
        "sns:List*",
        "rds:Describe*",
        "cloudformation:Describe*",
        "cloudformation:Get*",
        "cloudformation:List*",
        "cloudformation:Validate*",
        "cloudformation:Estimate*",
                ]
    resources = ["*"]
  }
}

# -------------------
# CREATE A IAM POLICY
# -------------------
resource "aws_iam_policy" "qa" {
  name = "qa_policy"
  path = "/"
  policy = data.aws_iam_policy_document.demoqa.json
}

