proc setup*(self: QNetworkConfigurationManager) =
  ## Setup a new QUrl
  self.vptr = dos_qncm_create()

proc delete*(self: QNetworkConfigurationManager) =
  ## Delete a QUrl
  if self.vptr.isNil:
    return
  dos_qncm_delete(self.vptr)
  self.vptr.resetToNil

proc newQNetworkConfigurationManager*(): QNetworkConfigurationManager =
  new(result, delete)
  result.setup()

