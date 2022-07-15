import NimQml
import json, json_serialization, sequtils, chronicles, os, strformat, re
import ../../../app/global/global_singleton

logScope:
  topics = "language-service"

type
  Service* = ref object of RootObj
    i18nPath: string
    shouldRetranslate: bool
    locales: seq[string]

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.shouldRetranslate = not defined(linux)

proc obtainLocales(dir: string): seq[string] =
  let localeRe = re".*qml_(.*).qm"
  for file in walkFiles dir & "/*.qm":
    if file =~ localeRe:
      result.add(matches[0])

proc init*(self: Service) =
  try:
    self.i18nPath = ""
    if defined(development):
      self.i18nPath = joinPath(getAppDir(), "i18n")
    elif (defined(windows)):
      self.i18nPath = joinPath(getAppDir(), "../resources/i18n")
    elif (defined(macosx)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")
    elif (defined(linux)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")

    self.locales = obtainLocales(self.i18nPath)

    let locale = singletonInstance.localAppSettings.getLocale()
    singletonInstance.engine.setTranslationPackage(joinPath(self.i18nPath, fmt"qml_{locale}.qm"), self.shouldRetranslate)

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc setLanguage*(self: Service, locale: string) =
  if (locale == singletonInstance.localAppSettings.getLocale()):
    return

  singletonInstance.localAppSettings.setLocale(locale)
  singletonInstance.engine.setTranslationPackage(joinPath(self.i18nPath, fmt"qml_{locale}.qm"), self.shouldRetranslate)

proc locales*(self: Service): seq[string] =
  self.locales
