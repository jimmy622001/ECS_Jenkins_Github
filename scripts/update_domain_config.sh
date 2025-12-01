#!/bin/bash

# Update the DOMAIN_CONFIG_JSON line in setup_secrets.sh to include failover_domain
sed -i 's|DOMAIN_CONFIG_JSON='"'"'{"domain_name":"'"'"'$DOMAIN_NAME'"'"'"}'"'"'|DOMAIN_CONFIG_JSON='"'"'{"domain_name":"'"'"'$DOMAIN_NAME'"'"'","failover_domain":"'"'"'$FAILOVER_DOMAIN'"'"'"}'"'"'|g' setup_secrets.sh