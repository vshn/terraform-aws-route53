# VSHN Terraform Module AWS Route53

This module does the following:

* Create route53 zones
* Create records for route53 zones

## Example usage

```hcl
module "route53" {
  source = "git::ssh://git@git.vshn.net/vshn-terraform/module-aws-route53.git?ref=v1.0.0"
  route53_zones = var.route53_zones
  route53_recors = var.route53_records
}
```

```hcl
route53_zones = {
    name    = "vshn.ch"
    comment = "VSHN CH zone"
    tags    = ["vshn.ch", "terraform"]
}

route53_records = [
  {
    zone = "vshn.ch"
    name = "www"
    type = "A"
    ttl  = 300
    records = ["1.2.3.4"]
  }
]
```
