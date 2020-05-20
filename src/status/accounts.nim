import libstatus
import json
import utils
import os

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

proc ensureDir(dirname: string) =
  if not existsDir(dirname):
    # removeDir(dirname)
    createDir(dirname)

proc initNodeAccounts*() =
  const datadir = "./data/"
  const keystoredir = "./data/keystore/"
  const nobackupdir = "./noBackup/"

  ensureDir(datadir)
  ensureDir(keystoredir)
  ensureDir(nobackupdir)

  # 1
  discard $libstatus.initKeystore(keystoredir);
  # 2
  discard $libstatus.openAccounts(datadir);
