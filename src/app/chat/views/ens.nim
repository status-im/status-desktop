import NimQml, json, sequtils, chronicles, strutils

import status/[status, contacts]
import status/ens as status_ens
import ../../core/[main]
import ../../core/tasks/[qt, threadpool]
import ../../core/tasks/marathon/mailserver/worker

logScope:
  topics = "ens-view"

type
  ResolveEnsTaskArg = ref object of QObjectTaskArg
    ens: string
    uuid: string

const resolveEnsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[ResolveEnsTaskArg](argEncoded)
    output = %* {
      "address": status_ens.address(arg.ens),
      "pubkey": status_ens.pubkey(arg.ens),
      "uuid": arg.uuid
    }
  arg.finish(output)

proc resolveEns[T](self: T, slot: string, ens: string, uuid: string) =
  let arg = ResolveEnsTaskArg(
    tptr: cast[ByteAddress](resolveEnsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot, ens: ens, uuid: uuid
  )
  self.statusFoundation.threadpool.start(arg)

QtObject:
  type EnsView* = ref object of QObject
    status: Status
    statusFoundation: StatusFoundation

  proc setup(self: EnsView) = self.QObject.setup
  proc delete*(self: EnsView) = self.QObject.delete

  proc newEnsView*(status: Status, statusFoundation: StatusFoundation): EnsView =
    new(result, delete)
    result.status = status
    result.statusFoundation = statusFoundation
    result.setup

  proc isEnsVerified*(self: EnsView, id: string): bool {.slot.} =
    if id == "": return false
    let contact = self.status.contacts.getContactByID(id)
    if contact == nil:
      return false
    result = contact.ensVerified

  proc formatENSUsername*(self: EnsView, username: string): string {.slot.} =
    result = status_ens.addDomain(username)

  proc resolveENSWithUUID*(self: EnsView, ens: string, uuid: string) {.slot.} =
    self.resolveEns("ensResolved", ens, uuid)

  proc resolveENS*(self: EnsView, ens: string) {.slot.} =
    self.resolveEns("ensResolved", ens, "")

  proc ensWasResolved*(self: EnsView, resolvedPubKey: string, resolvedAddress: string, uuid: string) {.signal.}

  proc ensResolved(self: EnsView, addressPubkeyJson: string) {.slot.} =
    var
      parsed = addressPubkeyJson.parseJson
      address = parsed["address"].to(string)
      pubkey = parsed["pubkey"].to(string)
      uuid = parsed["uuid"].to(string)

    if address == "0x":
      address = ""

    self.ensWasResolved(pubKey, address, uuid)
