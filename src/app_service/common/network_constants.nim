import json
import ../../constants as main_constants

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
    "PoktAPIKey": POKT_TOKEN_RESOLVED,
    "LoadAllTransfers": true,
  },
  "TorrentConfig": {
    "Enabled": true,
    "Port": TORRENT_CONFIG_PORT,
    "DataDir": DEFAULT_TORRENT_CONFIG_DATADIR,
    "TorrentDir": DEFAULT_TORRENT_CONFIG_TORRENTDIR
  },
  "OutputMessageCSVEnabled": false
}
