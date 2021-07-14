#!/bin/bash

# source env.sh in same directory as script to set CONSUL_VERSION
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/env.sh

# use first argument to script as version if it is supplied and it matches pattern 
if [ ! -z "$1" ]; then
  PATTERN="^[0-9]+(\.[0-9]+)*$"
  if [[ "$1" =~ $PATTERN ]]; then
    CONSUL_VERSION="$1"
  else
    echo "invalid version $1" >&2
    exit 1
  fi
fi

if [ -z "$CONSUL_VERSION" ]
then
  echo "Variable CONSUL_VERSION is not defined.  Exiting without installing Consul." >&2
  exit 1
fi

echo "downloading Consul version $CONSUL_VERSION"

set -e

downloaddir="${HOME}/downloads"
dirname=consul_"$CONSUL_VERSION"
dirpath="$downloaddir/consul/$dirname"
tmppath=/tmp/$dirname
[ -d "$tmppath" ] && \rm -rf "$tmppath"
mkdir -p "${tmppath}"
cd $tmppath

curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig

set +e

shasum=`sha256sum consul_${CONSUL_VERSION}_linux_amd64.zip`
echo "verifying sha256sum: ${shasum}"
grep -q "${shasum}" consul_${CONSUL_VERSION}_SHA256SUMS
if [ $? -eq 0 ]
then
  echo "sha256sum verified"
else
  echo "sha256sum verification FAILED"
  exit 1
fi

set -e

[ -d "$dirpath" ] && \rm -rf "$dirpath"
mkdir -p "${dirpath}"
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
mv * "${dirpath}"
echo "files downloaded to ${dirpath}"
ls -l "${dirpath}"
[ -d "$tmppath" ] && \rm -rf "$tmppath"
echo "executable:"
find $dirpath -name consul -type f
