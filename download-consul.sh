#!/bin/bash
set -e
if [ -z "$CONSUL_VERSION" ]
then
  echo "Variable CONSUL_VERSION is not defined.  Exiting without installing Consul."
  exit 1
fi
dirpath="${HOME}"/downloads/consul/consul_"$CONSUL_VERSION"
echo "downloading Consul version $CONSUL_VERSION to $dirpath"
[ -d "$dirpath" ] && \rm -rf "$dirpath"
mkdir -p "$dirpath"
cd "$dirpath"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig

