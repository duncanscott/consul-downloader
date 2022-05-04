#!/bin/bash

# source env.sh in same directory as script to set CONSUL_VERSION
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/env.sh"

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
tmppath="/tmp/$dirname"
filename="consul_${CONSUL_VERSION}_linux_amd64.zip"
shaname="consul_${CONSUL_VERSION}_SHA256SUMS"
shasig="${shaname}.sig"
baseurl="https://releases.hashicorp.com/consul/${CONSUL_VERSION}/"

[ -d "$tmppath" ] && \rm -rf "$tmppath"
mkdir -p "${tmppath}"
cd $tmppath

set +e

echo retrieving ${baseurl}${filename}
if ! curl --fail --silent --remote-name "${baseurl}${filename}"; then
  echo "download of ${filename} failed" >&2
  exit 1
fi

echo retrieving ${baseurl}${shaname}
if ! curl --fail --silent --remote-name "${baseurl}${shaname}"; then
  echo "download of ${shaname} failed" >&2
  exit 1
fi

echo retrieving ${baseurl}${shasig}
if ! curl --fail --silent --remote-name "${baseurl}${shasig}"; then
  echo "download of ${shasig} failed" >&2
  exit 1
fi

shasum=`sha256sum ${filename}`
echo "verifying sha256sum: ${shasum}"
grep -q "${shasum}" "${shaname}"
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
unzip "${filename}"
mv * "${dirpath}"
echo "files downloaded to ${dirpath}"
ls -l "${dirpath}"
[ -d "$tmppath" ] && \rm -rf "$tmppath"
echo "executable:"
find $dirpath -name consul -type f
