import json, json_serialization

import 
  sugar, sequtils, strutils, atomics

import libstatus/settings as status_settings
import ../eventemitter

#TODO: temporary?
import libstatus/types as LibStatusTypes

type
    SettingsModel* = ref object
        events*: EventEmitter

proc newSettingsModel*(events: EventEmitter): SettingsModel =
  result = SettingsModel()
  result.events = events

proc getSetting*[T](self: SettingsModel, name: Setting, defaultValue: T, useCached: bool = true): T =
  result = status_settings.getSetting(name, defaultValue, useCached)

proc getSetting*[T](self: SettingsModel, name: Setting, useCached: bool = true): T =
  result = status_settings.getSetting[T](name, useCached)

proc getCurrentNetworkDetails*(self: SettingsModel): LibStatusTypes.NetworkDetails =
  result = status_settings.getCurrentNetworkDetails()
