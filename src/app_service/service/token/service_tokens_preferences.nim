proc fetchTokenPreferences(self: Service) =
  # this is emited so that the models can notify about token preferences being available
  defer: self.events.emit(SIGNAL_TOKEN_PREFERENCES_UPDATED, Args())
  self.tokenPreferencesJson = "[]"
  try:
    let response = backend.getTokenPreferences()
    if not response.error.isNil:
      error "status-go error", procName="fetchTokenPreferences", errCode=response.error.code, errDesription=response.error.message
      return

    if response.result.isNil or response.result.kind != JArray:
      return

    self.tokenPreferencesJson = $response.result
    for preferences in response.result:
      let dto = Json.decode($preferences, TokenPreferencesDto, allowUnknownFields = true)
      self.tokenPreferencesTable[dto.key] = TokenPreferencesItem(
        key: dto.key,
        position: dto.position,
        groupPosition: dto.groupPosition,
        visible: dto.visible,
        communityId: dto.communityId)
  except Exception as e:
    error "error: ", procName="fetchTokenPreferences", errName=e.name, errDesription=e.msg

proc getTokenPreferences*(self: Service, key: string): TokenPreferencesItem =
  if not self.tokenPreferencesTable.hasKey(key):
    return TokenPreferencesItem(
      key: key,
      position: high(int),
      groupPosition: high(int),
      visible: true,
      communityId: ""
    )
  return self.tokenPreferencesTable[key]

proc getTokenPreferencesJson*(self: Service): string =
  if len(self.tokenPreferencesJson) == 0:
    self.fetchTokenPreferences()
  return self.tokenPreferencesJson

proc updateTokenPreferences*(self: Service, tokenPreferencesJson: string) =
  try:
    let preferencesJson = parseJson(tokenPreferencesJson)
    var tokenPreferences: seq[TokenPreferencesDto]
    if preferencesJson.kind == JArray:
      for preferences in preferencesJson:
        add(tokenPreferences, Json.decode($preferences, TokenPreferencesDto, allowUnknownFields = false))
    let response = backend.updateTokenPreferences(tokenPreferences)
    if not response.error.isNil:
      raise newException(CatchableError, response.error.message)
    self.fetchTokenPreferences()
  except Exception as e:
    error "error: ", procName="updateTokenPreferences", errName=e.name, errDesription=e.msg