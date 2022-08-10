variable "domain_fqdn" {
  description = "The fully qualified name for the target domain, such as corp.example.com"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of resolver endpoint"
  type        = string
}

variable "dns_ip1" {
  description = "DNS IP address for target domain"
  type        = string
}

variable "dns_ip2" {
  description = "DNS IP address for target domain"
  type        = string
}

variable "resolver_endpoint_id" {
  description = "Endpoint ID of the R53 resolver the rule will be associated with"
  type = string
}