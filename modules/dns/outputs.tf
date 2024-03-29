output "domain_name" {
  value = var.dns_on ? google_dns_managed_zone.dns_zone.*.dns_name : data.google_dns_managed_zone.dns_zone.*.dns_name
}

output "hosted_zone" {
  value = var.dns_on ? google_dns_managed_zone.dns_zone.*.name : data.google_dns_managed_zone.dns_zone.*.name
}

output "private_hosted_zone" {
  value = var.airgap ? google_dns_managed_zone.private_dns_zone.*.name : ["NA"]
}

output "dns_zone_name_servers" {
  value = google_dns_managed_zone.dns_zone.*.name_servers
}

output "main_yba_console_dns" {
  value = "https://${replace(google_dns_record_set.platform_ops[0].name, "/\\.$/", "")}"
}

output "fb_yba_console_dns" {
  # value = var.dns_on ? ("https://${replace(one(google_dns_record_set.platform_ops.*.name), "/\\.$/", "")}:8800") : "NA"
  value = length(google_dns_record_set.platform_ops.*) > 1 ? ("https://${replace(google_dns_record_set.platform_ops[1].name, "/\\.$/", "")}") : "NA"
}
