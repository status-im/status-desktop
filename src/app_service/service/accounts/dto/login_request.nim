import json, std/options
import wallet_secretes_config
import api_config

export wallet_secretes_config
export api_config

type LoginAccountRequest* = object
  passwordHash*: string
  keyUID*: string
  kdfIterations*: int
  runtimeLogLevel*: string
  wakuV2Nameserver*: string
  bandwidthStatsEnabled*: bool
  keycardWhisperPrivateKey*: string
  mnemonic*: string
  walletSecretsConfig*: WalletSecretsConfig
  apiConfig*: APIConfig
  statusProxyEnabled*: bool

proc toJson*(self: LoginAccountRequest): JsonNode =
  result =
    %*{
      "password": self.passwordHash,
      "keyUid": self.keyUID,
      "kdfIterations": self.kdfIterations,
      "runtimeLogLevel": self.runtimeLogLevel,
      "wakuV2Nameserver": self.wakuV2Nameserver,
      "bandwidthStatsEnabled": self.bandwidthStatsEnabled,
      "keycardWhisperPrivateKey": self.keycardWhisperPrivateKey,
      "mnemonic": self.mnemonic,
      "apiConfig": self.apiConfig,
      "statusProxyEnabled": self.statusProxyEnabled,
    }
  for key, value in self.walletSecretsConfig.toJson().pairs():
    result[key] = value
