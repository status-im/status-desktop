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

proc setup*(self: QNetworkAccessManager, vptr: DosQQNetworkAccessManager) =
  self.vptr = DosQObject(vptr)

proc delete*(self: QNetworkAccessManager) =
  if self.vptr.isNil:
    return
  self.vptr.resetToNil

proc newQNetworkAccessManager*(vptr: DosQQNetworkAccessManager): QNetworkAccessManager =
  new(result, delete)
  result.setup(vptr)

proc clearConnectionCache*(self: QNetworkAccessManager) =
  dos_qqmlnetworkaccessmanager_clearconnectioncache(DosQQNetworkAccessManager(self.vptr))

proc setNetworkAccessible*(self: QNetworkAccessManager, accessibility: NetworkAccessibility) =
  dos_qqmlnetworkaccessmanager_setnetworkaccessible(DosQQNetworkAccessManager(self.vptr), accessibility.cint)

