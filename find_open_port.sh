#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Check if port is open and kills it
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚪
# @raycast.packageName check-open-portal-and-kill-it
# @raycast.argument1 {"type": "text", "placeholder": "port number"}

# Documentation:
# @raycast.description Check if a port is open and kills it.
# @raycast.author dennis_lemm
# @raycast.authorURL https://raycast.com/dennis_lemm


# 1. Get the port number from input
# 3. If the port is open, kill it. If not, print a message.

# 1. Get the port number
port=$1

# Check if the input is a valid number
if ! [[ $port =~ ^[0-9]+$ ]] ; then
   echo "Error: Invalid port number"
   exit 1
fi

# If the port is open, kill the process and print a message
if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
    pid=$(lsof -i :$port | awk '{print $2}' | tail -n 1)
    kill -9 $pid
    echo "Killed process $pid on port $port"
else
    echo "Port $port is closed"
fi
