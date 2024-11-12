#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 rtsp://username:password@ip:port/stream"
    echo "Example: $0 rtsp://admin:12345@192.168.1.100:554/stream"
    exit 1
}

# Check if URL is provided
if [ $# -eq 0 ]; then
    usage
fi

RTSP_URL="$1"
ERROR_LOG=$(mktemp)

echo "Testing RTSP connection to: $RTSP_URL"
echo "Please wait..."

# Use ffprobe instead of ffmpeg - it's better for connection testing without video output
if timeout 10 ffprobe -v error -i "$RTSP_URL" 2>"$ERROR_LOG"; then
    echo -e "\e[32mSuccess: RTSP connection is working!\e[0m"
    rm -f "$ERROR_LOG"
    exit 0
else
    # Check the error log for specific errors
    if grep -q "Connection refused" "$ERROR_LOG"; then
        echo -e "\e[31mError: Connection refused. Please check if the server is running.\e[0m"
    elif grep -q "Authorization failed" "$ERROR_LOG"; then
        echo -e "\e[31mError: Authentication failed. Please check username and password.\e[0m"
    elif grep -q "Connection timed out" "$ERROR_LOG"; then
        echo -e "\e[31mError: Connection timed out. Please check the IP address and port.\e[0m"
    else
        echo -e "\e[31mError: RTSP connection failed.\e[0m"
        echo "Error details:"
        cat "$ERROR_LOG"
    fi
    rm -f "$ERROR_LOG"
    exit 1
fi
