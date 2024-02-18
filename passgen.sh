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
if [ "$HELP" ]; then
  printf 'Usage: $(basename "$0") [OPTION]\n'
  printf 'Options:\n'
  printf '  -q, --quiet		  return only result\n'
  printf '  -b, --build, --rebuild  Build or rebuild the container\n'
  printf '  -h, --help              Display this help and exit\n'
  exit 0
fi

if [ "$BUILD" ]; then
  build=1
fi

scriptdir="$(dirname "$(realpath "$0")")/"
cd "${scriptdir}" || exit 1

# Generate a random password
password=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 16 | head -n 1)

# Check for docker-compose file and set filename variable
if [ -f "docker-compose.yml" ]; then
  filename="docker-compose.yml"
elif [ -f "docker-compose.yaml" ]; then
  filename="docker-compose.yaml"
else
  echo "No docker-compose file found."
  exit 1
fi

# Update POSTGRES_PASSWORD in docker-compose.yml
sed -i "s/POSTGRES_PASSWORD: .*/POSTGRES_PASSWORD: $password/" "${filename}"

if [ "${QUIET}" ]; then
  printf '%s' "${password}"
else
  printf 'Updated POSTGRES_PASSWORD to %s in %s\n' "${password}" "${filename}"
  if [ -z "${build}" ]; then
    printf 'Will take effect after container rebuild\n'
  else
    sudo docker compose up --build -d	
  fi
fi
