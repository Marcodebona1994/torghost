## What is TorGhost ?
TorGhost is an anonymization script. TorGhost redirects all internet traffic through SOCKS5 tor proxy. DNS requests are also redirected via tor, thus preventing DNSLeak. The scripts also disables unsafe packets exiting the system. Some packets like ping request can compromise your identity.

## Original source
```
git clone https://github.com/SusmithKrishnan/torghost.git
```
## Updated repository
```
git clone https://github.com/marcodebona1994/torghost.git
```
## Build
```
cd torghost
chmod +x build.sh
./build.sh
```

## Run
```
sudo python3 torghost.py --start
```
or
```
sudo torghost --start
```
Torghost v3.0 usage:

`  -s      --start        # Start`

`  -r      --switch       # Request new tor exit node`

`  -x      --stop         # Stop`

`  -h      --help         # Print this help and exit`
