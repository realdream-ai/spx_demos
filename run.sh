#!/bin/bash

# Iterate through all subdirectories in the demos directory and run spx run command
# The script will wait for each spx run command to complete before continuing to the next subdirectory

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find all subdirectories (ignore hidden directories)
SUBDIRS=("$SCRIPT_DIR"/[0-9]*)

echo "The following subdirectories will run spx run command in sequence:"
for DIR in "${SUBDIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "- $(basename "$DIR")"
    fi
done
echo ""

# Iterate through each subdirectory and run spx run
for DIR in "${SUBDIRS[@]}"; do
    if [ -d "$DIR" ]; then
        DIR_NAME=$(basename "$DIR")
        echo "===================================="
        echo "Entering $DIR_NAME and running spx run..."
        echo "===================================="
        
        # Enter subdirectory and run spx run
        (cd "$DIR" && spx run)
        
        # Get the exit status of the previous command
        STATUS=$?
        
        if [ $STATUS -eq 0 ]; then
            echo "spx run in $DIR_NAME completed successfully"
        else
            echo "spx run in $DIR_NAME failed, exit status: $STATUS"
        fi
        
        echo ""
        echo "Continue to next directory, or press Ctrl+C to exit..."

    fi
done

echo "spx run commands in all subdirectories have been completed"