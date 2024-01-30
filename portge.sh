#!/bin/sh

# Display help information
if [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = 'help' ]; then
	echo "Usage: $(basename "$0") [NEW_PORT (optional)]"
  echo "Change the port in the port forwarding of the db service in docker-compose.yml or docker-compose.yaml"
  exit 0
fi

# Function to find a free port
find_free_port() {
  port=49152 # TODO: more random
  while [ ${port} -le 65535 ]; do
    if ! ss -tulwn | grep -q ":${port} "; then
      echo ${port}
      return
    fi
    port=$((port+1))
  done
  echo "No free port found in the range 49152-65535."
  exit 1
}

new_port="$1"

if [ -z "${new_port}" ]; then
  echo "finding free port..."
  new_port=$(find_free_port)
else

  # Check if port is a number and in the valid range (1-65535)
  if ! echo "${new_port}" | grep -qE '^[0-9]+$' || [ "${new_port}" -lt 1 ] || [ "${new_port}" -gt 65535 ]; then
    echo "Invalid port number. Port must be an integer between 1 and 65535."
    exit 1
  fi
  
  # Check if the port is already in use
  if ss -tulwn | grep -q ":${new_port} "; then
    echo "Port ${new_port} is already in use."
    exit 1
  fi
fi

# Check for docker-compose file and set filename variable
if [ -f "docker-compose.yml" ]; then
  filename="docker-compose.yml"
elif [ -f "docker-compose.yaml" ]; then
  filename="docker-compose.yaml"
else
  echo "No docker-compose file found."
  exit 1
fi

# Update the port forwarding
sed -i "s/- .*:5432/- ${new_port}:5432/" "${filename}"

echo "Updated db service port to ${new_port} in ${filename}"
