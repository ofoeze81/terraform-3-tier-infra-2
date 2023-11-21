variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr range"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = list(string)
  description = "subnets cidr range"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "availability zone"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  type        = map(any)
  description = "tags"
}