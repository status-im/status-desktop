import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint

import NimQml, json, sequtils, chronicles, strutils, strformat, json
import ../../../status/[status, settings, wallet, tokens]
import ../../../status/wallet/collectibles as status_collectibles
import ../../../status/signals/types as signal_types
import ../../../status/types

import # status-desktop libs
  ../../../status/wallet as status_wallet,
  ../../../status/utils as status_utils,
  ../../../status/tokens as status_tokens,
  ../../../status/ens as status_ens,
  ../../../status/tasks/[qt, task_runner_impl]

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
    slot: slot,
    ens: ens,
    uuid: uuid
  )
  self.status.tasks.threadpool.start(arg)

QtObject:
  type EnsView* = ref object of QObject
      status: Status

  proc setup(self: EnsView) =
    self.QObject.setup

  proc delete(self: EnsView) =
    echo "delete"

  proc newEnsView*(status: Status): EnsView =
    new(result, delete)
    result.status = status
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
