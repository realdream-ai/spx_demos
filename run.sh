#!/bin/bash

# Iterate through all subdirectories in the demos directory and run spx command
# The script will wait for each spx command to complete before continuing to the next subdirectory

# Parse command line arguments
WEB_MODE=false
APK_MODE=false
IOS_MODE=false
for arg in "$@"; do
    case $arg in
        --web)
        WEB_MODE=true
        shift
        ;;
        --apk)
        APK_MODE=true
        shift
        ;;
        --ios)
        IOS_MODE=true
        shift
        ;;
    esac
done

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_PATH=$(pwd)

# Find all subdirectories (ignore hidden directories)
SUBDIRS=("$SCRIPT_DIR"/[0-9]*)

if [ "$WEB_MODE" = true ]; then
    echo "Running in web mode"
    echo "Killing gdspx_web_server.py processes if running..."
    PIDS=$(pgrep -f gdspx_web_server.py)
    if [ -n "$PIDS" ]; then
        echo "Killing processes: $PIDS"
        kill -9 $PIDS
    else
        echo "No gdspx_web_server.py process found."
    fi
    
    echo "The following subdirectories will run spx runweb command in sequence:"
    for DIR in "${SUBDIRS[@]}"; do
        if [ -d "$DIR" ]; then
            echo "- $(basename "$DIR")"
        fi
    done
    echo ""
    
    # Base port starting at 8106, will increment for each directory
    PORT=8106
    
    # Iterate through each subdirectory and run spx runweb
    for DIR in "${SUBDIRS[@]}"; do
        if [ -d "$DIR" ]; then
            DIR_NAME=$(basename "$DIR")
            echo "===================================="
            echo "Entering $DIR_NAME and running spx runweb on port $PORT..."
            echo "===================================="
            
            # Enter subdirectory and run spx runweb
            (cd "$DIR" && spx clear && spx runweb -serveraddr=":$PORT")
            
            # Increment port for next directory
            PORT=$((PORT + 1))
            
        fi
    done
    
    cd "$CURRENT_PATH"
    echo "spx runweb commands in all subdirectories have been completed"

elif [ "$APK_MODE" = true ]; then
    echo "Running in apk mode"
    echo "The following subdirectories will run spx exportapk command in sequence:"
    for DIR in "${SUBDIRS[@]}"; do
        if [ -d "$DIR" ]; then
            echo "- $(basename "$DIR")"
        fi
    done
    echo ""
    cd $SCRIPT_DIR
    mkdir -p $SCRIPT_DIR/builds
    # Base port starting at 8106, will increment for each directory
    mkdir -p "../build"
    # Iterate through each subdirectory and run spx runweb
    for DIR in "${SUBDIRS[@]}"; do
        if [ -d "$DIR" ]; then
            DIR_NAME=$(basename "$DIR")
            echo "===================================="
            echo "Entering $DIR_NAME and running spx exportapk..."
            echo "===================================="
            
            # Enter subdirectory and run spx runweb
            (cd "$DIR" && spx clear && spx exportapk)
            cp -f "$DIR/project/.builds/android/game.apk" "$SCRIPT_DIR/builds/$DIR_NAME.apk"
            cd "$DIR" && spx clear
        fi
    done
    
    cd "$CURRENT_PATH"
    echo "spx exportapk commands in all subdirectories have been completed"
elif [ "$IOS_MODE" = true ]; then
    echo "Running in ios mode"
    echo "The following subdirectories will run spx exportios command in sequence:"
    for DIR in "${SUBDIRS[@]}"; do
        if [ -d "$DIR" ]; then
            echo "- $(basename "$DIR")"
        fi
    done
    echo ""
    cd $SCRIPT_DIR
    mkdir -p $SCRIPT_DIR/builds
    # Base port starting at 8106, will increment for each directory
    mkdir -p "../build"
    # Iterate through each subdirectory and run spx runweb
    for DIR in "${SUBDIRS[@]}"; do
        if [ -d "$DIR" ]; then
            DIR_NAME=$(basename "$DIR")
            echo "===================================="
            echo "Entering $DIR_NAME and running spx exportios..."
            echo "===================================="
            
            # Enter subdirectory and run spx runweb
            (cd "$DIR" && spx clear && spx exportios)
            cp -f "$DIR/project/.builds/ios/Game.ipa" "$SCRIPT_DIR/builds/$DIR_NAME.ipa"
            cd "$DIR" && spx clear
        fi
    done
    
    cd "$CURRENT_PATH"
    echo "spx exportios commands in all subdirectories have been completed"
else
    echo "Running in normal mode"
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
            (cd "$DIR" && spx runi)
            
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
fi