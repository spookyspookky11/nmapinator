#!/bin/bash

# Store the current working directory
SCRIPT_DIR=$(pwd)

# Check if ultimate-nmap-parser is already installed
if [ ! -d "ultimate-nmap-parser" ]; then
    read -p "ultimate-nmap-parser is not installed. Would you like to install it now? (y/n): " INSTALL_PARSER
    if [ "$INSTALL_PARSER" = "y" ]; then
        git clone https://github.com/shifty0g/ultimate-nmap-parser.git && cd ultimate-nmap-parser && chmod +x ultimate-nmap-parser.sh
        cd "$SCRIPT_DIR"
    else
        echo "Error: ultimate-nmap-parser is required for this script"
        exit 1
    fi
fi

# Prompt the user to enter the filename containing the IP addresses to scan
read -p "Enter the filename containing the IP addresses to scan: " IP_FILE

# Check if the file exists
if [[ ! -f "$IP_FILE" ]]; then
    echo "Error: $IP_FILE not found"
    exit 1
fi

# Validate the IP addresses in the file
function validate_ip() {
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Prompt the user to enter the port range to scan with Masscan
read -p "Enter the port range to scan with Masscan (e.g. 1-65535): " PORT_RANGE

# Run Masscan against the live hosts with the specified port range
MASSCAN_OUTPUT="masscan_output.txt"
masscan -p$PORT_RANGE -oL $MASSCAN_OUTPUT -iL $IP_FILE --max-retries 2 --rate 1000

# Parse Masscan output for live hosts
LIVE_HOSTS=""
while IFS= read -r line; do
    ip=$(echo "$line" | cut -d " " -f 4)
    if validate_ip "$ip"; then
        LIVE_HOSTS+=" $ip"
    fi
done < "$MASSCAN_OUTPUT"

# Run nmap against the live hosts with the specified options
nmap -sC -sV -Pn -oG nmap_results.gnmap $LIVE_HOSTS

# Run the ultimate nmap parser against nmap results
cd ultimate-nmap-parser/ && ./ultimate-nmap-parser.sh --summary "$SCRIPT_DIR/nmap_results.gnmap" 
mv summary.txt "$SCRIPT_DIR" && cd "$SCRIPT_DIR"
