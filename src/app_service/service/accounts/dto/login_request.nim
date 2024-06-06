import json
import ./wallet_secretes_config

type
  LoginAccountRequest* = object
    passwordHash*: string
    keyUID*: string
    kdfIterations*: int
    runtimeLogLevel*: string
    wakuV2Nameserver*: string
    bandwidthStatsEnabled*: bool
    keycardWhisperPrivateKey*: string
    walletSecretsConfig*: WalletSecretsConfig

proc toJson*(self: LoginAccountRequest): JsonNode =
  result = %* {
    "password": self.passwordHash,
    "keyUid": self.keyUID,
    "kdfIterations": self.kdfIterations,
    "runtimeLogLevel": self.runtimeLogLevel,
    "wakuV2Nameserver": self.wakuV2Nameserver,
    "bandwidthStatsEnabled": self.bandwidthStatsEnabled,
    "keycardWhisperPrivateKey": self.keycardWhisperPrivateKey,
  }
  for key, value in self.walletSecretsConfig.toJson().pairs():
    result[key] = value
