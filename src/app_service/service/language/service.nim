import NimQml
import json, json_serialization, sequtils, chronicles, os, strformat
import ./service_interface
import ../../../app/global/global_singleton

export service_interface

logScope:
  topics = "language-service"

type
  Service* = ref object of ServiceInterface
    i18nPath: string
    shouldRetranslate: bool

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.shouldRetranslate = not defined(linux)

method init*(self: Service) =
  try:
    self.i18nPath = ""
    if defined(development):
      self.i18nPath = joinPath(getAppDir(), "../ui/i18n")
    elif (defined(windows)):
      self.i18nPath = joinPath(getAppDir(), "../resources/i18n")
    elif (defined(macosx)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")
    elif (defined(linux)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")

    let locale = singletonInstance.localAppSettings.getLocale()
    singletonInstance.engine.setTranslationPackage(joinPath(self.i18nPath, fmt"qml_{locale}.qm"), self.shouldRetranslate)

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method setLanguage*(self: Service, locale: string) =
  if (locale == singletonInstance.localAppSettings.getLocale()):
    return

  singletonInstance.localAppSettings.setLocale(locale)
  singletonInstance.engine.setTranslationPackage(joinPath(self.i18nPath, fmt"qml_{locale}.qm"), self.shouldRetranslate)
