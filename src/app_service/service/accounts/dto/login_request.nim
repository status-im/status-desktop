import json, std/options
import wallet_secretes_config

export wallet_secretes_config

type
  LoginAccountRequest* = object
    passwordHash*: string
    keyUID*: string
    kdfIterations*: int
    runtimeLogLevel*: string
    wakuV2Nameserver*: string
    bandwidthStatsEnabled*: bool
    keycardWhisperPrivateKey*: string
    mnemonic*: string
    walletSecretsConfig*: WalletSecretsConfig
    apiConfig*: Option[JsonNode]

proc toJson*(self: LoginAccountRequest): JsonNode =
  result = %* {
    "password": self.passwordHash,
    "keyUid": self.keyUID,
    "kdfIterations": self.kdfIterations,
    "runtimeLogLevel": self.runtimeLogLevel,
    "wakuV2Nameserver": self.wakuV2Nameserver,
    "bandwidthStatsEnabled": self.bandwidthStatsEnabled,
    "keycardWhisperPrivateKey": self.keycardWhisperPrivateKey,
    "mnemonic": self.mnemonic,
  }
  for key, value in self.walletSecretsConfig.toJson().pairs():
    result[key] = value

  if self.apiConfig.isSome():
    result["apiConfig"] = %self.apiConfig.get()
