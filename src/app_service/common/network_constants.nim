import json
import ../../constants as main_constants
import strformat

let STATUS_PROXY_HOST = "api.status.im"

var NETWORKS* = %* [
  {
    "chainId": 1,
    "chainName": "Mainnet",
    "defaultRpcUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/grove/ethereum/mainnet/{POKT_TOKEN_RESOLVED}",
    "defaultFallbackUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/infura/ethereum/mainnet/{INFURA_TOKEN_RESOLVED}",
    "rpcUrl": "https://eth-archival.rpc.grove.city/v1/" & POKT_TOKEN_RESOLVED,
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
    "relatedChainId": 5,
  },
  {
    "chainId": 5,
    "chainName": "Mainnet",
    "rpcUrl": "https://goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "fallbackUrl": "",
    "blockExplorerUrl": "https://goerli.etherscan.io/",
    "iconUrl": "network/Network=Ethereum",
    "chainColor": "#627EEA",
    "shortName": "eth",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest": true,
    "layer": 1,
    "enabled": true,
    "relatedChainId": 1,
  },
  {
    "chainId": 10,
    "chainName": "Optimism",
    "defaultRpcUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/grove/optimism/mainnet/{POKT_TOKEN_RESOLVED}",
    "defaultFallbackUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/infura/optimism/mainnet/{INFURA_TOKEN_RESOLVED}",
    "rpcUrl": "https://optimism-archival.rpc.grove.city/v1/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://optimism-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://optimistic.etherscan.io",
    "iconUrl": "network/Network=Optimism",
    "chainColor": "#E90101",
    "shortName": "oeth",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  false,
    "layer":   2,
    "enabled": true,
    "relatedChainId": 420,
  },
  {
    "chainId": 420,
    "chainName": "Optimism",
    "rpcUrl": "https://optimism-goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "fallbackUrl": "",
    "blockExplorerUrl": "https://goerli-optimism.etherscan.io/",
    "iconUrl": "network/Network=Optimism",
    "chainColor": "#E90101",
    "shortName": "oeth",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": true,
    "relatedChainId": 10,
  },
  {
    "chainId": 42161,
    "chainName": "Arbitrum",
    "defaultRpcUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/grove/arbitrum/mainnet/{POKT_TOKEN_RESOLVED}",
    "defaultFallbackUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/infura/arbitrum/mainnet/{INFURA_TOKEN_RESOLVED}",
    "rpcUrl": "https://arbitrum-one.rpc.grove.city/v1/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://arbitrum-mainnet.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://arbiscan.io/",
    "iconUrl": "network/Network=Arbitrum",
    "chainColor": "#51D0F0",
    "shortName": "arb1",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  false,
    "layer":   2,
    "enabled": true,
    "relatedChainId": 421613,
  },
  {
    "chainId": 421613,
    "chainName": "Arbitrum",
    "rpcUrl": "https://arbitrum-goerli.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "fallbackUrl": "",
    "blockExplorerUrl": "https://goerli.arbiscan.io/",
    "iconUrl": "network/Network=Arbitrum",
    "chainColor": "#51D0F0",
    "shortName": "arb1",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": true,
    "relatedChainId": 42161,
  },
  {
    "chainId": 11155111,
    "chainName": "Mainnet",
    "defaultRpcUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/grove/ethereum/sepolia/{POKT_TOKEN_RESOLVED}",
    "defaultFallbackUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/infura/ethereum/sepolia/{INFURA_TOKEN_RESOLVED}",
    "rpcUrl": "https://sepolia-archival.rpc.grove.city/v1/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://sepolia.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://sepolia.etherscan.io/",
    "iconUrl": "network/Network=Ethereum",
    "chainColor": "#627EEA",
    "shortName": "eth",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   1,
    "enabled": true,
    "relatedChainId": 1,
   },
   {
    "chainId": 11155420,
    "chainName": "Optimism",
    "defaultRpcUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/grove/optimism/sepolia/{POKT_TOKEN_RESOLVED}",
    "defaultFallbackUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/infura/optimism/sepolia/{INFURA_TOKEN_RESOLVED}",
    "rpcUrl": "https://optimism-sepolia-archival.rpc.grove.city/v1/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://optimism-sepolia.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://sepolia-optimism.etherscan.io/",
    "iconUrl": "network/Network=Optimism",
    "chainColor": "#E90101",
    "shortName": "oeth",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": true,
    "relatedChainId": 10,
   },
   {
    "chainId": 421614,
    "chainName": "Arbitrum",
    "defaultRpcUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/grove/arbitrum/sepolia/{POKT_TOKEN_RESOLVED}",
    "defaultFallbackUrl": fmt"https://{STATUS_PROXY_STAGE_NAME_RESOLVED}.{STATUS_PROXY_HOST}/infura/arbitrum/sepolia/{INFURA_TOKEN_RESOLVED}",
    "rpcUrl": "https://arbitrum-sepolia-archival.rpc.grove.city/v1/" & POKT_TOKEN_RESOLVED,
    "fallbackUrl": "https://arbitrum-sepolia.infura.io/v3/" & INFURA_TOKEN_RESOLVED,
    "blockExplorerUrl": "https://sepolia-explorer.arbitrum.io/",
    "iconUrl": "network/Network=Arbitrum",
    "chainColor": "#51D0F0",
    "shortName": "arb1",
    "nativeCurrencyName": "Ether",
    "nativeCurrencySymbol": "ETH",
    "nativeCurrencyDecimals": 18,
    "isTest":  true,
    "layer":   2,
    "enabled": true,
    "relatedChainId": 42161,
  }
]

var NODE_CONFIG* = %* {
  "BrowsersConfig": {
    "Enabled": true
  },
  "ClusterConfig": {
    "Enabled": true,
    "ClusterID": MAIN_STATUS_SHARD_CLUSTER_ID
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
  "LogLevel": main_constants.DEFAULT_LOG_LEVEL,
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
    "EnableFilterFullNode": true,
    "UseShardAsDefaultTopic": true,
  },
  # Don't add properties to the login node config that can be changed from within the app
  "WalletConfig": {
    "Enabled": true,
    "OpenseaAPIKey": OPENSEA_API_KEY_RESOLVED,
    "RaribleMainnetAPIKey": RARIBLE_MAINNET_API_KEY_RESOLVED,
    "RaribleTestnetAPIKey": RARIBLE_TESTNET_API_KEY_RESOLVED,
    "AlchemyAPIKeys": %* {
      "1": ALCHEMY_ETHEREUM_MAINNET_TOKEN_RESOLVED,
      "5": ALCHEMY_ETHEREUM_GOERLI_TOKEN_RESOLVED,
      "11155111": ALCHEMY_ETHEREUM_SEPOLIA_TOKEN_RESOLVED,
      "42161": ALCHEMY_ARBITRUM_MAINNET_TOKEN_RESOLVED,
      "421613": ALCHEMY_ARBITRUM_GOERLI_TOKEN_RESOLVED,
      "421614": ALCHEMY_ARBITRUM_SEPOLIA_TOKEN_RESOLVED,
      "10": ALCHEMY_OPTIMISM_MAINNET_TOKEN_RESOLVED,
      "420": ALCHEMY_OPTIMISM_GOERLI_TOKEN_RESOLVED,
      "11155420": ALCHEMY_OPTIMISM_SEPOLIA_TOKEN_RESOLVED
    },
    "InfuraAPIKey": INFURA_TOKEN_RESOLVED,
    "InfuraAPIKeySecret": INFURA_TOKEN_SECRET_RESOLVED,
    "LoadAllTransfers": true,
  },
  "Networks": NETWORKS,
  "TorrentConfig": {
    "Enabled": false,
    "Port": TORRENT_CONFIG_PORT,
    "DataDir": DEFAULT_TORRENT_CONFIG_DATADIR,
    "TorrentDir": DEFAULT_TORRENT_CONFIG_TORRENTDIR
  },
  "OutputMessageCSVEnabled": false
}
