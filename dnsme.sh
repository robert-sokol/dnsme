#!/usr/bin/env bash

################################################################################
# dnsme is a Bash script used to get various records, geoip information etc.
# for a specific domain.
################################################################################

################################################################################
# FUNCTIONS
################################################################################

dns_help() {
  cat <<- EOF
dnsme: dnsme [DOMAIN]... [NAMESERVER]... [OPTION]...
Show DNS information for the specified domain.

  -g, --geoip   Provide GeoIP information from ip-api.com along with DNS information.
  -h, --help    Show this help section.
EOF
}

dns_parse_domain() {
  _domain="$(echo "$1" | sed -e 's+https\?://++')"
  _top_domain="$(echo "$_domain" | rev | cut -d '.' -f1-2 | rev)"
}
