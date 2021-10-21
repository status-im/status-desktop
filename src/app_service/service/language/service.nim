import NimQml
import json, json_serialization, sequtils, chronicles, os, strformat
import ./service_interface, ./dto
import ../../../app/core/global_singleton

export service_interface

logScope:
  topics = "language-service"

type 
  Service* = ref object of ServiceInterface
    i18nPath*: string
    currentLanguageCode*: string

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    echo "init"

    self.i18nPath = ""
    if defined(development):
      self.i18nPath = joinPath(getAppDir(), "../ui/i18n")
    elif (defined(windows)):
      self.i18nPath = joinPath(getAppDir(), "../resources/i18n")
    elif (defined(macosx)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")
    elif (defined(linux)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method setLanguage*(self: Service, locale: string) =
  echo "---------------"
  echo "--- setting language"
  if (locale == self.currentLanguageCode):
    return
  self.currentLanguageCode = locale
  let shouldRetranslate = not defined(linux)
  singletonInstance.engine.setTranslationPackage(
    joinPath(self.i18nPath, fmt"qml_{locale}.qm"), shouldRetranslate)
