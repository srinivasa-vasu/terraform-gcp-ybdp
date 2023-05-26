#!/bin/bash

set -x

# Define the port to check
port=9873

# i=1;
# while [ $i -le 20 ]
while true
do
  nc -vz localhost $port >/dev/null 2>&1;
  if [ $? -eq 0 ]; then
    echo "replicated is up, setting up the domain cert"
    sudo mv ${user_home}/domain.pem ${user_home}/domain.crt /etc/replicated/
    replicated console cert set ${hostname} /etc/replicated/domain.pem /etc/replicated/domain.crt
    touch ${user_home}/cert_upload.completed
    break;
  else
    echo "replicated is not up yet, sleeping for 5 seconds"
    sleep 5
    # sleep $i
    # i=$(expr $i + 1)
  fi
done

test ! -f ${user_home}/cert_upload.completed && echo 'Cert upload has failed' || echo 'Cert uploaded successfully'

echo "Setting the console password"
echo '{"Password": {"Password": "${password}"}}' | replicatedctl console-auth import

echo "Loading the license file"
replicatedctl license-load < ${user_home}/license_key

echo "cleanup"
rm ${user_home}/cert_upload.completed
rm ${user_home}/license_key
