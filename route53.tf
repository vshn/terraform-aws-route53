resource "aws_route53_zone" "zones" {
  for_each = var.route53_zones

  name          = each.key
  comment       = lookup(each.value, "comment", null)
  force_destroy = lookup(each.value, "force_destroy", false)

  delegation_set_id = lookup(each.value, "delegation_set_id", null)

  dynamic "vpc" {
    for_each = try(tolist(lookup(each.value, "vpc", [])), [lookup(each.value, "vpc", {})])

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = lookup(vpc.value, "vpc_region", null)
    }
  }

  tags = lookup(each.value, "tags", [])
}

resource "aws_route53_record" "records" {
  for_each = {
    for index, record in var.route53_records : index => record
  }
  zone_id = aws_route53_zone.zones[each.value.zone].id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = try(each.value.records, null)

  dynamic "alias" {
    for_each = length(keys(lookup(each.value, "alias", {}))) == 0 ? [] : [true]

    content {
      name                   = each.value.alias.name
      zone_id                = aws_route53_zone.zones[each.value.zone].id
      evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
    }
  }

  depends_on = [
    aws_route53_zone.zones
  ]
}
