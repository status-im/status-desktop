import os, parseutils
import ../ens/utils as ens_utils

include ../../common/json_utils
from ../../common/conversion import isCompressedPubKey
include ../../../app/core/tasks/common

import ../../../backend/contacts as status_go

#################################################
# Async lookup ENS contact
#################################################

type LookupContactTaskArg = ref object of QObjectTaskArg
  value: string
  uuid: string
  chainId: int
  reason: string

proc lookupContactTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LookupContactTaskArg](argEncoded)
  var output = %*{"id": "", "address": "", "uuid": arg.uuid, "reason": arg.reason}
  try:
    var pubkey = arg.value
    var address = ""

    if (pubkey.startsWith("0x") or isCompressedPubKey(pubkey)):
      if pubkey.startsWith("0x"):
        var num64: int64
        let parsedChars = parseHex(pubkey, num64)
        if (parsedChars != PK_LENGTH_0X_INCLUDED):
          pubkey = ""
          address = ""
    else:
      # TODO refactor those calls to use the new backend and also do it in a signle call
      pubkey = ens_utils.publicKeyOf(arg.chainId, arg.value)
      address = ens_utils.addressOf(arg.chainid, arg.value)

    output =
      %*{"id": pubkey, "address": address, "uuid": arg.uuid, "reason": arg.reason}
    arg.finish(output)
  except Exception as e:
    error "error lookupContactTask: ", message = e.msg
    arg.finish(output)

type AsyncFetchContactsTaskArg = ref object of QObjectTaskArg
  pubkey: string

proc asyncFetchContactsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchContactsTaskArg](argEncoded)
  try:
    let response = status_contacts.getContacts()
    arg.finish(%*{"response": response, "error": ""})
  except Exception as e:
    arg.finish(%*{"error": e.msg})

type AsyncRequestContactInfoTaskArg = ref object of QObjectTaskArg
  pubkey: string

proc asyncRequestContactInfoTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestContactInfoTaskArg](argEncoded)
  try:
    let response = status_go.requestContactInfo(arg.pubkey)
    arg.finish(%*{"publicKey": arg.pubkey, "response": response, "error": ""})
  except Exception as e:
    arg.finish(%*{"publicKey": arg.pubkey, "error": e.msg})

type AsyncGetProfileShowcaseForContactTaskArg = ref object of QObjectTaskArg
  pubkey: string
  validate: bool

proc asyncGetProfileShowcaseForContactTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetProfileShowcaseForContactTaskArg](argEncoded)
  try:
    let response = status_go.getProfileShowcaseForContact(arg.pubkey, arg.validate)
    arg.finish(
      %*{
        "publicKey": arg.pubkey,
        "validated": arg.validate,
        "response": response,
        "error": "",
      }
    )
  except Exception as e:
    arg.finish(%*{"publicKey": arg.pubkey, "validated": arg.validate, "error": e.msg})

type FetchProfileShowcaseAccountsTaskArg = ref object of QObjectTaskArg
  address: string

proc fetchProfileShowcaseAccountsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchProfileShowcaseAccountsTaskArg](argEncoded)
  var response = %*{"response": "", "error": ""}
  try:
    let rpcResponse = status_accounts.getProfileShowcaseAccountsByAddress(arg.address)
    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)
    response["response"] = rpcResponse.result
  except Exception as e:
    response["error"] = %*e.msg
  arg.finish(response)
