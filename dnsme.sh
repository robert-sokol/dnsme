#!/usr/bin/env bash

################################################################################
# dnsme is a Bash script used to get various records, geoip information etc.
# for a specific domain.
################################################################################

################################################################################
# VARIABLES
################################################################################

_dns_record_types=(NS CNAME TXT SRV AAAA SOA)
_dns_resolver=8.8.8.8

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
  _dns_resolver="$1"
}

dns_lookup() {
  echo -e "\n=== A RECORDS ===\n"
  _A_record="$(dig @"$_dns_resolver" "$_domain" +short)"
  echo "$_A_record"

  echo -e "\n=== MX RECORDS ===\n"
  dig @"$_dns_resolver" "$_domain" mx +short

  echo -e "\n=== PTR RECORDS ===\n"
  dig -x "$_A_record" +short

  for _dns_type in "${_dns_record_types[@]}"; do
    echo -e "\n=== $_dns_type RECORDS ===\n"
    dig @"$_dns_resolver" "$_domain" "$_dns_type" +short
  done
}

geoip_lookup() {
  curl "http://ip-api.com/line/$_domain?fields=query,country,countryCode,regionName,timezone,isp,org"
}

dns_parse_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      
      -d|--domain)
        if [[ "$2" == *.* ]]; then
          dns_parse_domain "$2"
        else
          echo "$2 is not a valid domain, exiting." && exit 1
        fi
        shift 2
      ;;

      -r|--resolver)
        if [[ "$2" == *.* || "$2" =~ ^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
          dns_parse_resolver "$2"
        else
          echo "$2 is not a valid domain or IP, exiting." && exit 1
        fi
        shift 2
      ;;

      -g|--geoip)
        _geoip=true
        shift
      ;;

      -w|--whois)
        _whois=true
        shift
      ;;
      
      -h|--help)
        dns_help
        exit 0
      ;;

      *)
        echo -e "$1 is not a valid argument, exiting.\n"
        dns_help && exit 1
      ;;
    esac
  done
}

################################################################################

dns_parse_options "$@"
dns_lookup
if [[ "$_geoip" == true ]]; then
  echo -e "\n=== GEOIP INFORMATION ===\n"
  geoip_lookup
fi
if [[ "$_whois" == true ]]; then
  echo -e "\n=== WHOIS INFORMATION ===\n"
  whois "$_top_domain"
fi
