import libstatus
import json
import utils

proc generateAddresses*(): string =
  let multiAccountConfig = %* {
    "n": 5,
    "mnemonicPhraseLength": 12,
    "bip39Passphrase": "",
    "paths": ["m/43'/60'/1581'/0'/0", "m/44'/60'/0'/0/0"]
  }
  result = $libstatus.multiAccountGenerateAndDeriveAddresses($multiAccountConfig)

proc generateAlias*(publicKey: string): string =
  result = $libstatus.generateAlias(publicKey.toGoString)
