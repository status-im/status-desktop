import json, os, chronicles, utils
import ../../constants as main_constants

# set via `nim c` param `-d:INFURA_TOKEN:[token]`; should be set in CI/release builds
const INFURA_TOKEN {.strdefine.} = ""
# allow runtime override via environment variable; core contributors can set a
# release token in this way for local development
let INFURA_TOKEN_ENV = $getEnv("INFURA_TOKEN")
let INFURA_TOKEN_RESOLVED =
  if INFURA_TOKEN_ENV != "":
    INFURA_TOKEN_ENV
  else:
    INFURA_TOKEN

const OPENSEA_API_KEY {.strdefine.} = ""
# allow runtime override via environment variable; core contributors can set a
# an opensea API key in this way for local development
let OPENSEA_API_KEY_ENV = $getEnv("OPENSEA_API_KEY")
let OPENSEA_API_KEY_RESOLVED* =
  if OPENSEA_API_KEY_ENV != "":
    OPENSEA_API_KEY_ENV
  else:
    OPENSEA_API_KEY

let DEFAULT_TORRENT_CONFIG_PORT* = 9025
let DEFAULT_TORRENT_CONFIG_DATADIR* = joinPath(main_constants.defaultDataDir(), "data", "archivedata")
let DEFAULT_TORRENT_CONFIG_TORRENTDIR* = joinPath(main_constants.defaultDataDir(), "data", "torrents")


const DEFAULT_NETWORK_NAME* = "mainnet_rpc"
const DEFAULT_NETWORKS_IDS* = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]

let DEFAULT_NETWORKS* = %* [
  {
    "id": "testnet_rpc",
    "etherscan-link": "https://ropsten.etherscan.io/address/",
    "name": "Ropsten with upstream RPC",
    "config": {
      "NetworkId": 3,
      "DataDir": "/ethereum/testnet_rpc",
      "UpstreamConfig": {
        "Enabled": true,
        "URL": "https://ropsten.infura.io/v3/" & INFURA_TOKEN_RESOLVED
      }
    }
  },
  {
    "id": "rinkeby_rpc",
    "etherscan-link": "https://rinkeby.etherscan.io/address/",
    "name": "Rinkeby with upstream RPC",
    "config": {
      "NetworkId": 4,
      "DataDir": "/ethereum/rinkeby_rpc",
      "UpstreamConfig": {
        "Enabled": true,
        "URL": "https://rinkeby.infura.io/v3/" & INFURA_TOKEN_RESOLVED
      }
    }
  },
  {
    "id": "goerli_rpc",
    "etherscan-link": "https://goerli.etherscan.io/address/",
    "name": "Goerli with upstream RPC",
    "config": {
      "NetworkId": 5,
      "DataDir": "/ethereum/goerli_rpc",
      "UpstreamConfig": {
        "Enabled": true,
        "URL": "https://goerli.blockscout.com/"
      }
    }
  },
  {
    "id": "mainnet_rpc",
    "etherscan-link": "https://etherscan.io/address/",
    "name": "Mainnet with upstream RPC",
    "config": {
      "NetworkId": 1,
      "DataDir": "/ethereum/mainnet_rpc",
      "UpstreamConfig": {
        "Enabled": true,
        "URL": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED
      }
    }
  },
  {
    "id": "xdai_rpc",
    "name": "xDai Chain",
    "config": {
      "NetworkId": 100,
      "DataDir": "/ethereum/xdai_rpc",
      "UpstreamConfig": {
        "Enabled": true,
        "URL": "https://dai.poa.network"
      }
    }
  },
  {
    "id": "poa_rpc",
    "name": "POA Network",
    "config": {
      "NetworkId": 99,
      "DataDir": "/ethereum/poa_rpc",
      "UpstreamConfig": {
        "Enabled": true,
        "URL": "https://core.poa.network"
      }
    }
  }
]

let NETWORKS* = %* [
  {
    "chainId": 1,
    "chainName": "Mainnet",
    "rpcUrl": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://etherscan.io/",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest": false,
    "layer": 1,
    "enabled": true,
  },
  {
    "chainId": 3,
    "chainName": "Ropsten",
    "rpcUrl": "https://ropsten.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://ropsten.etherscan.io/",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest": true,
    "layer": 1,
    "enabled": true,
  },
  {
    "chainId": 4,
    "chainName": "Rinkeby",
    "rpcUrl": "https://rinkeby.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://rinkeby.etherscan.io/",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest": true,
    "layer": 1,
    "enabled": false,
  },
  {
    "chainId": 5,
    "chainName": "Goerli",
    "rpcUrl": "http://goerli.blockscout.com/",
    "blockExplorerUrl": "https://goerli.etherscan.io/",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest": true,
    "layer": 1,
    "enabled": false,
  },
  {
    "chainId": 10,
    "chainName": "Optimism",
    "rpcUrl": "https://optimism-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://optimistic.etherscan.io",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  false,
    "layer":   2,
    "enabled": true,
  },
  {
    "chainId": 69,
    "chainName": "Optimism Kovan",
    "rpcUrl": "https://optimism-kovan.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://kovan-optimistic.etherscan.io",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": false,
  },
  {
    "chainId": 42161,
    "chainName": "Arbitrum",
    "rpcUrl": "https://arbitrum-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://arbiscan.io/",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  false,
    "layer":   2,
    "enabled": true,
  },
  {
    "chainId": 421611,
    "chainName": "Arbitrum Rinkeby",
    "rpcUrl": "https://arbitrum-rinkeby.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": " https://testnet.arbiscan.io",
    "iconUrl": "",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": false,
  }
]

var NODE_CONFIG* = %* {
  "BrowsersConfig": {
    "Enabled": true
  },
  "ClusterConfig": {
    "Enabled": true
  },
  "DataDir": "./ethereum/mainnet",
  "EnableNTPSync": true,
  "KeyStoreDir": "./keystore",
  "IPFSDir": "./ipfs",
  # TODO: commented since it's not necessary (we do the connections thru C bindings). Enable it thru an option once status-nodes are able to be configured in desktop
  #"ListenAddr": ":30304",
  "LogEnabled": true,
  "LogFile": "geth.log",
  "LogLevel": $LogLevel.INFO,
  "MailserversConfig": {
    "Enabled": true
  },
  "Name": "StatusDesktop",
  "NetworkId": 1,
  "NoDiscovery": false,
  "PermissionsConfig": {
    "Enabled": true
  },
  "Rendezvous": true,
  "RegisterTopics": @["whispermail"],
  "RequireTopics": {
    "whisper": {
      "Max": 2,
      "Min": 2
    }
  },
  "ShhextConfig": {
    "BackupDisabledDataDir": "./",
    "DataSyncEnabled": true,
    "InstallationID": "aef27732-8d86-5039-a32e-bdbe094d8791",
    "MailServerConfirmations": true,
    "MaxMessageDeliveryAttempts": 6,
    "PFSEnabled": true,
    "VerifyENSContractAddress": "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e",
    "VerifyENSURL": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "VerifyTransactionChainID": 1,
    "VerifyTransactionURL": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "BandwidthStatsEnabled": true
  },
  "Web3ProviderConfig": {
    "Enabled": true
  },
  "EnsConfig": {
    "Enabled": true
  },
  "StatusAccountsConfig": {
    "Enabled": true
  },
  "UpstreamConfig": {
    "Enabled": true,
    "URL": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED
  },
  "WakuConfig": {
    "BloomFilterMode": true,
    "Enabled": true,
    "LightClient": true,
    "MinimumPoW": 0.001
  },
  "WakuV2Config": {
    "Enabled": false,
    "Host": "0.0.0.0",
    "Port": 0,
    "LightClient": false,
    "PersistPeers": true,
    "EnableDiscV5": true,
    "UDPPort": 0,
    "PeerExchange": true,
    "AutoUpdate": true,
  },
  "WalletConfig": {
    "Enabled": true,
    "OpenseaAPIKey": OPENSEA_API_KEY_RESOLVED
  },
  "EnsConfig": {
    "Enabled": true
  },
  "Networks": Networks,
  "TorrentConfig": {
    "Enabled": false,
    "Port": DEFAULT_TORRENT_CONFIG_PORT,
    "DataDir": DEFAULT_TORRENT_CONFIG_DATADIR,
    "TorrentDir": DEFAULT_TORRENT_CONFIG_TORRENTDIR
  }
}

proc getNetworkConfig*(currentNetwork: string): JsonNode =
  result = DEFAULT_NETWORKS.first("id", currentNetwork)
