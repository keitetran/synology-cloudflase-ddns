#!/bin/sh

# DSM Config
__USERNAME__="$(echo ${@} | cut -d' ' -f1)"
__PASSWORD__="$(echo ${@} | cut -d' ' -f2)"
__DOMAIN__="$(echo ${@} | cut -d' ' -f3)"
__MYIP__="$(echo ${@}  | cut -d' ' -f4)"

# Log location
__LOGFILE__="/volume1/backup/cloudflareddns.log"

# CloudFlare Config
# Split type DOMAIN ZONEID RECID TTL PROXY
temp=( $__DOMAIN__ )
__RECTYPE__=${temp[0]}
__HOST_NAME__=${temp[1]}
__ZONE_ID__=${temp[2]}
__RECID__=${temp[3]}
__TTL__=${temp[4]}
__PROXY__=${temp[5]}

# Logger
log() {
  __LOGTIME__=$(date +"%b %e %T")
  if [ "${#}" -lt 1 ]; then
    false
  else
    __LOGMSG__="${1}"
  fi
  if [ "${#}" -lt 2 ]; then
    __LOGPRIO__=7
  else
    __LOGPRIO__=${2}
  fi
  logger -p ${__LOGPRIO__} -t "$(basename ${0})" "${__LOGMSG__}"
  echo "${__LOGTIME__} $(basename ${0}) (${__LOGPRIO__}): ${__LOGMSG__}" >> ${__LOGFILE__}
}

# Cloudflase url
__URL__="https://api.cloudflare.com/client/v4/zones/${__ZONE_ID__}/dns_records/${__RECID__}"

# Update DNS record:
log "Updating ${__HOST_NAME__} with ${__MYIP__}..."
__RESPONSE__=$(curl -s -X PUT "${__URL__}" \
    -H "X-Auth-Email: ${__USERNAME__}" \
    -H "X-Auth-Key: ${__PASSWORD__}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"${__RECTYPE__}\",\"name\":\"${__DOMAIN__}\",\"content\":\"${__MYIP__}\",\"ttl\":${__TTL__},\"proxied\":${__PROXY__}}")

# Strip the result element from response json
__RESULT__=$(echo ${__RESPONSE__} | grep -Po '"success":\K.*?[^\\],')
case ${__RESULT__} in 
  'true,')
      __STATUS__='good'
      true
    ;;

  *)
    __STATUS__="${__RESULT__}"
    log "__RESPONSE__=${__RESPONSE__}"
    false
  ;;
esac

# Result 
log "Status: ${__STATUS__}"
printf "%s" "${__STATUS__}"