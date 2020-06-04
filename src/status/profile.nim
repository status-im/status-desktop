import json
import eventemitter
import libstatus/types
import libstatus/core as libstatus_core
import libstatus/accounts as status_accounts

type
  MailServer* = ref object
    name*, endpoint*: string

type
  Contact* = ref object
    name*, address*: string

type Profile* = ref object
  id*, alias*, username*, identicon*: string
  ensVerified*: bool
  ensVerifiedAt*: int
  ensVerificationEntries*: int

proc toProfileModel*(account: Account): Profile =
    result = Profile(
      id: "",
      username: account.name,
      identicon: account.photoPath,
      alias: account.name,
      ensVerified: false,
      ensVerifiedAt: 0,
      ensVerificationEntries: 0,
    )

proc toProfileModel*(profile: JsonNode): Profile =
    result = Profile(
      id: profile["id"].str,
      username: profile["alias"].str,
      identicon: profile["identicon"].str,
      alias: profile["alias"].str,
      ensVerified: profile["ensVerified"].getBool,
      ensVerifiedAt: profile["ensVerifiedAt"].getInt,
      ensVerificationEntries: profile["ensVerificationEntries"].getInt
    )


proc getContactByID*(id: string): Profile =
  let response = libstatus_core.getContactByID(id)
  let val = parseJSON($response)
  result = toProfileModel(val)

type
  ProfileModel* = ref object

proc newProfileModel*(): ProfileModel =
  result = ProfileModel()

proc logout*(self: ProfileModel) =
  discard status_accounts.logout()


