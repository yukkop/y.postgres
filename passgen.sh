#!/bin/sh

if [ "$1" = '-b' ] || [ "$1" = '--build' ] || [ "$1" = '--rebuild' ]; then
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

echo "Updated POSTGRES_PASSWORD to $password in ${filename}"
if [ -z "${build}" ]; then
  echo "Will take effect after container rebuild"
else
  sudo docker compose up --build -d	
fi
