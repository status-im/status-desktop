import types

proc hashMessage*(p0: cstring): cstring {.importc: "HashMessage".}

proc initKeystore*(keydir: cstring): cstring {.importc: "InitKeystore".}

proc openAccounts*(datadir: cstring): cstring {.importc: "OpenAccounts".}

proc multiAccountGenerateAndDeriveAddresses*(paramsJSON: cstring): cstring {.importc: "MultiAccountGenerateAndDeriveAddresses".}

proc multiAccountStoreDerivedAccounts*(paramsJSON: cstring): cstring {.importc: "MultiAccountStoreDerivedAccounts".}

proc multiAccountImportMnemonic*(paramsJSON: cstring): cstring {.importc: "MultiAccountImportMnemonic".}

proc MultiAccountImportPrivateKey*(paramsJSON: cstring): cstring {.importc: "MultiAccountImportPrivateKey".}

proc multiAccountDeriveAddresses*(paramsJSON: cstring): cstring {.importc: "MultiAccountDeriveAddresses".}

proc saveAccountAndLogin*(accountData: cstring, password: cstring, settingsJSON: cstring, configJSON: cstring, subaccountData: cstring): cstring {.importc: "SaveAccountAndLogin".}

proc callRPC*(inputJSON: cstring): cstring {.importc: "CallRPC".}

proc callPrivateRPC*(inputJSON: cstring): cstring {.importc: "CallPrivateRPC".}

proc addPeer*(peer: cstring): cstring {.importc: "AddPeer".}

proc setSignalEventCallback*(callback: SignalCallback) {.importc: "SetSignalEventCallback".}

proc sendTransaction*(jsonArgs: cstring, password: cstring): cstring {.importc: "SendTransaction".}

proc generateAlias*(p0: GoString): cstring {.importc: "GenerateAlias".}

proc identicon*(p0: GoString): cstring {.importc: "Identicon".}

proc login*(acctData: cstring, password: cstring): cstring {.importc: "Login".}

proc logout*(): cstring {.importc: "Logout".}

proc verifyAccountPassword*(keyStoreDir: cstring, address: cstring, password: cstring): cstring {.importc: "VerifyAccountPassword".}

proc validateMnemonic*(mnemonic: cstring): cstring {.importc: "ValidateMnemonic".}
