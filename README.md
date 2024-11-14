# VSHN Terraform Module AWS Route53

This module does the following:

* Create route53 zones
* Create records for route53 zones
* Optionally enable DNSSec

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
  }
]

route53_create_cmk = true
```
