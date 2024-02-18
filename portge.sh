#!/bin/sh

while [ "$#" -gt 0 ]; do
  case $1 in 
    -h|--help|help)
      HELP=1
      ;;                                   
    -q|--quiet)
      QUIET=1
      ;;                 
    -b|--build|--rebuild)
      BUILD=1
      ;;
    -*)
      echo "Error: Unsupported flag $1" >&2
      return 1
      ;;                                  
    *)  # No more options                          
      break
      ;;                                                                                                  
  esac
  shift                     
done

# Display help information
if [ "${HELP}" ]; then
  printf 'Usage: %s [NEW_PORT (optional)]\n' "$(basename "$0")"
  printf '  Change the port in the port forwarding of the db service in docker-compose.yml or docker-compose.yaml\n'
  printf ''
  printf 'Options:\n'
  printf '  -q, --quiet		  return only result\n'
  printf '  -b, --build, --rebuild  Build or rebuild the container\n'
  printf '  -h, --help              Display this help and exit\n'
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
  if [ ! "${QUIET}" ]; then
    printf 'finding free port...\n'
  fi
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

if [ "${QUIET}" ]; then
  printf '%s' "${new_port}"
else
  printf 'Updated db service port to %s in %s\n' "${new_port}" "${filename}"
  if [ -z "${build}" ]; then
    printf 'Will take effect after container rebuild\n'
  else
    sudo docker compose up --build -d	
  fi
fi
