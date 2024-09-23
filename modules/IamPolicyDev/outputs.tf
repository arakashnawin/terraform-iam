
output "policy" {
  value       = aws_iam_policy.dev.policy
  description = "`policy` exported from `aws_iam_policy`"
}
