resource "aws_route53_zone" "n8n" {
  name = var.domain
  tags = local.common_tags
}

resource "aws_route53_record" "n8n_A" {
  zone_id = aws_route53_zone.n8n.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.n8n.dns_name
    zone_id                = aws_lb.n8n.zone_id
    evaluate_target_health = false
  }
}

#
# Add a DNS resolver firewall to limit outbound DNS queries
#
module "resolver_dns" {
  source           = "github.com/cds-snc/terraform-modules//resolver_dns?ref=v10.5.2"
  vpc_id           = module.vpc.vpc_id
  firewall_enabled = true

  allowed_domains = [
    "*.amazonaws.com.",      # AWS
    "*.azure.com.",          # Azure OpenAI
    "*.azure-api.net.",      # Azure OpenAI
    "*.canada.ca.",          # Government of Canada
    "*.cds-snc.ca.",         # Government of Canada
    "*.cdssandbox.xyz.",     # Government of Canada
    "*.gc.ca.",              # Government of Canada
    "*.microsoft.com.",      # Azure OpenAI
    "*.trafficmanager.net.", # Azure OpenAI
    "tiktoken.pages.dev.",   # OpenAI token counting
  ]

  billing_tag_value = var.billing_code
}
