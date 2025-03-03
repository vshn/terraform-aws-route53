# VSHN Terraform Module AWS Route53

This module does the following:

* Create route53 zones
* Create records for route53 zones
* Optionally enable DNSSec
* Optionally create CIDR collections and locations
* Optionally configure [CIDR Routing Policies](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-ipbased.html)

## Example usage

```hcl
module "route53" {
  source = "git::ssh://git@git.vshn.net/vshn-terraform/module-aws-route53.git?ref=v1.0.0"
  route53_zones = var.route53_zones
  route53_records = var.route53_records
  route53_create_cmk = var.route53_create_cmk
}
```

```hcl

cidr_collections = {
  clouds = {
    cidr_locations = {
      cloudscale = ["185.72.238.0/23", "185.79.232.0/22"],
      exoscale   = ["85.217.184.0/23"]
    }
  }
}

route53_zones = [
  {
    name    = "vshn.ch"
    comment = "VSHN CH zone"
    tags    = {
      source =  "terraform"
    }
    dnssec_enabled = true
  }
]

route53_records = [
  {
    zone = "vshn.ch"
    name = "www"
    type = "A"
    ttl  = 300
    records = ["1.2.3.4"]
    cidr_location = "cloudscale"
  },
  {
    zone = "vshn.ch"
    name = "blog"
    type = "A"
    ttl  = 300
    records = ["4.3.2.1"]
  }
]

route53_create_cmk = true
```
