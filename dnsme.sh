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
  -w, --whois     Print whois information for the domain.
  -h, --help      Show this help section.
EOF
}

dns_parse_domain() {
  _domain="${1#*\/\/}" #strip protocol prefix if any.
  _top_domain="$(echo "$_domain" | rev | cut -d '.' -f1-2 | rev)"
}

dns_parse_resolver() {
  _dns_resolver="$(1:-8.8.8.8)"
}

dns_lookup() {
  echo -e "\n=== A RECORDS ===\n"
  _A_record="$(dig @"$_dns_resolver" "$_domain" +short)"
  echo "$_A_record"

  echo -e "\n=== MX RECORDS ===\n"
  dig @"$_dns_resolver" "$_domain" mx +short

  echo -e "\n=== PTR RECORDS ===\n"
  dig -x "$_A_record" +short

  echo -e "\n=== OTHER RECORDS ===\n"
  for _dns_type in "${_dns_record_types[@]}"; do
    echo -e "=== $_dns_type RECORDS \n"
    dig @"_dns_resolver" "$_domain" "$_dns_type" +short
  done
}

geoip_lookup() {
  curl "http://ip-api.com/line/$_domain?fields=query,country,countryCode,regionName,timezone,isp,org"
}

################################################################################

