variable "region" {
  type = string
}

variable "cidr" {
  type = string

}

variable "publicsubnet" {
  type = list(string)

}

variable "privatesubnet" {
  type = list(string)
}

variable "aws_availibity_zones" {
  type = list(string)
}

variable "tags" {
  description = "map to each resource"
  type        = map(string)
  default = {
    Env             = "dev"
    Department      = "could"
    resource_owner  = "srinu_naik"
    resource_owner2 = "hcl"
  }


}