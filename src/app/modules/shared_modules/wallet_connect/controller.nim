import NimQml
import chronicles, times, json

import app/global/global_singleton
import app_service/common/utils
import app_service/service/wallet_connect/service as wallet_connect_service
import app_service/service/wallet_account/service as wallet_account_service

import helpers

logScope:
  topics = "wallet-connect-controller"

type
  SigningCallbackFn* = proc(topic: string, id: string, keyUid: string, address: string, signature: string)

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

  ## signals emitted by this controller
  proc userAuthenticationResult*(self: Controller, topic: string, id: string, error: bool, password: string, pin: string, payload: string) {.signal.}
  proc signingResultReceived*(self: Controller, topic: string, id: string, data: string) {.signal.}

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
    if res.len == 0:
      return false
    else:
      self.dappsListReceived(res)
      return true

  proc activeSessionsReceived(self: Controller, activeSessionsJson: string) {.signal.}

  # Emits signal activeSessionsReceived with the list of active sessions
  # TODO: make it async
  proc getActiveSessions(self: Controller): bool {.slot.} =
    let validAtTimestamp = now().toTime().toUnix()
    let res = self.service.getActiveSessions(validAtTimestamp)
    if res.isNil:
      return false
    else:
      let resultStr = $res
      self.activeSessionsReceived(resultStr)
      return true

  # Beware, it will fail if an authentication is already in progress
  proc authenticateUser*(self: Controller, topic: string, id: string, address: string, payload: string): bool {.slot.} =
    let keypair = self.walletAccountService.getKeypairByAccountAddress(address)
    if keypair.isNil:
      return false
    var keyUid = singletonInstance.userProfile.getKeyUid()
    if keypair.migratedToKeycard():
      keyUid = keypair.keyUid
    return self.service.authenticateUser(keyUid, proc(receivedKeyUid: string, password: string, pin: string) =
      if receivedKeyUid.len == 0 or receivedKeyUid != keyUid or password.len == 0:
        self.userAuthenticationResult(topic, id, false, "", "", "")
        return
      self.userAuthenticationResult(topic, id, true, password, pin, payload)
    )

  proc signOnKeycard(self: Controller, address: string): bool =
    let keypair = self.walletAccountService.getKeypairByAccountAddress(address)
    if keypair.isNil:
      raise newException(CatchableError, "cannot resolve keypair for address: " & address)
    return keypair.migratedToKeycard()

  proc preparePassword(self: Controller, password: string): string =
    if singletonInstance.userProfile.getIsKeycardUser():
      return password
    return hashPassword(password)

  proc signMessageWithCallback(self: Controller, topic: string, id: string, address: string, message: string, password: string,
    pin: string, callback: SigningCallbackFn) =
    var res = ""
    try:
      if message.len == 0:
        raise newException(CatchableError, "message is empty")
      if self.signOnKeycard(address):
        let acc = self.walletAccountService.getAccountByAddress(address)
        if acc.isNil:
          raise newException(CatchableError, "cannot resolve account for address: " & address)
        if not self.service.runSigningOnKeycard(
          acc.keyUid,
          acc.path,
          singletonInstance.utils.removeHexPrefix(message),
          pin,
          proc(keyUid: string, signature: string) =
            if keyUid.len == 0 or keyUid != acc.keyUid or signature.len == 0:
              raise newException(CatchableError, "keycard signing failed")
            callback(topic, id, keyUid, address, signature)
          ):
            raise newException(CatchableError, "runSigningOnKeycard failed")
        debug "signMessageWithCallback: signing on keycard started successfully"
        return
      let finalPassword = self.preparePassword(password)
      res = self.service.signMessage(address, finalPassword, message)
    except Exception as e:
      error "signMessageWithCallback failed: ", msg=e.msg
    callback(topic, id, "", address, res)

  proc signMessage*(self: Controller, topic: string, id: string, address: string, message: string, password: string, pin: string) {.slot.} =
    var res = ""
    try:
      if message.len == 0:
        raise newException(CatchableError, "message is empty")
      let hashedMessage = self.service.hashMessageEIP191(message)
      if hashedMessage.len == 0:
        raise newException(CatchableError, "hashMessageEIP191 failed")
      self.signMessageWithCallback(topic, id, address, hashedMessage, password, pin,
        proc (topic: string, id: string, keyUid: string, address: string, signature: string) =
          self.signingResultReceived(topic, id, signature)
      )
    except Exception as e:
      error "signMessage failed: ", msg=e.msg
      self.signingResultReceived(topic, id, res)

  proc signMessageUnsafe*(self: Controller, topic: string, id: string, address: string, message: string, password: string, pin: string) {.slot.} =
    self.signMessage(topic, id, address, message, password, pin)

  proc safeSignTypedData*(self: Controller, topic: string, id: string, address: string, typedDataJson: string, chainId: int, legacy: bool,
    password: string, pin: string): string {.slot.} =
    var res = ""
    try:
      var dataToSign = ""
      if legacy:
        dataToSign = self.service.hashTypedData(typedDataJson)
      else:
        dataToSign = self.service.hashTypedDataV4(typedDataJson)
      if dataToSign.len == 0:
        raise newException(CatchableError, "hashTypedData failed")
      self.signMessageWithCallback(topic, id, address, dataToSign, password, pin,
        proc (topic: string, id: string, keyUid: string, address: string, signature: string) =
          self.signingResultReceived(topic, id, signature)
      )
    except Exception as e:
      error "safeSignTypedData failed: ", msg=e.msg
      self.signingResultReceived(topic, id, res)

  proc signTransaction*(self: Controller, topic: string, id: string, address: string, chainId: int, txJson: string, password: string, pin: string) {.slot.} =
    var res = ""
    try:
      let (txHash, txData) = self.service.buildTransaction(chainId, txJson)
      if txHash.len == 0 or txData.isNil:
        raise newException(CatchableError, "building transaction failed")
      self.signMessageWithCallback(topic, id, address, txHash, password, pin,
        proc (topic: string, id: string, keyUid: string, address: string, signature: string) =
          let rawTx = self.service.buildRawTransaction(chainId, $txData, signature)
          self.signingResultReceived(topic, id, rawTx)
      )
    except Exception as e:
      error "signTransaction failed: ", msg=e.msg
      self.signingResultReceived(topic, id, res)

  proc sendTransaction*(self: Controller, topic: string, id: string, address: string, chainId: int, txJson: string, password: string, pin: string) {.slot.} =
    var res = ""
    try:
      let (txHash, txData) = self.service.buildTransaction(chainId, txJson)
      if txHash.len == 0 or txData.isNil:
        raise newException(CatchableError, "building transaction failed")
      self.signMessageWithCallback(topic, id, address, txHash, password, pin,
        proc (topic: string, id: string, keyUid: string, address: string, signature: string) =
          let signedTxHash = self.service.sendTransactionWithSignature(chainId, $txData, signature)
          self.signingResultReceived(topic, id, signedTxHash)
      )
    except Exception as e:
      error "sendTransaction failed: ", msg=e.msg
      self.signingResultReceived(topic, id, res)

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
