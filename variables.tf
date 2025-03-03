variable "route53_zones" {
  description = "List of zones"
  type = list(object({
    name              = string
    tags              = optional(map(string), {})
    dnssec_enabled    = optional(bool, false)
    delegation_set_id = optional(string, null)
    vpc               = optional(map(any), null)
    cmk_arn           = optional(string, null)
  }))
}

variable "route53_records" {
  description = "List of record objects"
  type = list(object({
    zone          = string
    name          = optional(string, "")
    type          = string
    ttl           = optional(number, null)
    records       = optional(list(string), null)
    alias         = optional(map(any), {})
    cidr_location = optional(string, "")
  }))
}

variable "route53_create_cmk" {
  description = "Whether to create a CMK or not"
  type        = bool
  default     = false
}

variable "cidr_collections" {
  description = "List of cidr collection objects"
  type        = map(any)
  default     = {}
}