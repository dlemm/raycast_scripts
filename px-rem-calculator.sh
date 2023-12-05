#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title px rem Calculator
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName px-rem-calculator
# @raycast.argument1 {"type": "text", "placeholder": "query"}

# Documentation:
# @raycast.description change the input to either rem or px based on the input. Input should be like "10px" or "1rem"
# @raycast.author dennis_lemm
# @raycast.authorURL https://raycast.com/dennis_lemm


convert_units() {
  local input=$1

  # Check if the input contains 'px' or 'rem'
  if [[ $input == *'px' ]]; then
    local value=$(echo "$input" | cut -d 'p' -f 1)
    local converted_value=$(echo "scale=3; $value / 16" | bc)
    local unit='rem'
  elif [[ $input == *'rem' ]]; then
    local value=$(echo "$input" | cut -d 'r' -f 1)
    local converted_value=$(echo "scale=3; $value * 16" | bc)
    local unit='px'
  else
    echo "Invalid input. Please provide a valid input with either 'px' or 'rem'."
    return 1
  fi

  # Remove trailing zeros and decimal point if not necessary
  converted_value=$(echo $converted_value | sed 's/\.0*$//;s/\.$//')

  # Construct the output string
  local output="$converted_value$unit"
  echo "$output"
}

output=$(convert_units "$1")

echo "$output" | tee >(pbcopy)