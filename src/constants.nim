include env_cli_vars

## Added a constant here cause it's easier to check the app how it behaves
## on other platform if we just change the value here
const IS_MACOS* = defined(macosx)
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
  KEYCARDPAIRINGDATAFILE* = joinPath(baseDir, "data", "keycard/pairings.json")
  DEFAULT_TORRENT_CONFIG_DATADIR* = joinPath(baseDir, "data", "archivedata")
  DEFAULT_TORRENT_CONFIG_TORRENTDIR* = joinPath(baseDir, "data", "torrents")

  # runtime variables
  TEST_MODE_ENABLED* = desktopConfig.testMode
  WALLET_ENABLED* = desktopConfig.enableWallet
  TORRENT_CONFIG_PORT* = desktopConfig.defaultTorentConfigPort
  WAKU_V2_PORT* = desktopConfig.defaultWakuV2Port
  STATUS_PORT* = desktopConfig.statusPort
  LOG_LEVEL* = desktopConfig.logLevel

  # build variables
  POKT_TOKEN_RESOLVED* = desktopConfig.poktToken
  INFURA_TOKEN_RESOLVED* = desktopConfig.infuraToken
  INFURA_TOKEN_SECRET_RESOLVED* = desktopConfig.infuraTokenSecret
  ALCHEMY_ETHEREUM_MAINNET_TOKEN_RESOLVED* = desktopConfig.alchemyEthereumMainnetToken
  ALCHEMY_ETHEREUM_GOERLI_TOKEN_RESOLVED* = desktopConfig.alchemyEthereumGoerliToken
  ALCHEMY_ETHEREUM_SEPOLIA_TOKEN_RESOLVED* = desktopConfig.alchemyEthereumSepoliaToken
  ALCHEMY_ARBITRUM_MAINNET_TOKEN_RESOLVED* = desktopConfig.alchemyArbitrumMainnetToken
  ALCHEMY_ARBITRUM_GOERLI_TOKEN_RESOLVED* = desktopConfig.alchemyArbitrumGoerliToken
  ALCHEMY_ARBITRUM_SEPOLIA_TOKEN_RESOLVED* = desktopConfig.alchemyArbitrumSepoliaToken
  ALCHEMY_OPTIMISM_MAINNET_TOKEN_RESOLVED* = desktopConfig.alchemyOptimismMainnetToken
  ALCHEMY_OPTIMISM_GOERLI_TOKEN_RESOLVED* = desktopConfig.alchemyOptimismGoerliToken
  ALCHEMY_OPTIMISM_SEPOLIA_TOKEN_RESOLVED* = desktopConfig.alchemyOptimismSepoliaToken
  OPENSEA_API_KEY_RESOLVED* = desktopConfig.openseaApiKey
  RARIBLE_MAINNET_API_KEY_RESOLVED* = desktopConfig.raribleMainnetApiKey
  RARIBLE_TESTNET_API_KEY_RESOLVED* = desktopConfig.raribleTestnetApiKey
  TENOR_API_KEY_RESOLVED* = desktopConfig.tenorApiKey
  WALLET_CONNECT_PROJECT_ID* = BUILD_WALLET_CONNECT_PROJECT_ID

proc hasLogLevelOption*(): bool =
  for p in cliParams:
    if p.startswith("--log-level") or p.startsWith("--LOG_LEVEL"):
      return true
  return false

proc runtimeLogLevelSet*(): bool =
  return existsEnv(RUN_TIME_PREFIX & "_LOG_LEVEL") or hasLogLevelOption()
