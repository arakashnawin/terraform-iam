variable "devuser" {
  description = "Whether to create the dev user"
  type        = bool
  default     = false
}

variable "qauser" {
  description = "Whether to create the dev user"
  type        = bool
  default     = false
}

variable "name" {
  description = "Desired name for the IAM user"
  type        = string
  default     = "demouser"
}

variable "path" {
  description = "Desired path for the IAM user"
  type        = string
  default     = "/"
}

variable "force_destroy" {
  description = "Allow force destroy"
  type        = bool
  default     = true
}

