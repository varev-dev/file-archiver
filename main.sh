#!bin/bash
# Author: Kacper Doga [@varev-dev] 

TITLE="File Archiver"
NO_FILES="No files were selected"
FILE_SEPARATOR=","
declare -a OPTIONS=("Archive" "Extract")
declare -a ARCHIVE_OPTIONS=("ZIP" "RAR" "TAR" "7Z")
declare -a selected_files=()

function select_items() {
    local locFiles
    locFiles=$(zenity --file-selection --multiple --separator="$FILE_SEPARATOR" --title="$TITLE")

    if [ $? == 0 ]; then
        IFS="$FILE_SEPARATOR" read -r -a fileArray <<< "$locFiles"
        echo "Selected files:"
        for file in "${fileArray[@]}"; do
            selected_files+=($file)
            echo "$file"
            selected_files+=("$file")
        done
    else
        zenity --info --text="$NO_FILES" --title="$TITLE"
    fi  
}

function archive_items() {
    echo "${selected_files[0]}"
}

while true; do
    selection=$(zenity --text "Choose option" --list --column=Menu "${OPTIONS[@]}" --title="$TITLE");

    if [ $? -ne 0 ]; then
        break;
    fi;

    if [ "$selection" == "Archive" ]; then
        echo "You selected Archive."
        select_items
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
