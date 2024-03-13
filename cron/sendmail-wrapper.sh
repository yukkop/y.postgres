#!/bin/sh
# Remove the -F option and any argument that follows it
args=$(printf '%s\n' "$@" | awk '!(prev ~ /^-F$/ || $1 ~ /^-F$/) {print} {prev=$1}')

# Call the real sendmail with modified arguments
/usr/sbin/sendmail $args
