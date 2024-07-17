import NimQml
import chronicles

import app_service/service/wallet_connect/service as wallet_connect_service
import app_service/service/wallet_account/service as wallet_account_service

import helpers

logScope:
  topics = "wallet-connect-controller"


QtObject:
  type
    Controller* = ref object of QObject
      service: wallet_connect_service.Service
      walletAccountService: wallet_account_service.Service

  proc delete*(self: Controller) =
    self.QObject.delete

  proc newController*(service: wallet_connect_service.Service, walletAccountService: wallet_account_service.Service): Controller =
    new(result, delete)

    result.service = service
    result.walletAccountService = walletAccountService

    result.QObject.setup

  proc addWalletConnectSession*(self: Controller, session_json: string): bool {.slot.} =
    return self.service.addSession(session_json)

  proc deactivateWalletConnectSession*(self: Controller, topic: string): bool {.slot.} =
    return self.service.deactivateSession(topic)

  proc updateSessionsMarkedAsActive*(self: Controller, activeTopicsJson: string) {.slot.} =
    self.service.updateSessionsMarkedAsActive(activeTopicsJson)

  proc dappsListReceived*(self: Controller, dappsJson: string) {.signal.}

  # Emits signal dappsListReceived with the list of dApps
  proc getDapps*(self: Controller): bool {.slot.} =
    let res = self.service.getDapps()
    if res == "":
      return false
    else:
      self.dappsListReceived(res)
      return true

  proc userAuthenticationResult*(self: Controller, topic: string, id: string, error: bool, password: string, pin: string, payload: string) {.signal.}

  # Beware, it will fail if an authentication is already in progress
  proc authenticateUser*(self: Controller, topic: string, id: string, address: string, payload: string): bool {.slot.} =
    let acc = self.walletAccountService.getAccountByAddress(address)
    if acc.keyUid == "":
      return false

    return self.service.authenticateUser(acc.keyUid, proc(password: string, pin: string, success: bool) =
      self.userAuthenticationResult(topic, id, success, password, pin, payload)
    )

  proc signMessageUnsafe*(self: Controller, address: string, password: string, message: string): string {.slot.} =
    return self.service.signMessageUnsafe(address, password, message)

  proc signMessage*(self: Controller, address: string, password: string, message: string): string {.slot.} =
    return self.service.signMessage(address, password, message)

  proc safeSignTypedData*(self: Controller, address: string, password: string, typedDataJson: string, chainId: int, legacy: bool): string {.slot.} =
    return self.service.safeSignTypedData(address, password, typedDataJson, chainId, legacy)

  proc signTransaction*(self: Controller, address: string, chainId: int, password: string, txJson: string): string {.slot.} =
    return self.service.signTransaction(address, chainId, password, txJson)

  proc sendTransaction*(self: Controller, address: string, chainId: int, password: string, txJson: string): string {.slot.} =
    return self.service.sendTransaction(address, chainId, password, txJson)

  proc getEstimatedTime(self: Controller, chainId: int, maxFeePerGasHex: string): int {.slot.} =
    return self.service.getEstimatedTime(chainId, maxFeePerGasHex).int

  proc getSuggestedFeesJson(self: Controller, chainId: int): string {.slot.} =
    let dto = self.service.getSuggestedFees(chainId)
    return dto.toJson()

  proc hexToDecBigString*(self: Controller, hex: string): string {.slot.} =
    try:
      return hexToDec(hex)
    except Exception as e:
      error "Failed to convert hex big int: ", hex=hex, ex=e.msg
      return ""

  # Convert from float gwei to hex wei
  proc convertFeesInfoToHex*(self: Controller, feesInfoJson: string): string {.slot.} =
    try:
      return convertFeesInfoToHex(feesInfoJson)
    except Exception as e:
      error "Failed to convert fees info to hex: ", feesInfoJson=feesInfoJson, ex=e.msg
      return ""
