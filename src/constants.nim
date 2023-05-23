import os, sequtils, strutils, strformat

import # vendor libs
  confutils

const DEFAULT_WALLET_ENABLED = true
let WALLET_ENABLED* = if (existsEnv("ENABLE_WALLET")):
              parseInt($getEnv("ENABLE_WALLET")) != 0
            else:
              DEFAULT_WALLET_ENABLED

## Added a constant here cause it's easier to check the app how it behaves 
## on other platform if we just change the value here
const IS_MACOS* = defined(macosx)

# For future supporting fingerprints on other platforms
const SUPPORTS_FINGERPRINT* = IS_MACOS

const sep* = when defined(windows): "\\" else: "/"

proc defaultDataDir*(): string =
  let homeDir = getHomeDir()
  let parentDir =
    if defined(development):
      parentDir(getAppDir())
    elif homeDir == "":
      getCurrentDir()
    elif IS_MACOS:
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
  absolutePath(joinPath(parentDir, "Status"))

type StatusDesktopConfig = object
    dataDir* {.
      defaultValue: defaultDataDir()
      desc: "Status Desktop data directory"
      abbr: "d" .}: string
    uri* {.
      defaultValue: ""
      desc: "status-app:// URI to open a chat or other"
      name: "uri" .}: string


# On macOS the first time when a user gets the "App downloaded from the
# internet" warning, and clicks the Open button, the OS passes a unique process
# serial number (PSN) as -psn_... command-line argument, which we remove before
# processing the arguments with nim-confutils.
# Credit: https://github.com/bitcoin/bitcoin/blame/b6e34afe9735faf97d6be7a90fafd33ec18c0cbb/src/util/system.cpp#L383-L389

var cliParams = commandLineParams()
if IS_MACOS:
  cliParams.keepIf(proc(p: string): bool = not p.startsWith("-psn_"))

let desktopConfig = StatusDesktopConfig.load(cliParams)

let
  baseDir = absolutePath(expandTilde(desktopConfig.dataDir))
  OPENURI* = desktopConfig.uri
  DATADIR* = baseDir & sep
  STATUSGODIR* = joinPath(baseDir, "data") & sep
  ROOTKEYSTOREDIR* = joinPath(baseDir, "data", "keystore")
  TMPDIR* = joinPath(baseDir, "tmp") & sep
  LOGDIR* = joinPath(baseDir, "logs") & sep
  KEYCARDPAIRINGDATAFILE* = joinPath(baseDir, "data", "keycard/pairings.json")

proc ensureDirectories*(dataDir, tmpDir, logDir: string) =
  createDir(dataDir)
  createDir(tmpDir)
  createDir(logDir)

# This is changed during compilation by reading the VERSION file
const DESKTOP_VERSION {.strdefine.} = "0.0.0"
# This is changed during compilation by executing git command
const GIT_COMMIT* {.strdefine.} = ""

const APP_VERSION* = if defined(production): DESKTOP_VERSION else: fmt("git master {GIT_COMMIT}")

# Name of the test environment var to check for
const TEST_ENVIRONMENT_VAR* = "TEST_ENVIRONMENT"
