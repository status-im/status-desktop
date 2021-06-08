import json, json_serialization

import 
  sugar, sequtils, strutils, atomics

import libstatus/settings as status_settings
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
    result = status_settings.saveSetting(key, value)

proc getSetting*[T](self: SettingsModel, name: Setting, defaultValue: T, useCached: bool = true): T =
  result = status_settings.getSetting(name, defaultValue, useCached)

proc getSetting*[T](self: SettingsModel, name: Setting, useCached: bool = true): T =
  result = status_settings.getSetting[T](name, useCached)

proc getCurrentNetworkDetails*(self: SettingsModel): LibStatusTypes.NetworkDetails =
  result = status_settings.getCurrentNetworkDetails()

proc getMailservers*(self: SettingsModel):JsonNode =
  result = status_settings.getMailservers()

proc getPinnedMailserver*(self: SettingsModel): string =
  result = status_settings.getPinnedMailserver()

proc pinMailserver*(self: SettingsModel, enode: string = "") =
  status_settings.pinMailserver(enode)

proc saveMailserver*(self: SettingsModel, name, enode: string) =
  status_settings.saveMailserver(name, enode)

proc getFleet*(self: SettingsModel): Fleet =
    result = status_settings.getFleet()

proc getCurrentNetwork*(self: SettingsModel): Network =
    result = status_settings.getCurrentNetwork()
