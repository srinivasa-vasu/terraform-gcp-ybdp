#!/bin/bash

set -x

sudo apt-get install -y wget || true

cd ${user_home}

test -f ${user_home}/yba_installer* || { wget ${download_path} -O yba-installer.tar.gz; tar -xvf yba-installer.tar.gz -C ${user_home}/ && rm -rf yba-installer.tar.gz; }

cd ${user_home}/yba_installer*

# Define the port to check
port=9000

# Send a request to the port and check the response
response=$(curl -sSf http://localhost:$port)

# Check the exit code of curl
if [ $? -ne 0 ]; then
  echo "Port $port is free, executing the install command."
  sed -i 's/server_cert_path:.*/server_cert_path: \"${e_user_home}\/domain.crt\"/g' yba-ctl.yml.reference
  sed -i 's/server_key_path:.*/server_key_path: \"${e_user_home}\/domain.pem\"/g' yba-ctl.yml.reference
  sed -i 's/keyStorePassword:.*/keyStorePassword: \"${password}\"/g' yba-ctl.yml.reference
  sed -i 's/appSecret:.*/appSecret: \"${password}\"/g' yba-ctl.yml.reference

  # TODO: TLS workaround (to be removed)
  sudo mkdir -p /opt/yugabyte/data/yba-installer/certs
  sudo cp ${user_home}/domain.pem /opt/yugabyte/data/yba-installer/certs/server.pem
  sudo cp ${user_home}/domain.crt /opt/yugabyte/data/yba-installer/certs/server.crt

  sudo ./yba-ctl install -l ${user_home}/license_key -s cpu,memory,disk-availability -f

else
  echo "Port $port is already in use, bouncing the instances with the updates"
  sed -i 's/server_cert_path:.*/server_cert_path: \"${e_user_home}\/domain.crt\"/g' ${default_config_path}
  sed -i 's/server_key_path:.*/server_key_path: \"${e_user_home}\/domain.pem\"/g' ${default_config_path}
  sed -i 's/keyStorePassword:.*/keyStorePassword: \"${password}\"/g' ${default_config_path}
  sed -i 's/appSecret:.*/appSecret: \"${password}\"/g' ${default_config_path}
  sudo ./yba-ctl restart yb-platform
fi
