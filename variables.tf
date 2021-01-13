########################################
# General Vars
########################################

variable "name" {
  default     = "1password-scim"
  description = "Name of this deployment (e.g., prod-1password-scim)"
  type        = string
}

variable "scim_host_name" {
  description = "Fully qualified host name (e.g., prod-1password-scim.mycompany.io)"
  type        = string
}

variable "scim_secret_name" {
  description = "Friendly name of manually created secret"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}


########################################
# ASG/Instance Vars
########################################

variable "ami_id" {
  default     = null
  description = "AMI to build on (must be Ubuntu, `ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*` used if this is null)"
  type        = string
}

variable "asg_additional_iam_policies" {
  default     = []
  description = "Additional IAM policies to attach to the  ASG instance profile"
  type        = list(string)
}

variable "asg_additional_security_groups" {
  default     = []
  description = "Additional security group IDs to attach to ASG instances"
  type        = list(string)
}

variable "asg_additional_user_data" {
  default     = ""
  description = "Additional User Data to attach to the launch template"
  type        = string
}

variable "asg_allow_outbound_egress" {
  default     = true
  description = "whether or not the default SG should allow outbound egress"
  type        = bool
}

variable "asg_desired_capacity" {
  default     = 1
  description = "The number of Amazon EC2 instances that should be running in the group."
  type        = number
}

variable "asg_instance_type" {
  default     = "t3a.micro"
  description = "Instance type for scim app"
  type        = string
}

variable "asg_keypair" {
  default     = null
  description = "Optional keypair to associate with instances"
  type        = string
}

variable "asg_max_size" {
  default     = 2
  description = "Maximum number of instances in the autoscaling group"
  type        = number
}

variable "asg_min_size" {
  default     = 1
  description = "Minimum number of instances in the autoscaling group"
  type        = number
}

########################################
# Networking Vars
########################################

variable "access_log_bucket" {
  description = "Bucket name to route ELB access logs to"
  type        = string
}

variable "access_log_prefix" {
  description = "Bucket prefix to route ELB access logs to"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of ACM Certificate to use for ELB"
  type        = string
}

variable "elb_allowed_cidrs" {
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs that can reach the ELB (must be reachable by the SSO provider)"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets to associate SCIM instances with (specify 1 or more)"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets to associate ELB with (specify at least 2)"
  type        = list(string)
}

variable "route53_zone_id" {
  description = "Zone ID to register Route53 entry in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

########################################
# SCIM Vars (these shouldn't need set)
########################################

variable "scim_cache_dns_name" {
  default     = "localhost"
  description = "Redis cache DNS name (this changes the port SCIM tries to reach redis on but does not change the address redis listens on)"
  type        = string
}

variable "scim_cache_port" {
  default     = "6379"
  description = "Redis cache port (this changes the port SCIM tries to reach redis on but does not change the port redis listens on)"
  type        = string
}

variable "scim_group" {
  default     = "nogroup"
  description = "unprivileged group to run op-scim service"
  type        = string
}

variable "scim_path" {
  default     = "/var/lib/op-scim"
  description = "op-scim working directory path (e.g: /var/lib/op-scim)"
  type        = string
}

variable "scim_port" {
  default     = 3002
  description = "Port SCIM should listen on"
  type        = number
}

variable "scim_repo" {
  default     = "deb https://apt.agilebits.com/op-scim/ stable op-scim"
  description = "Repo/package to pull `op-scim` from"
  type        = string
}

variable "scim_session_path" {
  default     = "/var/lib/op-scim/.op/scimsession"
  description = "op-scim scimsession file path (e.g: /var/lib/op-scim/.op/scimsession)"
  type        = string
}

variable "scim_user" {
  type        = string
  description = "unprivileged user to run op-scim service"
  default     = "op-scim"
}
