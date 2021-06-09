import json, json_serialization

import 
  sugar, sequtils, strutils, atomics

import libstatus/settings as libstatus_settings
import ../eventemitter
import signals/types

#TODO: temporary?
import types as LibStatusTypes

type
    SettingsModel* = ref object
        events*: EventEmitter

proc newSettingsModel*(events: EventEmitter): SettingsModel =
  result = SettingsModel()
  result.events = events

proc saveSetting*(self: SettingsModel, key: Setting, value: string | JsonNode | bool): StatusGoError =
    result = libstatus_settings.saveSetting(key, value)

proc getSetting*[T](self: SettingsModel, name: Setting, defaultValue: T, useCached: bool = true): T =
  result = libstatus_settings.getSetting(name, defaultValue, useCached)

proc getSetting*[T](self: SettingsModel, name: Setting, useCached: bool = true): T =
  result = libstatus_settings.getSetting[T](name, useCached)

# TODO: name with a 2 due to namespace conflicts that need to be addressed in subsquent PRs
proc getSetting2*[T](name: Setting, defaultValue: T, useCached: bool = true): T =
  result = libstatus_settings.getSetting(name, defaultValue, useCached)

proc getSetting2*[T](name: Setting, useCached: bool = true): T =
  result = libstatus_settings.getSetting[T](name, useCached)

proc getCurrentNetworkDetails*(self: SettingsModel): LibStatusTypes.NetworkDetails =
  result = libstatus_settings.getCurrentNetworkDetails()

proc getMailservers*(self: SettingsModel):JsonNode =
  result = libstatus_settings.getMailservers()

proc getPinnedMailserver*(self: SettingsModel): string =
  result = libstatus_settings.getPinnedMailserver()

proc pinMailserver*(self: SettingsModel, enode: string = "") =
  libstatus_settings.pinMailserver(enode)

proc saveMailserver*(self: SettingsModel, name, enode: string) =
  libstatus_settings.saveMailserver(name, enode)

proc getFleet*(self: SettingsModel): Fleet =
    result = libstatus_settings.getFleet()

proc getCurrentNetwork*(): Network =
    result = libstatus_settings.getCurrentNetwork()

proc getCurrentNetwork*(self: SettingsModel): Network =
    result = getCurrentNetwork()
