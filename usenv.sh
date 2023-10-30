if [ -f .env ]; then
  . .env
else
  echo ".env file not found. Please create one with the necessary environment variables."
  exit 1
fi

echo $PGPASSWORD

$@
