import NimQml
import json_serialization, chronicles, os, strformat, re

import ../../../constants as main_constants
import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import ../../../app/core/signals/types

logScope:
  topics = "language-service"

const SIGNAL_LANGUAGE_UPDATE* = "languageUpdated"

type
  LanguageUpdatedArgs* = ref object of Args
    language*: string

type
  Service* = ref object of RootObj
    events: EventEmitter
    i18nPath: string
    shouldRetranslate: bool
    languages: seq[string] # list of locale names for translation purposes

proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter): Service =
  result = Service()
  result.events = events
  result.shouldRetranslate = false #not defined(linux)

proc obtainLanguages(dir: string): seq[string] =
  let localeRe = re".*qml_(.*).qm"
  for file in walkFiles dir & "/*.qm":
    if file =~ localeRe:
      result.add(matches[0])

proc currentLanguage*(): string =
  singletonInstance.localAppSettings.getLanguage()

proc languages*(self: Service): seq[string] =
  self.languages

proc init*(self: Service) =
  try:
    self.i18nPath = ""
    if defined(development):
      self.i18nPath = joinPath(getAppDir(), "i18n")
    elif (defined(windows)):
      self.i18nPath = joinPath(getAppDir(), "../resources/i18n")
    elif (main_constants.IS_MACOS):
      self.i18nPath = joinPath(getAppDir(), "../i18n")
    elif (defined(linux)):
      self.i18nPath = joinPath(getAppDir(), "../i18n")

    self.languages = obtainLanguages(self.i18nPath)

    let language = currentLanguage()
    singletonInstance.engine.setTranslationPackage(joinPath(self.i18nPath, fmt"qml_{language}.qm"), self.shouldRetranslate)

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc setLanguage*(self: Service, language: string) =
  if (language == singletonInstance.localAppSettings.getLanguage()):
    return

  singletonInstance.localAppSettings.setLanguage(language)
  singletonInstance.engine.setTranslationPackage(joinPath(self.i18nPath, fmt"qml_{language}.qm"), self.shouldRetranslate)

  self.events.emit(SIGNAL_LANGUAGE_UPDATE, LanguageUpdatedArgs(language: language))
