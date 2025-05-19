variable "environment" {
  default = "gitlab-runners-autoscaler-default"

}

variable "gitlab_runners_ci_boundary" {
  default = ""

}

variable "cache_bucket_name" {
  default = ""

}

variable "default_image" {
  default = "ubuntu"

}

variable "policy_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::<acount_id>:policy/gitlab-runners-cache-read"
  ]

}

variable "runner_instance_type" {
  default = ""

}

variable "worker_instance_types" {
  default = ""

}

variable "max_concurrency" {
  default = "20"

}

variable "idle_machine_count" {
  default = "1"

}

variable "build_type" {
  default = "x86_64"

  validation {
    condition     = contains(["arm64", "x86_64"], var.build_type)
    error_message = "Allowed values for build_type are \"arm64\" or \"x86_64\"."
  }

}

variable "aws_subnet_ids" {
  default = ""

}
variable "aws_vpc_id" {
  default = ""
}

variable "aws_security_group_id" {
  default = ""

}

variable "gitlab_runner_token" {
  default = ""

}

variable "gitlab_runner_url" {
  default = ""

}