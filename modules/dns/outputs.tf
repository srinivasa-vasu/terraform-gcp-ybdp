output "domain_name" {
  value = google_dns_managed_zone.dns_zone.*.dns_name
}

output "hosted_zone" {
  value = google_dns_managed_zone.dns_zone.*.name
}

output "dns_zone_name_servers" {
  value = google_dns_managed_zone.dns_zone.*.name_servers
}

output "main_replicated_console_dns" {
  value = "https://${replace(google_dns_record_set.platform_ops[0].name, "/\\.$/", "")}:8800"
}

output "fb_replicated_console_dns" {
  # value = var.dns_on ? ("https://${replace(one(google_dns_record_set.platform_ops.*.name), "/\\.$/", "")}:8800") : "NA"
  value = length(google_dns_record_set.platform_ops.*) > 1 ? ("https://${replace(google_dns_record_set.platform_ops[1].name, "/\\.$/", "")}:8800") : "NA"
}
