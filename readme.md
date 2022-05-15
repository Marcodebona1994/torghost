## What is TorSystem ?
TorSystem is an anonymization script. TorSystem redirects all internet traffic through SOCKS5 tor proxy. DNS requests are also redirected via tor, thus preventing DNSLeak. The scripts also disables unsafe packets exiting the system. Some packets like ping request can compromise your identity.

## Credits
Bash rewrite of Torghost -> https://github.com/SusmithKrishnan/torghost.git

## Installation
```
git clone https://github.com/Marcodebona1994/torsystem.git
cd torsystem
./install
```

## Run
```
sudo torsystem --start

```

### Usage

TorSystem usage:
-s, --start       	   # Start TorSystem
-n, --new-circuit      # Request new tor exit node
-x, --stop             # Stop TorSystem
-b  --backup           # Create backup for restoring networking system
-h  --help
