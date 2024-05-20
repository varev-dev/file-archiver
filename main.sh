#!bin/bash
# Author            : Kacper Doga [@varev-dev]
# Created On        : 17.05.2024
# Last Modified By  : Kacper Doga [@varev-dev]
# Last Modified     : 20.05.2024
# Version           : 0.0.1
#
# Description       : Simple archive setuper / archive extractor created using Zenity widgets and Bash language
#
# Licensed under GPL (/usr/share/common-licenses/GPL for more details
# or contact the Free Software Foundation for a copy


TITLE="File Archiver"
NO_FILES="No files were selected"
FILE_SEPARATOR=","
MAX_COMPRESSION_ZIP=9
MAX_COMPRESSION_RAR=5
MIN_LENGTH=3

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
        exit
    fi  
}

function select_type() {
    type=$(zenity --text "Choose archive type" --list --column=Menu "${ARCHIVE_OPTIONS[@]}" --title="$TITLE");

    if [ $? != 0 ]; then
        exit
    fi

    echo "Type: ${type}"
}

function password_setup() {
    if zenity --question --title="$TITLE" --text="Do you want to create password for archive?"; then
        password=$(zenity --password --title="$TITLE" --text="Enter password for archive")

        if [ $? != 0 ]; then
            exit
        fi

        if [ ${#name} -lt $MIN_LENGTH ]; then
            echo "Password have to be at least ${MIN_LENGTH} characters."
            password_setup
        fi

        echo "Password: YES (${password})"
    fi
}

function metadata_cleanup() {
    if zenity --question --title="$TITLE" --text="Do you want to clear metadata from the archive?"; then
        echo "Metadata: REMOVED"
    fi;
}

function compression_level() {
    if zenity --question --title="$TITLE" --text="Do you want custom compression level?"; then
        local max_compression=0
        if [ "$type" == "RAR" ]; then
            max_compression=${MAX_COMPRESSION_RAR}
        elif [ "$type" == "ZIP" ]; then
            max_compression=${MAX_COMPRESSION_ZIP}
        fi
        compression=$(zenity --scale --title="$TITLE" --text="Compression level" --value=0 --min-value=0 --max-value=${max_compression})

        if [ $? != 0 ]; then
            exit
        fi
        echo "Compression: CUSTOM ${compression}"
    fi
}

function name_setup() {
    name=$(zenity --entry --title="$TITLE" --text="Enter archive name:")

    if [ $? != 0 ]; then
        exit
    fi;

    if [ ${#name} -lt $MIN_LENGTH ]; then
        echo "Name have to be at least ${MIN_LENGTH} characters."
        name_setup
    fi

    name=$(echo "$name" | sed 's/[^a-zA-Z0-9_.-]//g')
    echo "Name: ${name}"
}

function archive_items() {
    if zenity --question --title="$TITLE" --text="Is printed data in terminal right?"; then
        echo "1"
    else
        echo "Declined creating archive";
        exit
    fi
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
        name_setup
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
