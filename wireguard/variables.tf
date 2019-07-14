variable "ssh_key" {
  type        = string
  description = "EC2 SSH key"
  default     = ""
}

variable "peers" {
  type        = number
  description = "The number of peer configurations to create"
  default     = "1"
}
