#!/bin/sh

HELP=
QUIET=
PREFER=
ERROR_ON_PREFERRED_TAKEN=
RANDOMIZE=

while [ "$#" -gt 0 ]; do
  case $1 in 
    -h|--help|help)
      HELP=1
      ;;
    -p|--prefer)
      shift
      PREFER="$1"
      ;;
    -e|--error)
      ERROR_ON_PREFERRED_TAKEN=1
      ;;
    -r|--random)
      RANDOMIZE=1
      ;;
    -*)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;                                  
    *)  # No more options                          
      break
      ;;                                                                                                  
  esac
  shift                     
done

if [ "${HELP}" ]; then
  printf 'Usage: %s [OPTIONS]\n' "$(basename "$0")"
  printf 'Find and print a free TCP port from the ephemeral range (49152-65535).\n\n'
  printf 'Options:\n'
  printf '  -p, --prefer PORT        Attempt to use the specified preferred port first.\n'
  printf '  -e, --error              If the preferred port is taken, exit with an error instead of finding another.\n'
  printf '  -r, --random             Randomly select a free port instead of picking the first available.\n'
  printf '  -h, --help               Display this help message.\n'
  exit 0
fi

is_port_free() {
  # Checks if the given port is free (not in use)
  # Returns 0 if free, 1 if taken.
  if ss -tulwn | grep -q ":$1 " >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

find_first_free_port() {
  port=49152
  while [ ${port} -le 65535 ]; do
    if is_port_free $port; then
      echo $port
      return 0
    fi
    port=$((port+1))
  done
  echo "No free port found in the range 49152-65535." >&2
  exit 1
}


generate_random_port() {
  # Generates a random number between 49152 and 65535 using /dev/urandom
  # Ensures the port is within the desired range
  port=$(od -An -N2 -i /dev/urandom | tr -d ' ')
  port=$(( port % 16384 + 49152 ))
  echo "$port"
}

find_random_free_port() {
  # We attempt some random tries. If unsuccessful after 200 tries, just fallback to sequential.
  tries=0
  while [ $tries -lt 200 ]; do
    port=$(generate_random_port)
    if is_port_free "$port"; then
      echo "$port"
      return 0
    fi
    tries=$((tries+1))
  done
  # Fallback to sequential if random attempts fail
  find_first_free_port
}

if [ -n "$PREFER" ]; then
  # Validate preferred port
  if ! echo "$PREFER" | grep -qE '^[0-9]+$' || [ "$PREFER" -lt 1 ] || [ "$PREFER" -gt 65535 ]; then
    echo "Invalid preferred port number. Port must be an integer between 1 and 65535." >&2
    exit 1
  fi

  # Check if preferred port is free
  if is_port_free "$PREFER"; then
    # Preferred port is free
    chosen_port="$PREFER"
  else
    # Preferred port is taken
    if [ "$ERROR_ON_PREFERRED_TAKEN" ]; then
      echo "Preferred port $PREFER is already in use." >&2
      exit 1
    else
      # Try to find another free port
      if [ "$RANDOMIZE" ]; then
        chosen_port=$(find_random_free_port)
      else
        chosen_port=$(find_first_free_port)
      fi
    fi
  fi
else
  # No preferred port specified
  if [ "$RANDOMIZE" ]; then
    chosen_port=$(find_random_free_port)
  else
    chosen_port=$(find_first_free_port)
  fi
fi

printf '%s\n' "${chosen_port}"
printf '%s\n' "${chosen_port}" >&2
