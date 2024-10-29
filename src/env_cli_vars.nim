import os, sequtils, strutils, stew/shims/strformat, chronicles

import app/global/feature_flags

import # vendor libs
  confutils

const BUILD_TIME_PREFIX = "STATUS_BUILD_"
const RUN_TIME_PREFIX = "STATUS_RUNTIME"

# default log level value
const DEFAULT_LOG_LEVEL* = if defined(production): $LogLevel.INFO else: $LogLevel.DEBUG

# build vars base name
const BASE_NAME_INFURA_TOKEN = "INFURA_TOKEN"
const BASE_NAME_INFURA_TOKEN_SECRET = "INFURA_TOKEN_SECRET"
const BASE_NAME_POKT_TOKEN = "POKT_TOKEN"
const BASE_NAME_OPENSEA_API_KEY = "OPENSEA_API_KEY"
const BASE_NAME_RARIBLE_MAINNET_API_KEY = "RARIBLE_MAINNET_API_KEY"
const BASE_NAME_RARIBLE_TESTNET_API_KEY = "RARIBLE_TESTNET_API_KEY"
const BASE_NAME_ALCHEMY_ETHEREUM_MAINNET_TOKEN = "ALCHEMY_ETHEREUM_MAINNET_TOKEN"
const BASE_NAME_ALCHEMY_ETHEREUM_SEPOLIA_TOKEN = "ALCHEMY_ETHEREUM_SEPOLIA_TOKEN"
const BASE_NAME_ALCHEMY_ARBITRUM_MAINNET_TOKEN = "ALCHEMY_ARBITRUM_MAINNET_TOKEN"
const BASE_NAME_ALCHEMY_ARBITRUM_SEPOLIA_TOKEN = "ALCHEMY_ARBITRUM_SEPOLIA_TOKEN"
const BASE_NAME_ALCHEMY_OPTIMISM_MAINNET_TOKEN = "ALCHEMY_OPTIMISM_MAINNET_TOKEN"
const BASE_NAME_ALCHEMY_OPTIMISM_SEPOLIA_TOKEN = "ALCHEMY_OPTIMISM_SEPOLIA_TOKEN"
const BASE_NAME_TENOR_API_KEY = "TENOR_API_KEY"
const BASE_NAME_STATUS_PROXY_STAGE_NAME = "PROXY_STAGE_NAME"
const BASE_NAME_STATUS_PROXY_USER = "PROXY_USER"
const BASE_NAME_STATUS_PROXY_PASSWORD = "PROXY_PASSWORD"
const BASE_NAME_WALLET_CONNECT_PROJECT_ID = "WALLET_CONNECT_PROJECT_ID"
const BASE_NAME_MIXPANEL_APP_ID = "MIXPANEL_APP_ID"
const BASE_NAME_MIXPANEL_TOKEN = "MIXPANEL_TOKEN"


################################################################################
# Build time evaluated variables
################################################################################

const
  DEFAULT_INFURA_TOKEN = "220a1abb4b6943a093c35d0ce4fb0732"
  BUILD_INFURA_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_INFURA_TOKEN, DEFAULT_INFURA_TOKEN)
const BUILD_INFURA_TOKEN_SECRET = getEnv(BUILD_TIME_PREFIX & BASE_NAME_INFURA_TOKEN_SECRET)
const
  DEFAULT_POKT_TOKEN = "849214fd2f85acead08f5184"
  BUILD_POKT_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_POKT_TOKEN, DEFAULT_POKT_TOKEN)
const
  DEFAULT_MIXPANEL_APP_ID = "3350627"
  BUILD_MIXPANEL_APP_ID = getEnv(BUILD_TIME_PREFIX & BASE_NAME_MIXPANEL_APP_ID, DEFAULT_MIXPANEL_APP_ID)
  DEFAULT_MIXPANEL_TOKEN = "5c73bda2d36a9f688a5ee45641fb6775"
  BUILD_MIXPANEL_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_MIXPANEL_TOKEN, DEFAULT_MIXPANEL_TOKEN)
const BUILD_OPENSEA_API_KEY = getEnv(BUILD_TIME_PREFIX & BASE_NAME_OPENSEA_API_KEY)
const BUILD_RARIBLE_MAINNET_API_KEY = getEnv(BUILD_TIME_PREFIX & BASE_NAME_RARIBLE_MAINNET_API_KEY)
const BUILD_RARIBLE_TESTNET_API_KEY = getEnv(BUILD_TIME_PREFIX & BASE_NAME_RARIBLE_TESTNET_API_KEY)
const BUILD_ALCHEMY_ETHEREUM_MAINNET_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_ALCHEMY_ETHEREUM_MAINNET_TOKEN)
const BUILD_ALCHEMY_ETHEREUM_SEPOLIA_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_ALCHEMY_ETHEREUM_SEPOLIA_TOKEN)
const BUILD_ALCHEMY_ARBITRUM_MAINNET_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_ALCHEMY_ARBITRUM_MAINNET_TOKEN)
const BUILD_ALCHEMY_ARBITRUM_SEPOLIA_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_ALCHEMY_ARBITRUM_SEPOLIA_TOKEN)
const BUILD_ALCHEMY_OPTIMISM_MAINNET_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_ALCHEMY_OPTIMISM_MAINNET_TOKEN)
const BUILD_ALCHEMY_OPTIMISM_SEPOLIA_TOKEN = getEnv(BUILD_TIME_PREFIX & BASE_NAME_ALCHEMY_OPTIMISM_SEPOLIA_TOKEN)

const
  DEFAULT_STATUS_PROXY_STAGE_NAME = "test"
  BUILD_STATUS_PROXY_STAGE_NAME = getEnv(BUILD_TIME_PREFIX & BASE_NAME_STATUS_PROXY_STAGE_NAME, DEFAULT_STATUS_PROXY_STAGE_NAME)
const BUILD_STATUS_PROXY_USER = getEnv(BUILD_TIME_PREFIX & BASE_NAME_STATUS_PROXY_USER)
const BUILD_STATUS_PROXY_PASSWORD = getEnv(BUILD_TIME_PREFIX & BASE_NAME_STATUS_PROXY_PASSWORD)

const
  DEFAULT_TENOR_API_KEY = "DU7DWZ27STB2"
  BUILD_TENOR_API_KEY = getEnv(BUILD_TIME_PREFIX & BASE_NAME_TENOR_API_KEY, DEFAULT_TENOR_API_KEY)
const
  WALLET_CONNECT_STATUS_PROJECT_ID = "87815d72a81d739d2a7ce15c2cfdefb3"
  BUILD_WALLET_CONNECT_PROJECT_ID = getEnv(BUILD_TIME_PREFIX & BASE_NAME_WALLET_CONNECT_PROJECT_ID, WALLET_CONNECT_STATUS_PROJECT_ID)

################################################################################
# Run time evaluated variables
################################################################################

proc defaultDataDir*(): string =
  try:
    let homeDir = getHomeDir()
    let parentDir =
      if defined(development):
        parentDir(getAppDir())
      elif homeDir == "":
        getCurrentDir()
      elif defined(macosx):
        joinPath(homeDir, "Library", "Application Support")
      elif defined(windows):
        let targetDir = getEnv("LOCALAPPDATA").string
        if targetDir == "":
          joinPath(homeDir, "AppData", "Local")
        else:
          targetDir
      else:
        let targetDir = getEnv("XDG_CONFIG_HOME").string
        if targetDir == "":
          joinPath(homeDir, ".config")
        else:
          targetDir
    return absolutePath(joinPath(parentDir, "Status"))
  except OSError:
    echo "Error: Unable to determine home directory."

type StatusDesktopConfig = object
  # runtime counterparts vars of build vars
  infuraToken* {.
    defaultValue: BUILD_INFURA_TOKEN
    desc: "Sets infura token"
    name: $BASE_NAME_INFURA_TOKEN
    abbr: "infura-token" .}: string
  infuraTokenSecret* {.
    defaultValue: BUILD_INFURA_TOKEN_SECRET
    desc: "Sets infura token secret"
    name: $BASE_NAME_INFURA_TOKEN_SECRET
    abbr: "infura-token-secret" .}: string
  poktToken* {.
    defaultValue: BUILD_POKT_TOKEN
    desc: "Sets pokt token"
    name: $BASE_NAME_POKT_TOKEN
    abbr: "pokt-token" .}: string
  mixpanelAppId* {.
    defaultValue: BUILD_MIXPANEL_APP_ID
    desc: "Sets mixpanel app id"
    name: $BASE_NAME_MIXPANEL_APP_ID
    abbr: "mixpanel-app-id" .}: string
  mixpanelToken* {.
    defaultValue: BUILD_MIXPANEL_TOKEN
    desc: "Sets mixpanel token"
    name: $BASE_NAME_MIXPANEL_TOKEN
    abbr: "mixpanel-token" .}: string
  openseaApiKey* {.
    defaultValue: BUILD_OPENSEA_API_KEY
    desc: "Sets open sea api key"
    name: $BASE_NAME_OPENSEA_API_KEY
    abbr: "open-sea-api-key" .}: string
  raribleMainnetApiKey* {.
    defaultValue: BUILD_RARIBLE_MAINNET_API_KEY
    desc: "Sets rarible mainnet api key"
    name: $BASE_NAME_RARIBLE_MAINNET_API_KEY
    abbr: "rarible-mainnet-api-key" .}: string
  raribleTestnetApiKey* {.
    defaultValue: BUILD_RARIBLE_TESTNET_API_KEY
    desc: "Sets rarible testnet api key"
    name: $BASE_NAME_RARIBLE_TESTNET_API_KEY
    abbr: "rarible-testnet-api-key" .}: string
  alchemyEthereumMainnetToken* {.
    defaultValue: BUILD_ALCHEMY_ETHEREUM_MAINNET_TOKEN
    desc: "Sets alchemy ethereum mainnet token"
    name: $BASE_NAME_ALCHEMY_ETHEREUM_MAINNET_TOKEN
    abbr: "alchemy-ethereum-mainnet-token" .}: string
  alchemyEthereumSepoliaToken* {.
    defaultValue: BUILD_ALCHEMY_ETHEREUM_SEPOLIA_TOKEN
    desc: "Sets alchemy ethereum sepolia token"
    name: $BASE_NAME_ALCHEMY_ETHEREUM_SEPOLIA_TOKEN
    abbr: "alchemy-ethereum-sepolia-token" .}: string
  alchemyArbitrumMainnetToken* {.
    defaultValue: BUILD_ALCHEMY_ARBITRUM_MAINNET_TOKEN
    desc: "Sets alchemy arbitrum mainnet token"
    name: $BASE_NAME_ALCHEMY_ARBITRUM_MAINNET_TOKEN
    abbr: "alchemy-arbitrum-mainnet-token" .}: string
  alchemyArbitrumSepoliaToken* {.
    defaultValue: BUILD_ALCHEMY_ARBITRUM_SEPOLIA_TOKEN
    desc: "Sets alchemy arbitrum sepolia token"
    name: $BASE_NAME_ALCHEMY_ARBITRUM_SEPOLIA_TOKEN
    abbr: "alchemy-arbitrum-sepolia-token" .}: string
  alchemyOptimismMainnetToken* {.
    defaultValue: BUILD_ALCHEMY_OPTIMISM_MAINNET_TOKEN
    desc: "Sets alchemy optimism mainnet token"
    name: $BASE_NAME_ALCHEMY_OPTIMISM_MAINNET_TOKEN
    abbr: "alchemy-optimism-mainnet-token" .}: string
  alchemyOptimismSepoliaToken* {.
    defaultValue: BUILD_ALCHEMY_OPTIMISM_SEPOLIA_TOKEN
    desc: "Sets alchemy optimism sepolia token"
    name: $BASE_NAME_ALCHEMY_OPTIMISM_SEPOLIA_TOKEN
    abbr: "alchemy-optimism-sepolia-token" .}: string
  tenorApiKey* {.
    defaultValue: BUILD_TENOR_API_KEY
    desc: "Sets tenor api key"
    name: $BASE_NAME_TENOR_API_KEY
    abbr: "tenor-api-key" .}: string
  statusProxyStageName* {.
    defaultValue: BUILD_STATUS_PROXY_STAGE_NAME
    desc: "Sets status proxy stage name"
    name: $BASE_NAME_STATUS_PROXY_STAGE_NAME
    abbr: "status-proxy-stage-name" .}: string
  statusProxyUser* {.
    defaultValue: BUILD_STATUS_PROXY_USER
    desc: "Sets status proxy username"
    name: $BASE_NAME_STATUS_PROXY_USER
    abbr: "status-proxy-user" .}: string
  statusProxyPassword* {.
    defaultValue: BUILD_STATUS_PROXY_PASSWORD
    desc: "Sets status proxy password"
    name: $BASE_NAME_STATUS_PROXY_PASSWORD
    abbr: "status-proxy-password" .}: string

  # runtime vars
  dataDir* {.
    defaultValue: defaultDataDir()
    desc: "Status Desktop data directory"
    abbr: "d" .}: string
  uri* {.
    defaultValue: ""
    desc: "status-app:// URI to open a chat or other"
    name: "uri" .}: string
  testMode* {.
    defaultValue: false
    desc: "Determines if the app should be run in test mode"
    name: "TEST_MODE"
    abbr: "test-mode" .}: bool
  enableWallet* {.
    defaultValue: true
    desc: "Determines if the wallet section is enabled"
    name: "ENABLE_WALLET"
    abbr: "enable-wallet" .}: bool
  defaultTorentConfigPort* {.
    defaultValue: 0
    desc: "Sets default torrent config port"
    name: "DEFAULT_TORRENT_CONFIG_PORT"
    abbr: "default-torrent-config-port" .}: int
  logLevel* {.
    defaultValue: DEFAULT_LOG_LEVEL
    desc: "Sets log level"
    longdesc: "Can be one of: \"ERROR\", \"WARN\", \"INFO\", \"DEBUG\", \"TRACE\". \"INFO\" in production build, otherwise \"DEBUG\""
    name: "LOG_LEVEL"
    abbr: "log-level" .}: string
  enableFleetSelection* {.
    defaultValue: false
    desc: "Determines if the fleet selection UI is enabled"
    name: "ENABLE_FLEET_SELECTION"
    abbr: "enable-fleet-selection" .}: bool
  displayMockedKeycardWindow* {.
    defaultValue: false
    desc: "Determines if the app should use mocked keycard"
    name: "USE_MOCKED_KEYCARD"
    abbr: "use-mocked-keycard" .}: bool
  httpApiEnabled* {.
    defaultValue: getEnv("FLAG_CONNECTOR_ENABLED", boolToEnv(DEFAULT_FLAG_CONNECTOR_ENABLED)) != "0"
    desc: "Enable HTTP RPC API"
    name: "HTTP_API"
    abbr: "http-api" .}: bool
  wsApiEnabled* {.
    defaultValue: getEnv("FLAG_CONNECTOR_ENABLED", boolToEnv(DEFAULT_FLAG_CONNECTOR_ENABLED)) != "0"
    desc: "Enable WebSocket RPC API"
    name: "WS_API"
    abbr: "ws-api" .}: bool

# On macOS the first time when a user gets the "App downloaded from the
# internet" warning, and clicks the Open button, the OS passes a unique process
# serial number (PSN) as -psn_... command-line argument, which we remove before
# processing the arguments with nim-confutils.
# Credit: https://github.com/bitcoin/bitcoin/blame/b6e34afe9735faf97d6be7a90fafd33ec18c0cbb/src/util/system.cpp#L383-L389

var cliParams = commandLineParams()
if defined(macosx):
  cliParams.keepIf(proc(p: string): bool = not p.startsWith("-psn_"))

let desktopConfig = StatusDesktopConfig.load(cmdLine = cliParams, envVarsPrefix = RUN_TIME_PREFIX)
