variable "region" {
  default = "us-west-2"

}

# For Helm Chart
variable "helm_chart_version" {
  type = string

}

variable "namespace" {
  type = string

}

variable "client_id" {
  type = string

}

variable "client_secret" {
  type      = string
  sensitive = true

}

variable "redirect_uri" {
  type = string

}

variable "signing_key" {
  type      = string
  sensitive = true

}

variable "gitlab_url" {
  type = string

}

variable "workspace_domain_cert" {
  type      = string
  sensitive = true

}

variable "workspace_domain_key" {
  type      = string
  sensitive = true

}

variable "wwildcard_domain_cert" {
  type      = string
  sensitive = true

}

variable "wildcard_domain_key" {
  type      = string
  sensitive = true

}

variable "ingress_class" {
  type = string

}

variable "gitlab_workspaces_proxy_domain" {
  type = string

}

variable "gitlab_workspaces_wildcard_domain" {
  type = string

}

variable "ssh_host_key" {
  type      = string
  sensitive = true

}

