#!bin/bash
# Author: Kacper Doga [@varev-dev] 

TITLE="File Archiver"
NO_FILES="No files were selected"
declare -a OPTIONS=("Archive" "Extract")

selection=$(zenity --text "Choose option" --list --column=Menu "${OPTIONS[@]}" --title="$TITLE")

function select_items() {
    local files
    files=$(zenity --file-selection --multiple --separator="," --title="$TITLE")

    if [ $? == 0 ]; then
        IFS=":" read -r -a fileArray <<< "$files"
        echo "Selected files:"
        for file in "${fileArray[@]}"; do
            echo "$file"
        done
    else
       `zenity --info --text="$NO_FILES" --title="$TITLE"`
    fi  
}

while true; do
    if [ "$selection" == "Archive" ]; then
        echo "You selected Archive."
        select_items
    else
        echo "You selected Extract."
        # @TO-DO
    fi
done