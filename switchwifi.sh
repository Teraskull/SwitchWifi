#!/usr/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo -e "\e[31mError: Please run as root.\e[0m"
  exit 1
fi

VERSION="0.3.0"
WIFI_DIR="/etc/wpa_supplicant/"
_V=0

# TODO:
# Use -f --force to overwrite existing wifi_file
# Hash password using wpa_passphrase
# Ask for country code.

function version () {
  echo "$(basename $0) $VERSION"
  echo "Copyright (C) 2021 Anton Grouchtchak."
  echo "License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>."
  echo "This is free software: you are free to change and redistribute it."
  echo "There is NO WARRANTY, to the extent permitted by law."
  echo
  echo "Written by Anton Grouchtchak."
}

function usage () {
  echo "usage: sudo ./$(basename $0) [options] -s | -c wifi_file"
  echo "  required:"
  echo "    -s:        select wifi file. Cannot be used with -c"
  echo "    -c:        create wifi file. Cannot be used with -s"
  echo "    wifi_file: the wifi file to select or create"
  echo "  options:"
  echo "    -v:        log process to console"
  echo "    -h:        output this help and exit"
  echo "    -V:        output version information and exit"
}

function log () {
  if [[ $_V -eq 1 ]]; then
    echo "$@"
  fi
}

if [ "$#" -lt 1 ]; then
  echo -e "\e[31mError: No wifi file provided.\e[0m"
  usage
  exit 1
fi

if [ "$#" -gt 5 ]; then
  echo -e "\e[31mError: Too many arguments.\e[0m"
  usage
  exit 1
fi

mode=0
wifi_file=""
while getopts ":s:c:vVh" o; do
  case "${o}" in
    s)
      wifi_file=${OPTARG}
      mode=1
      ;;
    c)
      wifi_file=${OPTARG}
      mode=2
      ;;
    v)
      _V=1;;
    V)
      version
      exit 0;;
    h)
      usage
      exit 0;;
    :)
      echo -e "\e[31mError: No wifi file provided.\e[0m"
      usage
      exit 1;;
    ?)
      echo -e "\e[31mError: Unknown argument '$OPTARG'.\e[0m"
      usage
      exit 1;;
  esac
done
# shift $((OPTIND-1))

function select_wifi () {
  if [ -z $wifi_file ]; then
    echo -e "\e[31mError: No wifi file provided.\e[0m"
    usage
  else
  log "Checking if wifi file '$wifi_file' exists...'"
    if [[ -f "$WIFI_DIR$wifi_file" ]]; then
      log "Copying wifi file to 'wpa_supplicant.conf...'"
      cp "$WIFI_DIR$wifi_file" "${WIFI_DIR}wpa_supplicant.conf"
      log "Switching to wifi '$wifi_file'..."
      wpa_cli -i wlan0 reconfigure
      exit 0
    else
      echo -e "\e[31mError: Wifi file '$wifi_file' does not exist in $WIFI_DIR.\e[0m"
      exit 1
    fi
  fi

  exit 0
}

function create_wifi () {
  if [[ -f "$WIFI_DIR$wifi_file" ]]; then
    echo -e "\e[31mError: Wifi file '$wifi_file' already exists in $WIFI_DIR.\e[0m"
    exit 1
  else
    read -p "Wifi SSID: " SSID
    read -p "Wifi Password: " PASS
    COUNTRY="UA"
    log "Creating Wifi '$wifi_file'..."
    touch $WIFI_DIR$wifi_file

echo "country=$COUNTRY
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
        ssid=\"$SSID\"
        psk=\"$PASS\"
}" | tee -a $WIFI_DIR$wifi_file > /dev/null

  fi
  exit 0
}

if [ $mode -eq 1 ]; then
  select_wifi
fi

if [ $mode -eq 2 ]; then
  create_wifi
fi

exit 0

### END OF SCRIPT ###
