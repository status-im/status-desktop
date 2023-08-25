  proc addKeycardOrAccountsAsync*(self: Service, keycard: KeycardDto, accountsComingFromKeycard: bool = false) =
    let arg = SaveOrUpdateKeycardTaskArg(
      tptr: cast[ByteAddress](saveOrUpdateKeycardTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onKeycardAdded",
      keycard: keycard,
      accountsComingFromKeycard: accountsComingFromKeycard
    )
    self.threadpool.start(arg)

proc updateLocalKeypairOnKeycardChange(self: Service, keyUid: string) =
  var kp: KeypairDto
  if keyUid.len > 0:
    kp = getKeypairByKeyUidFromDb(keyUid)
  if kp.isNil:
    return
  self.replaceKeypair(kp)

proc emitAddKeycardAddAccountsChange(self: Service, success: bool, keycard: KeycardDto) =
  self.updateLocalKeypairOnKeycardChange(keycard.keyUid)
  let data = KeycardArgs(
    success: success,
    keycard: keycard
  )
  self.events.emit(SIGNAL_NEW_KEYCARD_SET, data)

proc onKeycardAdded*(self: Service, response: string) {.slot.} =
  var keycard = KeycardDto()
  var success = false
  try:
    let responseObj = response.parseJson
    discard responseObj.getProp("success", success)
    var kpJson: JsonNode
    if responseObj.getProp("keycard", kpJson):
      keycard = kpJson.toKeycardDto()
  except Exception as e:
    error "error handilng migrated keycard response", errDesription=e.msg
  self.emitAddKeycardAddAccountsChange(success, keycard)

proc addKeycardOrAccounts*(self: Service, keycard: KeycardDto, accountsComingFromKeycard: bool = false): bool =
  var success = false
  try:
    let response = backend.saveOrUpdateKeycard(
      %* {
        "keycard-uid": keycard.keycardUid,
        "keycard-name": keycard.keycardName,
        # "keycard-locked" - no need to set it here, cause it will be set to false by the status-go
        "key-uid": keycard.keyUid,
        "accounts-addresses": keycard.accountsAddresses,
        # "position": - no need to set it here, cause it is fully maintained by the status-go
      },
      accountsComingFromKeycard
      )
    success = responseHasNoErrors("addKeycardOrAccounts", response)
  except Exception as e:
    error "error: ", procName="addKeycardOrAccounts", errName = e.name, errDesription = e.msg
  self.emitAddKeycardAddAccountsChange(success = success, keycard)
  return success

proc removeMigratedAccountsForKeycard*(self: Service, keyUid: string, keycardUid: string, accountsToRemove: seq[string]) =
  let arg = DeleteKeycardAccountsTaskArg(
    tptr: cast[ByteAddress](deleteKeycardAccountsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: "onMigratedAccountsForKeycardRemoved",
    keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid, accountsAddresses: accountsToRemove)
  )
  self.threadpool.start(arg)

proc onMigratedAccountsForKeycardRemoved*(self: Service, response: string) {.slot.} =
  var data = KeycardArgs(
    success: false,
  )
  try:
    let responseObj = response.parseJson
    discard responseObj.getProp("success", data.success)
    var kpJson: JsonNode
    if responseObj.getProp("keycard", kpJson):
      data.keycard = kpJson.toKeycardDto()
  except Exception as e:
    error "error handilng migrated keycard response", errDesription=e.msg
  self.updateLocalKeypairOnKeycardChange(data.keycard.keyUid)
  self.events.emit(SIGNAL_KEYCARD_ACCOUNTS_REMOVED, data)

proc getAllKnownKeycards*(self: Service): seq[KeycardDto] =
  try:
    let response = backend.getAllKnownKeycards()
    if responseHasNoErrors("getAllKnownKeycards", response):
      return map(response.result.getElems(), proc(x: JsonNode): KeycardDto = toKeycardDto(x))
  except Exception as e:
    error "error: ", procName="getAllKnownKeycards", errName = e.name, errDesription = e.msg

proc getKeycardByKeycardUid*(self: Service, keycardUid: string): KeycardDto =
  try:
    let response = backend.getKeycardByKeycardUID(keycardUid)
    if responseHasNoErrors("getKeycardByKeycardUid", response):
      return response.result.toKeycardDto()
  except Exception as e:
    error "error: ", procName="getKeycardByKeycardUid", errName = e.name, errDesription = e.msg

proc getKeycardsWithSameKeyUid*(self: Service, keyUid: string): seq[KeycardDto] =
  try:
    let response = backend.getKeycardsWithSameKeyUID(keyUid)
    if responseHasNoErrors("getKeycardsWithSameKeyUid", response):
      return map(response.result.getElems(), proc(x: JsonNode): KeycardDto = toKeycardDto(x))
  except Exception as e:
    error "error: ", procName="getKeycardsWithSameKeyUid", errName = e.name, errDesription = e.msg

proc isKeycardAccount*(self: Service, account: WalletAccountDto): bool =
  if account.isNil or
    account.keyUid.len == 0 or
    account.path.len == 0 or
    utils.isPathOutOfTheDefaultStatusDerivationTree(account.path):
      return false
  let keycards = self.getKeycardsWithSameKeyUid(account.keyUid)
  return keycards.len > 0

proc updateKeycardName*(self: Service, keycardUid: string, name: string): bool =
  let kc = self.getKeycardByKeycardUid(keycardUid)
  let kp = self.getKeypairByKeyUid(kc.keyUid)
  if kp.isNil:
    error "there is no known keypair", keyUid=kc.keyUid, procName="updateKeycardName"
    return
  var data = KeycardArgs(
    success: false,
    keycard: KeycardDto(keycardUid: keycardUid, keycardName: name)
  )
  try:
    let response = backend.setKeycardName(keycardUid, name)
    data.success = responseHasNoErrors("updateKeycardName", response)
    for kc in kp.keycards.mitems:
      if kc.keycardUid == keycardUid:
        kc.keycardName = name
        break
  except Exception as e:
    error "error: ", procName="updateKeycardName", errName = e.name, errDesription = e.msg
  self.events.emit(SIGNAL_KEYCARD_NAME_CHANGED, data)
  return data.success

proc setKeycardLocked*(self: Service, keyUid: string, keycardUid: string): bool =
  let kp = self.getKeypairByKeyUid(keyUid)
  if kp.isNil:
    error "there is no known keypair", keyUid=keyUid, procName="setKeycardLocked"
    return
  var data = KeycardArgs(
    success: false,
    keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid)
  )
  try:
    let response = backend.keycardLocked(keycardUid)
    data.success = responseHasNoErrors("setKeycardLocked", response)
    for kc in kp.keycards.mitems:
      if kc.keycardUid == keycardUid:
        kc.keycardLocked = true
        break
  except Exception as e:
    error "error: ", procName="setKeycardLocked", errName = e.name, errDesription = e.msg
  self.events.emit(SIGNAL_KEYCARD_LOCKED, data)
  return data.success

proc setKeycardUnlocked*(self: Service, keyUid: string, keycardUid: string): bool =
  let kp = self.getKeypairByKeyUid(keyUid)
  if kp.isNil:
    error "there is no known keypair", keyUid=keyUid, procName="setKeycardUnlocked"
    return
  var data = KeycardArgs(
    success: false,
    keycard: KeycardDto(keyUid: keyUid, keycardUid: keycardUid)
  )
  try:
    let response = backend.keycardUnlocked(keycardUid)
    data.success = responseHasNoErrors("setKeycardUnlocked", response)
    for kc in kp.keycards.mitems:
      if kc.keycardUid == keycardUid:
        kc.keycardLocked = false
        break
  except Exception as e:
    error "error: ", procName="setKeycardUnlocked", errName = e.name, errDesription = e.msg
  self.events.emit(SIGNAL_KEYCARD_UNLOCKED, data)
  return data.success

proc updateKeycardUid*(self: Service, oldKeycardUid: string, newKeycardUid: string): bool =
  let kc = self.getKeycardByKeycardUid(oldKeycardUid)
  let kp = self.getKeypairByKeyUid(kc.keyUid)
  if kp.isNil:
    error "there is no known keypair", keyUid=kc.keyUid, procName="updateKeycardUid"
    return
  var data = KeycardArgs(
    success: false,
    oldKeycardUid: oldKeycardUid,
    keycard: KeycardDto(keycardUid: newKeycardUid)
  )
  try:
    let response = backend.updateKeycardUID(oldKeycardUid, newKeycardUid)
    data.success = responseHasNoErrors("updateKeycardUid", response)
    for kc in kp.keycards.mitems:
      if kc.keycardUid == oldKeycardUid:
        kc.keycardUid = newKeycardUid
        break
  except Exception as e:
    error "error: ", procName="updateKeycardUid", errName = e.name, errDesription = e.msg
  self.events.emit(SIGNAL_KEYCARD_UID_UPDATED, data)
  return data.success

proc deleteKeycard*(self: Service, keycardUid: string): bool =
  var data = KeycardArgs(
    success: false,
    keycard: KeycardDto(keycardUid: keycardUid)
  )
  try:
    let response = backend.deleteKeycard(keycardUid)
    data.success = responseHasNoErrors("deleteKeycard", response)
    let kc = self.getKeycardByKeycardUid(keycardUid)
    self.updateLocalKeypairOnKeycardChange(kc.keyUid)
  except Exception as e:
    error "error: ", procName="deleteKeycard", errName = e.name, errDesription = e.msg
  self.events.emit(SIGNAL_KEYCARD_DELETED, data)
  return data.success

proc deleteAllKeycardsWithKeyUid*(self: Service, keyUid: string): bool =
  let kp = self.getKeypairByKeyUid(keyUid)
  if kp.isNil:
    error "there is no known keypair", keyUid=keyUid, procName="deleteAllKeycardsWithKeyUid"
    return
  var data = KeycardArgs(
    success: false,
    keycard: KeycardDto(keyUid: keyUid)
  )
  try:
    let response = backend.deleteAllKeycardsWithKeyUID(keyUid)
    data.success = responseHasNoErrors("deleteAllKeycardsWithKeyUid", response)
    kp.keycards = @[]
  except Exception as e:
    error "error: ", procName="deleteAllKeycardsWithKeyUid", errName = e.name, errDesription = e.msg
  self.events.emit(SIGNAL_ALL_KEYCARDS_DELETED, data)
  return data.success