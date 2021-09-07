import atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, strformat, json

import
  ../../../../status/[status, settings, wallet, tokens],
  ../../../../status/ens as status_ens
import ../../../../app_service/[main]
import ../../../../app_service/tasks/[qt, threadpool]

import account_list, account_item, transaction_list, accounts, asset_list, token_list

logScope:
  topics = "ens-view"

type
  ResolveEnsTaskArg = ref object of QObjectTaskArg
    ens: string
    uuid: string

const resolveEnsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[ResolveEnsTaskArg](argEncoded)
    output = %* { "address": status_ens.address(arg.ens), "uuid": arg.uuid }
  arg.finish(output)

proc resolveEns[T](self: T, slot: string, ens: string, uuid: string) =
  let arg = ResolveEnsTaskArg(
    tptr: cast[ByteAddress](resolveEnsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot, ens: ens, uuid: uuid
  )
  self.appService.threadpool.start(arg)

QtObject:
  type EnsView* = ref object of QObject
      status: Status
      appService: AppService

  proc setup(self: EnsView) = self.QObject.setup
  proc delete(self: EnsView) = self.QObject.delete

  proc newEnsView*(status: Status, appService: AppService): EnsView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.setup

  proc resolveENS*(self: EnsView, ens: string, uuid: string) {.slot.} =
    self.resolveEns("ensResolved", ens, uuid)

  proc ensWasResolved*(self: EnsView, resolvedAddress: string, uuid: string) {.signal.}

  proc ensResolved(self: EnsView, addressUuidJson: string) {.slot.} =
    var
      parsed = addressUuidJson.parseJson
      address = parsed["address"].to(string)
      uuid = parsed["uuid"].to(string)
    if address == "0x":
      address = ""
    self.ensWasResolved(address, uuid)
