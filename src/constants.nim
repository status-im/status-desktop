include env_cli_vars

## Added a constant here cause it's easier to check the app how it behaves
## on other platform if we just change the value here
const IS_MACOS* = defined(macosx)
const IS_INTEL* = defined(amd64)
# For future supporting fingerprints on other platforms
const SUPPORTS_FINGERPRINT* = IS_MACOS
# This is changed during compilation by reading the VERSION file
const DESKTOP_VERSION {.strdefine.} = "0.0.0"
const STATUSGO_VERSION* {.strdefine.} = "0.0.0"
# This is changed during compilation by executing git command
const GIT_COMMIT* {.strdefine.} = ""

const APP_VERSION* = if defined(production): DESKTOP_VERSION else: fmt("{GIT_COMMIT}")

const sep* = when defined(windows): "\\" else: "/"

################################################################################
# The following variables are set:
#
# - via CL arguments, if they are provided
# - otherwise via env variables, if they are provided
# - otherwise the default values are used
################################################################################
let
  baseDir = absolutePath(expandTilde(desktopConfig.dataDir))
  OPENURI* = desktopConfig.uri
  DATADIR* = baseDir & sep
  STATUSGODIR* = joinPath(baseDir, "data") & sep
  ROOTKEYSTOREDIR* = joinPath(baseDir, "data", "keystore")
  TMPDIR* = joinPath(baseDir, "tmp") & sep
  LOGDIR* = joinPath(baseDir, "logs") & sep
  KEYCARDPAIRINGDATAFILE* = joinPath(baseDir, "data", "keycard", "pairings.json")

  # runtime variables
  TEST_MODE_ENABLED* = desktopConfig.testMode
  DISPLAY_MOCKED_KEYCARD_WINDOW* = desktopConfig.displayMockedKeycardWindow
  WALLET_ENABLED* = desktopConfig.enableWallet
  TORRENT_CONFIG_PORT* = desktopConfig.defaultTorentConfigPort
  LOG_LEVEL* = desktopConfig.logLevel
  FLEET_SELECTION_ENABLED* = desktopConfig.enableFleetSelection

  # build variables
  POKT_TOKEN_RESOLVED* = desktopConfig.poktToken
  INFURA_TOKEN_RESOLVED* = desktopConfig.infuraToken
  INFURA_TOKEN_SECRET_RESOLVED* = desktopConfig.infuraTokenSecret
  ALCHEMY_ETHEREUM_MAINNET_TOKEN_RESOLVED* = desktopConfig.alchemyEthereumMainnetToken
  ALCHEMY_ETHEREUM_SEPOLIA_TOKEN_RESOLVED* = desktopConfig.alchemyEthereumSepoliaToken
  ALCHEMY_ARBITRUM_MAINNET_TOKEN_RESOLVED* = desktopConfig.alchemyArbitrumMainnetToken
  ALCHEMY_ARBITRUM_SEPOLIA_TOKEN_RESOLVED* = desktopConfig.alchemyArbitrumSepoliaToken
  ALCHEMY_OPTIMISM_MAINNET_TOKEN_RESOLVED* = desktopConfig.alchemyOptimismMainnetToken
  ALCHEMY_OPTIMISM_SEPOLIA_TOKEN_RESOLVED* = desktopConfig.alchemyOptimismSepoliaToken
  OPENSEA_API_KEY_RESOLVED* = desktopConfig.openseaApiKey
  RARIBLE_MAINNET_API_KEY_RESOLVED* = desktopConfig.raribleMainnetApiKey
  RARIBLE_TESTNET_API_KEY_RESOLVED* = desktopConfig.raribleTestnetApiKey
  TENOR_API_KEY_RESOLVED* = desktopConfig.tenorApiKey
  STATUS_PROXY_STAGE_NAME_RESOLVED* = desktopConfig.statusProxyStageName
  STATUS_PROXY_USER_RESOLVED* = desktopConfig.statusProxyUser
  STATUS_PROXY_PASSWORD_RESOLVED* = desktopConfig.statusProxyPassword
  WALLET_CONNECT_PROJECT_ID* = BUILD_WALLET_CONNECT_PROJECT_ID
  MIXPANEL_APP_ID* = desktopConfig.mixpanelAppId
  MIXPANEL_TOKEN* = desktopConfig.mixpanelToken
  BUILD_MODE* = if defined(production): "prod" else: "test"
  HTTP_API_ENABLED* = desktopConfig.httpApiEnabled
  WS_API_ENABLED* = desktopConfig.wsApiEnabled

proc hasLogLevelOption*(): bool =
  for p in cliParams:
    if p.startswith("--log-level") or p.startsWith("--LOG_LEVEL"):
      return true
  return false

proc runtimeLogLevelSet*(): bool =
  return existsEnv(RUN_TIME_PREFIX & "_LOG_LEVEL") or hasLogLevelOption()

const MAIN_STATUS_SHARD_CLUSTER_ID* = 16
