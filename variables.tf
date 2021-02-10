variable "github_token" {
  type = string
}

variable "project" {
  type = string
}

variable "zone" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "min_replicas" {
  default = 7
}

variable "max_replicas" {
  default = 21
}
