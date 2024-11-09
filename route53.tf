# KSK must be in us-east-1 for use with DNSSec (see https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec-cmk-requirements.html)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = {
      Managed_By   = "VSHN"
      Git_Repo_URL = "https://git.vshn.net/pistor/mercanto-dns-terraform"
      Product      = "DNS"
    }
  }
}

resource "aws_route53_zone" "zones" {
  for_each = {
    for index, zone in var.route53_zones : zone.name => zone
  }

  name          = each.value.name
  force_destroy = false

  delegation_set_id = each.value.delegation_set_id

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

resource "aws_kms_key" "route53" {
  provider                 = aws.us-east-1
  count                    = var.route53_create_cmk ? 1 : 0
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify",
        ],
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Resource = "*"
        Sid      = "Allow Route 53 DNSSEC Service",
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = [data.aws_caller_identity.current.arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_route53_key_signing_key" "key_signing_keys" {
  for_each = {
    for index, zone in var.route53_zones : zone.name => zone if zone.dnssec_enabled
  }

  hosted_zone_id             = aws_route53_zone.zones[each.value.name].id
  key_management_service_arn = try(coalesce(each.value.cmk_arn), aws_kms_key.route53[0].arn)
  name                       = each.key
}

resource "aws_route53_hosted_zone_dnssec" "dnssec_zones" {
  for_each = {
    for index, zone in var.route53_zones : zone.name => zone if zone.dnssec_enabled
  }

  depends_on = [
    aws_route53_key_signing_key.key_signing_keys
  ]
  hosted_zone_id = aws_route53_key_signing_key.key_signing_keys[each.value.name].hosted_zone_id
}