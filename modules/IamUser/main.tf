# ----------------------------
# CONFIGURE OUR AWS CONNECTION
# ----------------------------
provider "aws" {
  region = "ap-south-1"
}

#--------------------
# IAM POLICY CREATION
#--------------------
module "IamPolicyDev" {
  source = "../IamPolicyDev"
}

module "IamPolicyQA" {
  source = "../IamPolicyQA"
}

# ---------------
# CREATE IAM USER
# ---------------
resource "aws_iam_user" "demo" {
  name                 = var.name
  path                 = var.path
  force_destroy        = var.force_destroy
  tags = {
    "testuser" = var.name
  }
}

# ---------------------
# CREATE IAM ACCESS KEY
# ---------------------
resource "aws_iam_access_key" "demo" {
  user    = aws_iam_user.demo.name
}

# -------------------------
# ATTACH POLICY TO THE USER
# -------------------------
resource "aws_iam_user_policy" "demo" {
  user = aws_iam_user.demo.name
  policy = var.devuser ? module.IamPolicyDev.policy : module.IamPolicyQA.policy
}
