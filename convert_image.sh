#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert image into web friendly formats
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🖼️
# @raycast.packageName image-converter

# Documentation:
# @raycast.description Gets image and converts it into web friendly formats. avif and webp for the beginning.
# @raycast.author dennis_lemm
# @raycast.authorURL https://raycast.com/dennis_lemm


# 1. Get the images selected in the finder.
# 2. Convert the output into an array
# 3. Loop through the array and process each file
# 4. Convert the image into web friendly formats like webp and avif and save them in the same folder.

# Get the selected files from Finder

# Check if the required commands exist
if ! command -v cwebp &> /dev/null
then
    echo "cwebp could not be found"
    exit
fi

if ! command -v avifenc &> /dev/null
then
    echo "avifenc could not be found"
    exit
fi

filePaths=$(osascript <<EOF
tell application "Finder"
    set selectedItems to selection
    set itemList to ""
    repeat with currentItem in selectedItems
        set currentItemPath to (POSIX path of (currentItem as alias))
        set itemList to itemList & currentItemPath & ","
    end repeat
    return itemList
end tell
EOF
)

# Remove the trailing comma
filePaths=${filePaths%,}

# Convert the output into an array
IFS=',' read -r -a array <<< "$filePaths"

# Define a function to trim spaces
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

# Define a function to convert images
convert_image() {
    local image_name=$1
    local extension=$2

    # Convert the image into webp
    cwebp "$image_name" -o "${image_name%.*}.webp" &
    # Convert the image into avif
    avifenc "$image_name" -o "${image_name%.*}.avif" &
}


# Loop through the array and process each file
for image_name in "${array[@]}"
do
    # Trim spaces from the image name
    image_name=$(trim "$image_name")

    # Check if the image exists
    if ! [[ -f $image_name ]] ; then
       echo "Error: Image '$image_name' does not exist"
       continue
    fi

    # Get the extension of the file
    extension="${image_name##*.}"
    # Convert the extension to lowercase
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    # Check if the image is a png, jpg, or jpeg
    if [[ $extension =~ ^(png|jpg|jpeg)$ ]] ; then
        convert_image "$image_name" "$extension"
    else
        echo "Unsupported file type: $extension for file '$image_name'"
    fi
done

# Wait for all background jobs to finish
wait