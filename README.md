# SwitchWifi

Easy way to change Wifi connections on a headless Raspberry Pi.

## Installing
```shell
git clone https://github.com/Teraskull/SwitchWifi/

cd SwitchWifi

sudo chmod +x switchwifi.sh
```

## Usage
```shell
# Create a wifi file called "new_wifi".
# The script will ask for the SSID and password.
sudo ./switchwifi.sh -c new_wifi
```

```shell
# Switch to the previously created wifi file "new_wifi".
sudo ./switchwifi.sh -s new_wifi
```

## License

This software is available under the following licenses:
* GPLv3+
