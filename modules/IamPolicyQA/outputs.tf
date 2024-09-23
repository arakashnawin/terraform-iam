
output "policy" {
  value       = aws_iam_policy.qa.policy
  description = "`policy` exported from `aws_iam_policy`"
}
