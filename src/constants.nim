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

const APP_VERSION* = DESKTOP_VERSION

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
  KEYCARD_DATA_DIR* = joinPath(baseDir, "data", "keycard")
  KEYCARD_LOG_FILE_PATH* = joinPath(KEYCARD_DATA_DIR, "keycard.log")
  KEYCARDPAIRINGDATAFILE* = joinPath(KEYCARD_DATA_DIR, "pairings.json")

  # runtime variables
  TEST_MODE_ENABLED* = desktopConfig.testMode
  DISPLAY_MOCKED_KEYCARD_WINDOW* = desktopConfig.displayMockedKeycardWindow
  WALLET_ENABLED* = desktopConfig.enableWallet
  TORRENT_CONFIG_PORT* = desktopConfig.defaultTorentConfigPort
  LOG_LEVEL* = desktopConfig.logLevel
  FLEET_SELECTION_ENABLED* = desktopConfig.enableFleetSelection

  # build variables
  POKT_TOKEN_RESOLVED* = "foo"
  INFURA_TOKEN_RESOLVED* = "foo"
  INFURA_TOKEN_SECRET_RESOLVED* = "foo"
  ALCHEMY_ETHEREUM_MAINNET_TOKEN_RESOLVED* = "foo"
  ALCHEMY_ETHEREUM_SEPOLIA_TOKEN_RESOLVED* = "foo"
  ALCHEMY_ARBITRUM_MAINNET_TOKEN_RESOLVED* = "foo"
  ALCHEMY_ARBITRUM_SEPOLIA_TOKEN_RESOLVED* = "foo"
  ALCHEMY_OPTIMISM_MAINNET_TOKEN_RESOLVED* = "foo"
  ALCHEMY_OPTIMISM_SEPOLIA_TOKEN_RESOLVED* = "foo"
  ALCHEMY_BASE_MAINNET_TOKEN_RESOLVED* = "foo"
  ALCHEMY_BASE_SEPOLIA_TOKEN_RESOLVED* = "foo"
  OPENSEA_API_KEY_RESOLVED* = "foo"
  RARIBLE_MAINNET_API_KEY_RESOLVED* = "foo"
  RARIBLE_TESTNET_API_KEY_RESOLVED* = "foo"
  TENOR_API_KEY_RESOLVED* = "foo"
  STATUS_PROXY_STAGE_NAME_RESOLVED* = "foo"
  STATUS_PROXY_USER_RESOLVED* = "foo"
  STATUS_PROXY_PASSWORD_RESOLVED* = "foo"
  ETH_RPC_PROXY_USER_RESOLVED* = "foo"
  ETH_RPC_PROXY_PASSWORD_RESOLVED* = "foo"
  ETH_RPC_PROXY_URL_RESOLVED* = "foo"

  WALLET_CONNECT_PROJECT_ID* = BUILD_WALLET_CONNECT_PROJECT_ID
  MIXPANEL_APP_ID* = "foo"
  MIXPANEL_TOKEN* = "foo"
  BUILD_MODE* = if defined(production): "prod" else: "test"
  HTTP_API_ENABLED* = desktopConfig.httpApiEnabled
  WS_API_ENABLED* = desktopConfig.wsApiEnabled
  SENTRY_DSN_STATUS_GO* = BUILD_SENTRY_DSN_STATUS_GO
  SENTRY_DSN_STATUS_GO_DESKTOP* = BUILD_SENTRY_DSN_STATUS_DESKTOP
  API_LOGGING* = desktopConfig.apiLogging
  KEYCARD_LOGS_ENABLED* = if defined(production): false else: true
  METRICS_ENABLED* = desktopConfig.metricsEnabled
  METRICS_ADDRESS* = desktopConfig.metricsAddress

proc hasLogLevelOption*(): bool =
  for p in cliParams:
    if p.startswith("--log-level") or p.startsWith("--LOG_LEVEL"):
      return true
  return false

proc runtimeLogLevelSet*(): bool =
  return existsEnv(RUN_TIME_PREFIX & "_LOG_LEVEL") or hasLogLevelOption()

proc getStatusGoLogLevel*(): string =
  if LOG_LEVEL == "TRACE":
    return "DEBUG"
  return LOG_LEVEL

const MAIN_STATUS_SHARD_CLUSTER_ID* = 16
