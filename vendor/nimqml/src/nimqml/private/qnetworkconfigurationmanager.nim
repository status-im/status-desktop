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


proc setup*(self: QNetworkAccessManagerFactory, tmpPath: string) =
  self.vptr = dos_qqmlnetworkaccessmanagerfactory_create(tmpPath.cstring)

proc delete*(self: QNetworkAccessManagerFactory) =
  if self.vptr.isNil:
    return
  self.vptr.resetToNil

proc newQNetworkAccessManagerFactory*(tmpPath: string): QNetworkAccessManagerFactory =
  new(result, delete)
  result.setup(tmpPath)

