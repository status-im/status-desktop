import json, os, chronicles, strutils
import ../../constants as main_constants

# provider Tokens
# allow runtime override via environment variable; core contributors can set a
# release token in this way for local development

# set via `nim c` param `-d:POKT_TOKEN:[token]`; should be set in CI/release builds
const POKT_TOKEN {.strdefine.} = ""
let POKT_TOKEN_ENV = $getEnv("POKT_TOKEN")
let POKT_TOKEN_RESOLVED =
  if POKT_TOKEN_ENV != "":
    POKT_TOKEN_ENV
  else:
    POKT_TOKEN

# set via `nim c` param `-d:INFURA_TOKEN:[token]`; should be set in CI/release builds
const INFURA_TOKEN {.strdefine.} = ""
let INFURA_TOKEN_ENV = $getEnv("INFURA_TOKEN")
let INFURA_TOKEN_RESOLVED* =
  if INFURA_TOKEN_ENV != "":
    INFURA_TOKEN_ENV
  else:
    INFURA_TOKEN

# set via `nim c` param `-d:INFURA_TOKEN_SECRET:[token]`; should be set in CI/release builds
const INFURA_TOKEN_SECRET {.strdefine.} = ""
let INFURA_TOKEN_SECRET_ENV = $getEnv("INFURA_TOKEN_SECRET")
let INFURA_TOKEN_SECRET_RESOLVED* =
  if INFURA_TOKEN_SECRET_ENV != "":
    INFURA_TOKEN_SECRET_ENV
  else:
    INFURA_TOKEN_SECRET

# set via `nim c` param `-d:ALCHEMY_ARBITRUM_MAINNET_TOKEN:[token]`; should be set in CI/release builds
const ALCHEMY_ARBITRUM_MAINNET_TOKEN {.strdefine.} = ""
let ALCHEMY_ARBITRUM_MAINNET_TOKEN_ENV = $getEnv("ALCHEMY_ARBITRUM_MAINNET_TOKEN")
let ALCHEMY_ARBITRUM_MAINNET_TOKEN_RESOLVED* =
  if ALCHEMY_ARBITRUM_MAINNET_TOKEN_ENV != "":
    ALCHEMY_ARBITRUM_MAINNET_TOKEN_ENV
  else:
    ALCHEMY_ARBITRUM_MAINNET_TOKEN

# set via `nim c` param `-d:ALCHEMY_ARBITRUM_GOERLI_TOKEN:[token]`; should be set in CI/release builds
const ALCHEMY_ARBITRUM_GOERLI_TOKEN {.strdefine.} = ""
let ALCHEMY_ARBITRUM_GOERLI_TOKEN_ENV = $getEnv("ALCHEMY_ARBITRUM_GOERLI_TOKEN")
let ALCHEMY_ARBITRUM_GOERLI_TOKEN_RESOLVED* =
  if ALCHEMY_ARBITRUM_GOERLI_TOKEN_ENV != "":
    ALCHEMY_ARBITRUM_GOERLI_TOKEN_ENV
  else:
    ALCHEMY_ARBITRUM_GOERLI_TOKEN

# set via `nim c` param `-d:ALCHEMY_OPTIMISM_MAINNET_TOKEN:[token]`; should be set in CI/release builds
const ALCHEMY_OPTIMISM_MAINNET_TOKEN {.strdefine.} = ""
let ALCHEMY_OPTIMISM_MAINNET_TOKEN_ENV = $getEnv("ALCHEMY_OPTIMISM_MAINNET_TOKEN")
let ALCHEMY_OPTIMISM_MAINNET_TOKEN_RESOLVED* =
  if ALCHEMY_OPTIMISM_MAINNET_TOKEN_ENV != "":
    ALCHEMY_OPTIMISM_MAINNET_TOKEN_ENV
  else:
    ALCHEMY_OPTIMISM_MAINNET_TOKEN

# set via `nim c` param `-d:ALCHEMY_OPTIMISM_GOERLI_TOKEN:[token]`; should be set in CI/release builds
const ALCHEMY_OPTIMISM_GOERLI_TOKEN {.strdefine.} = ""
let ALCHEMY_OPTIMISM_GOERLI_TOKEN_ENV = $getEnv("ALCHEMY_OPTIMISM_GOERLI_TOKEN")
let ALCHEMY_OPTIMISM_GOERLI_TOKEN_RESOLVED* =
  if ALCHEMY_OPTIMISM_GOERLI_TOKEN_ENV != "":
    ALCHEMY_OPTIMISM_GOERLI_TOKEN_ENV
  else:
    ALCHEMY_OPTIMISM_GOERLI_TOKEN

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

const DEFAULT_TORRENT_CONFIG_PORT = 0 # Random
let TORRENT_CONFIG_PORT* = if (existsEnv("TORRENT_PORT")):
              parseInt($getEnv("TORRENT_PORT"))
            else:
              DEFAULT_TORRENT_CONFIG_PORT

const DEFAULT_WAKU_V2_PORT = 0 # Random
let WAKU_V2_PORT* = if (existsEnv("WAKU_PORT")):
              parseInt($getEnv("WAKU_PORT"))
            else:
              DEFAULT_WAKU_V2_PORT

let DEFAULT_TORRENT_CONFIG_DATADIR* = joinPath(main_constants.defaultDataDir(), "data", "archivedata")
let DEFAULT_TORRENT_CONFIG_TORRENTDIR* = joinPath(main_constants.defaultDataDir(), "data", "torrents")

var NETWORKS* = %* [
  {
    "chainId": 1,
    "chainName": "Ethereum Mainnet",
    "rpcUrl": "https://eth-archival.gateway.pokt.network/v1/lb/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
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
    "rpcUrl": "https://goerli-archival.gateway.pokt.network/v1/lb/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://goerli.etherscan.io/",
    "iconUrl": "network/Network=Testnet",
    "chainColor": "#939BA1",
    "shortName": "goEth",
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
    "rpcUrl": "https://optimism-mainnet.gateway.pokt.network/v1/lb/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://optimism-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
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
    "fallbackUrl": "",
    "blockExplorerUrl": "https://goerli-optimism.etherscan.io/",
    "iconUrl": "network/Network=Testnet",
    "chainColor": "#939BA1",
    "shortName": "goOpt",
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
    "rpcUrl": "https://arbitrum-one.gateway.pokt.network/v1/lb/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://arbitrum-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
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
    "fallbackUrl": "",
    "blockExplorerUrl": "https://goerli.arbiscan.io/",
    "iconUrl": "network/Network=Testnet",
    "chainColor": "#939BA1",
    "shortName": "goArb",
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
      "fallbackUrl": GANACHE_NETWORK_RPC_URL,
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
      "fallbackUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://goerli.etherscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "goEth",
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
      "fallbackUrl": GANACHE_NETWORK_RPC_URL,
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
      "fallbackUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://goerli-optimism.etherscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "goOpt",
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
      "fallbackUrl": GANACHE_NETWORK_RPC_URL,
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
      "fallbackUrl": GANACHE_NETWORK_RPC_URL,
      "blockExplorerUrl": "https://goerli.arbiscan.io/",
      "iconUrl": "network/Network=Testnet",
      "chainColor": "#939BA1",
      "shortName": "goArb",
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
  # Set Max number of log files kept to 1
  # Setting it to 0 creates a problem where all log files are kepts
  # Docs: https://pkg.go.dev/gopkg.in/natefinch/lumberjack.v2@v2.0.0#readme-cleaning-up-old-log-files
  "LogMaxBackups": 1,
  "LogMaxSize": 100, # MB
  "LogLevel": $LogLevel.INFO,
  "MailserversConfig": {
    "Enabled": true
  },
  "Name": "StatusDesktop",
  "NetworkId": 1,
  "NoDiscovery": true,
  "PermissionsConfig": {
    "Enabled": true
  },
  "Rendezvous": false,
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
    "Enabled": false,
    "BloomFilterMode": true,
    "LightClient": true,
    "MinimumPoW": 0.001
  },
  "WakuV2Config": {
    "Enabled": true,
    "Host": "0.0.0.0",
    "Port": WAKU_V2_PORT,
    "LightClient": false,
    "PersistPeers": true,
    "EnableDiscV5": true,
    "DiscoveryLimit": 20,
    "UDPPort": WAKU_V2_PORT,
    "PeerExchange": true,
    "AutoUpdate": true,
    "Rendezvous": true,
  },
  "WalletConfig": {
    "Enabled": true,
    "OpenseaAPIKey": OPENSEA_API_KEY_RESOLVED,
    "AlchemyAPIKeys": %* {
      "42161": ALCHEMY_ARBITRUM_MAINNET_TOKEN_RESOLVED,
      "421613": ALCHEMY_ARBITRUM_GOERLI_TOKEN_RESOLVED,
      "10": ALCHEMY_OPTIMISM_MAINNET_TOKEN_RESOLVED,
      "420": ALCHEMY_OPTIMISM_GOERLI_TOKEN_RESOLVED
    },
    "InfuraAPIKey": INFURA_TOKEN_RESOLVED,
    "InfuraAPIKeySecret": INFURA_TOKEN_SECRET_RESOLVED,
    "LoadAllTransfers": true,
  },
  "EnsConfig": {
    "Enabled": true
  },
  "Networks": NETWORKS,
  "TorrentConfig": {
    "Enabled": true,
    "Port": TORRENT_CONFIG_PORT,
    "DataDir": DEFAULT_TORRENT_CONFIG_DATADIR,
    "TorrentDir": DEFAULT_TORRENT_CONFIG_TORRENTDIR
  }
}
