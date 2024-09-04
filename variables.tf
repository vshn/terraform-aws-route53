variable "route53_zones" {
  description = "Map of zones"
  type        = map(any)
}

variable "route53_records" {
  description = "List of record objects"
  type = list(object({
    zone    = string
    name    = optional(string, "")
    type    = string
    ttl     = optional(number, 3600)
    records = optional(list(string), [])
  }))
}
