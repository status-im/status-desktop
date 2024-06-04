import NimQml
import chronicles

import app_service/service/wallet_connect/service as wallet_connect_service
import app_service/service/wallet_account/service as wallet_account_service

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

  proc dappsListReceived*(self: Controller, dappsJson: string) {.signal.}

  # Emits signal dappsListReceived with the list of dApps
  proc getDapps*(self: Controller): bool {.slot.} =
    let res = self.service.getDapps()
    if res == "":
      return false
    else:
      self.dappsListReceived(res)
      return true

  proc userAuthenticationResult*(self: Controller, topic: string, id: string, error: bool) {.signal.}

  # Beware, it will fail if an authentication is already in progress
  proc authenticateUser*(self: Controller, topic: string, id: string, address: string): bool {.slot.} =
    let acc = self.walletAccountService.getAccountByAddress(address)
    if acc.keyUid == "":
      return false

    return self.service.authenticateUser(acc.keyUid, proc(success: bool) =
      self.userAuthenticationResult(topic, id, success)
    )