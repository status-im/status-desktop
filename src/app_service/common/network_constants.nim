import json, os, chronicles
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


const GANACHE_NETWORK_RPC_URL = $getEnv("GANACHE_NETWORK_RPC_URL")
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

var NETWORKS* = %* [
  {
    "chainId": 1,
    "chainName": "Ethereum Mainnet",
    "rpcUrl": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://etherscan.io/",
    "iconUrl": "network/Network=Ethereum",
    "chainColor": "#627EEA",
    "shortName": "eth",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest": false,
    "layer": 1,
    "enabled": true,
  },
  {
      "chainId": 5,
      "chainName": "Goerli",
      "rpcUrl": "https://goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
      "blockExplorerUrl": "https://goerli.etherscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "goeEth",
      "nativeCurrencyName": "Ether",
      "nativeCurrencySymbol": "ETH",
      "nativeCurrencyDecimals": 18,
      "isTest": true,
      "layer": 1,
      "enabled": true,
  },
  {
    "chainId": 10,
    "chainName": "Optimism",
    "rpcUrl": "https://optimism-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://optimistic.etherscan.io",
    "iconUrl": "network/Network=Optimism",
    "chainColor": "#E90101",
    "shortName": "opt",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  false,
    "layer":   2,
    "enabled": true,
  },
  {
    "chainId": 420,
    "chainName": "Optimism Goerli Testnet",
    "rpcUrl": "https://optimism-goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://goerli-optimism.etherscan.io/",
    "iconUrl": "network/Network=Testnet",
    "chainColor": "#939BA1",
    "shortName": "goerOpt",
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
    "iconUrl": "network/Network=Arbitrum",
    "chainColor": "#51D0F0",
    "shortName": "arb",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  false,
    "layer":   2,
    "enabled": true,
  },
  {
    "chainId": 421613,
    "chainName": "Arbitrum Goerli",
    "rpcUrl": "https://arbitrum-goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://goerli.arbiscan.io/",
    "iconUrl": "network/Network=Testnet",
    "chainColor": "#939BA1",
    "shortName": "rinArb",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": false,
  }
]

if GANACHE_NETWORK_RPC_URL != "":
  NETWORKS = %* [
    {
      "chainId": 1,
      "chainName": "Ethereum Mainnet",
      "rpcUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://etherscan.io/",
      "iconUrl": "network/Network=Ethereum",
      "chainColor": "#627EEA",
      "shortName": "eth",
      "nativeCurrencyName": "Ether",
      "nativeCurrencySymbol": "ETH",
      "nativeCurrencyDecimals": 18,
      "isTest": false,
      "layer": 1,
      "enabled": true,
      "tokenOverrides": [
        {
          "symbol": "SNT",
          "address": "0x8571Ddc46b10d31EF963aF49b6C7799Ea7eff818"
        }
      ]
    },
    {
      "chainId": 5,
      "chainName": "Goerli",
      "rpcUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://goerli.etherscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "goeEth",
      "nativeCurrencyName": "Ether",
      "nativeCurrencySymbol": "ETH",
      "nativeCurrencyDecimals": 18,
      "isTest": true,
      "layer": 1,
      "enabled": true,
      "tokenOverrides": [
        {
          "symbol": "STT",
          "address": "0x8571Ddc46b10d31EF963aF49b6C7799Ea7eff818"
        }
      ]
    },
    {
      "chainId": 10,
      "chainName": "Optimism",
      "rpcUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://optimistic.etherscan.io",
      "iconUrl": "network/Network=Optimism",
      "chainColor": "#E90101",
      "shortName": "opt",
      "nativeCurrencyName": "Ether",
      "nativeCurrencySymbol": "ETH",
      "nativeCurrencyDecimals": 18,
      "isTest":  false,
      "layer":   2,
      "enabled": true,
    },
    {
      "chainId": 420,
      "chainName": "Optimism Goerli Testnet",
      "rpcUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://goerli-optimism.etherscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "goerOpt",
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
      "rpcUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://arbiscan.io/",
      "iconUrl": "network/Network=Arbitrum",
      "chainColor": "#51D0F0",
      "shortName": "arb",
      "nativeCurrencyName": "Ether",
      "nativeCurrencySymbol": "ETH",
      "nativeCurrencyDecimals": 18,
      "isTest":  false,
      "layer":   2,
      "enabled": true,
    },
    {
      "chainId": 421613,
      "chainName": "Arbitrum Goerli",
      "rpcUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://goerli.arbiscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "rinArb",
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
  "Networks": NETWORKS,
  "TorrentConfig": {
    "Enabled": true,
    "Port": DEFAULT_TORRENT_CONFIG_PORT,
    "DataDir": DEFAULT_TORRENT_CONFIG_DATADIR,
    "TorrentDir": DEFAULT_TORRENT_CONFIG_TORRENTDIR
  }
}