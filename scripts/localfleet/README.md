# Create a local fleet for tests


## Installation
The following software is required:
- `jq`
- `docker`
- `docker-compose`
- `qrencode`

Be sure that NAT is configured in the router you're connected to, since this uses the external IP address to connect the peers

## Usage
```
go run main.go
```
By default it will attempt to create 1 bootnode, 1 mailserver and 1 whisper node. You can control the number 
of mailservers and whisper nodes by using the flags `--mailservers N` and `--whisper N`, where `N` is the 
number of nodes to create.

**WARNING** this will overwrite the following files:
- `fleets.json`
- `vendor/status-go/services/mailservers/fleet.go`

The program will create the required nodes, and modify the fleet files. Afterwards you need to rebuild 
`status-go` and `status-desktop`, so it uses the local fleet nodes instead of the default `eth.prod` nodes.

Once you're done with the fleet, press `CTRL+C` to shutdown the fleet

## Simulating network conditions
With https://github.com/tylertreat/comcast, you can test common network problems. Use the following command to setup some rules:

```
comcast --device=wlp2s0 --latency=250 --target-bw=1000 --default-bw=10000 --packet-loss=10% --target-addr=your_ip_address --target-proto=tcp,udp --target-port=30310:30320
```
`latency` is specified in milliseconds, `target-bw` and `default-bw` are in Kbit


Replace the `device` flag with a valid value from `ifconfig` and `target-addr` with your IP address. After you're done with testing, use:
```
comcast --device=wlp2s0 --stop
```