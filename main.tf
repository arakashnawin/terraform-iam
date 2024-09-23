#----------------------
# IAM DEV USER CREATION
#----------------------
#module "iam_dev_user" {
#  source  = "./modules/IamUser"
#  devuser = "1"
#  name    = "devuser"
#}

#---------------------
# IAM QA USER CREATION
#---------------------
module "iam_qa_user" {
  source = "./modules/IamUser"
  qauser = "1"
  name    = "testuser"
}

