#!/bin/sh

HELP=0
LENGTH=16
INCLUDE_DIGITS=0
INCLUDE_SPECIAL=0

# Define the character sets
LETTERS='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
DIGITS='0123456789'
SPECIAL='@#$%&*?'

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help|help)
      HELP=1
      ;;
    -l|--length)
      shift
      if [ -z "$1" ] || [ "$1" -lt 1 ] 2>/dev/null; then
        echo "Error: Invalid length specified." >&2
        exit 1
      fi
      LENGTH="$1"
      ;;
    -d|--digits)
      INCLUDE_DIGITS=1
      ;;
    -s|--special)
      INCLUDE_SPECIAL=1
      ;;
    -*)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
  shift
done

# Display help information
if [ "$HELP" -eq 1 ]; then
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo "Options:"
  echo "  -l, --length N      Set password length (default: 16)"
  echo "  -d, --digits        Include at least one digit (0-9)"
  echo "  -s, --special       Include at least one special character (@#$%&*?)"
  echo "  -h, --help          Display this help and exit"
  exit 0
fi

# Build the full character class
CHAR_CLASS="$LETTERS"
[ "$INCLUDE_DIGITS" -eq 1 ] && CHAR_CLASS="${CHAR_CLASS}${DIGITS}"
[ "$INCLUDE_SPECIAL" -eq 1 ] && CHAR_CLASS="${CHAR_CLASS}${SPECIAL}"

if [ -z "$CHAR_CLASS" ]; then
  echo "No valid character set specified." >&2
  exit 1
fi

# Function to pick a random character from a given set
random_char() {
    echo "$1" | fold -w1 | shuf | head -n1
}

password=""

# Ensure at least one digit if requested
if [ "$INCLUDE_DIGITS" -eq 1 ]; then
    password="${password}$(random_char "$DIGITS")"
fi

# Ensure at least one special char if requested
if [ "$INCLUDE_SPECIAL" -eq 1 ]; then
    password="${password}$(random_char "$SPECIAL")"
fi

# Calculate how many characters remain to reach the desired length
chosen_len=$(printf "%s" "$password" | wc -m)
remaining=$((LENGTH - chosen_len))

if [ "$remaining" -lt 0 ]; then
  echo "Error: Length is too small for the required sets." >&2
  exit 1
fi

# Add the remaining random characters from the full set
if [ "$remaining" -gt 0 ]; then
    # Use tr and shuf to pick remaining random characters
    additional=$(tr -dc "$CHAR_CLASS" < /dev/urandom | head -c "$remaining")
    password="${password}${additional}"
fi

# Shuffle the final password to avoid a fixed pattern
password=$(echo "$password" | fold -w1 | shuf | tr -d '\n')

# Print the generated password
printf '%s\n' "$password"
