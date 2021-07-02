output "domain_name" {
  value = google_dns_managed_zone.dns_zone.*.dns_name
}

output "hosted_zone" {
  value = google_dns_managed_zone.dns_zone.*.name
}

output "dns_zone_name_servers" {
  value = google_dns_managed_zone.dns_zone.*.name_servers
}

output "replicated_console_dns" {
  value = var.dns_on ? ("https://${replace(one(google_dns_record_set.platform_ops.*.name), "/\\.$/", "")}:8800") : "NA"
}
