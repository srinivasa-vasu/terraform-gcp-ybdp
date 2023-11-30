#!/bin/bash

set -x

# Define the port to check
port=9873

# i=1;
# while [ $i -le 20 ]
while true
do
  curl -t '' -v telnet://localhost:$port >/dev/null 2>&1;
  if [ $? -eq 49 ]; then
    echo "replicated is up; setting up the password, license and cert info::"

    sudo mv ${user_home}/domain.pem ${user_home}/domain.crt /etc/replicated/
    replicated console cert set ${hostname} /etc/replicated/domain.pem /etc/replicated/domain.crt
    test $? -eq 0 && echo 'Cert uploaded successfully' || echo 'Cert upload has failed'

    echo "Loading the license file"
    replicatedctl license-load < ${user_home}/license_key
    test $? -eq 0 && echo 'License loaded successfully' || echo 'License load has failed'

    echo '{"Password": {"Password": "${password}"}}' | replicatedctl console-auth import
    test $? -eq 0 && echo 'Password set successfully' || echo 'Password set has failed'

    break;
  else
    echo "replicated is not up yet, sleeping for 5 seconds"
    sleep 5
    # sleep $i
    # i=$(expr $i + 1)
  fi
done

echo "cleanup"
rm ${user_home}/license_key
