#!bin/bash
# Author: Kacper Doga [@varev-dev] 

TITLE="File Archiver"
NO_FILES="No files were selected"
FILE_SEPARATOR=","
MAX_COMPRESSION_ZIP=9
MAX_COMPRESSION_RAR=5

declare -a OPTIONS=("Archive" "Extract")
declare -a ARCHIVE_OPTIONS=("ZIP" "RAR" "TAR")

type=ARCHIVE_OPTIONS[0]
declare -a files=()
password=""
compression=0
name=""

function select_items() {
    local locFiles
    locFiles=$(zenity --file-selection --multiple --separator="$FILE_SEPARATOR" --title="$TITLE")

    if [ $? == 0 ]; then
        IFS="$FILE_SEPARATOR" read -r -a fileArray <<< "$locFiles"
        echo "Selected files:"
        for file in "${fileArray[@]}"; do
            files+=($file)
            echo "$file"
        done
    else
        zenity --info --text="$NO_FILES" --title="$TITLE"
    fi  
}

function select_type() {
    type=$(zenity --text "Choose archive type" --list --column=Menu "${ARCHIVE_OPTIONS[@]}" --title="$TITLE");
}

function password_setup() {
    if zenity --question --title="$TITLE" --text="Do you want to create password for archive?"; then
        password=$(zenity --password --title="$TITLE" --text="Enter password for archive")
        echo "Password: YES (${password})"
    fi
}

function metadata_cleanup() {
    if zenity --question --title="$TITLE" --text="Do you want to clear metadata from the archive?"; then
        echo "Metadata: REMOVED"
    fi
}

function compression_level() {
    if zenity --question --title="$TITLE" --text="Do you want custom compression level?"; then
        local max_compression=0
        if [ "$type" == "RAR" ]; then
            max_compression=MAX_COMPRESSION_RAR
        elif [ "$type" == "ZIP" ]; then
            max_compression=MAX_COMPRESSION_ZIP
        fi
        compression=$(zenity --scale --title="$TITLE" --text="$TEXT" --min-value=0 --max-value=max_compression --value=0)
        echo "Compression: CUSTOM ${compression}"
    fi
}

function archive_items() {
    echo "${files[0]}"
}

while true; do
    selection=$(zenity --text "Choose option" --list --column=Menu "${OPTIONS[@]}" --title="$TITLE");

    if [ $? -ne 0 ]; then
        break;
    fi;

    if [ "$selection" == "Archive" ]; then
        echo "You selected Archive."
        select_items
        select_type
        metadata_cleanup
        if [ "$type" != "TAR" ]; then
            compression_level
            password_setup
        fi
        archive_items
    else
        echo "You selected Extract."
        local file=$(zenity --file-selection --separator="$FILE_SEPARATOR" --title="$TITLE")
        if [ $? == 0 ]; then
            echo "Selected archive: ${file}"
        else
            zenity --info --text="$NO_FILES" --title="$TITLE"
        fi  
    fi
done
