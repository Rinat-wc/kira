#!/bin/bash
set +e && source "/etc/profile" &>/dev/null && set -e
# quick edit: FILE="$KIRA_MANAGER/scripts/restart-networks.sh" && rm -fv $FILE && nano $FILE && chmod 555 $FILE

reconnect=$1
target=$2

[ -z "$reconnect" ] && reconnect="true"

declare -a networks=("kiranet" "sentrynet" "servicenet" "regnet")
declare -a subnets=("$KIRA_VALIDATOR_SUBNET" "$KIRA_SENTRY_SUBNET" "$KIRA_SERVICE_SUBNET" "$KIRA_REGISTRY_SUBNET")
len=${#networks[@]}

for (( i=0; i<${len}; i++ )) ; do
  network=${networks[$i]}
  subnet=${subnets[$i]}
  [ ! -z "$target" ] && [ "$network" != "$target" ] && continue
  echo "INFO: Restarting $network ($subnet)"
  containers=$(docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' $network || echo "")

  for container in $containers ; do
     echo "INFO: Disconnecting container $container"
     docker network disconnect -f $network $container || echo "INFO: Failed to disconnect container $conatainer from network $network"
  done

  docker network rm $network || echo "INFO: Failed to remove $network network"
  docker network create --driver=bridge --subnet=$subnet $network

  if [ "${reconnect,,}" == "true" ] ; then
    for container in $containers ; do
      echo "INFO: Connecting container $container to $network"
      docker network connect $network $container
    done
  else
    echo "INFO: Containers will NOT be recconected to the '$network' network"
  fi
done
