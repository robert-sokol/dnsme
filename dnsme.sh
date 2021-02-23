#!/usr/bin/env bash

################################################################################
# dnsme is a Bash script used to get various records, geoip information etc.
# for a specific domain.
################################################################################

################################################################################
# VARIABLES
################################################################################

_dns_record_types=(NS CNAME TXT SRV AAAA SOA)

################################################################################
# FUNCTIONS
################################################################################

dns_help() {
  cat <<- EOF
dnsme: dnsme [DOMAIN]... [NAMESERVER]... [OPTION]...
Show DNS information for the specified domain.
  -d, --domain    Select the domain for the query.
  -r, --resolver  Select specific resolver for the query.
  -g, --geoip     Provide GeoIP information from ip-api.com along with DNS information.
  -h, --help      Show this help section.
  -w, --whois     Print whois information for the domain.
EOF
}

dns_parse_domain() {
  _domain="${1#*\/\/}"
  _top_domain="$(echo "$_domain" | rev | cut -d '.' -f1-2 | rev)"
}

dns_parse_resolver() {
  _dns_resolver="$(1:-8.8.8.8)"
}

dns_lookup() {
  echo -e "=== A RECORDS ===\n"
  dig @"$_dns_resolver" "$_domain" +short

  echo -e "=== MX RECORDS ===\n"
  dig @"$_dns_resolver" "$_domain" mx +short

  echo -e "=== OTHER RECORDS ===\n"
  for _dns_type in "${_dns_record_types[@]}"; do
    echo -e "=== $_dns_type RECORDS \n"
    dig @"_dns_resolver" "$_domain" "$_dns_type" +short
  done
}

geoip_lookup() {
  curl "http://ip-api.com/line/$_domain?fields=query,country,countryCode,regionName,timezone,isp,org"
}

################################################################################
#
################################################################################
