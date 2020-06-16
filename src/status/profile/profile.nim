
import ../libstatus/types
import json

type Profile* = ref object
  id*, alias*, username*, identicon*, address*, ensName*: string
  ensVerified*: bool
  ensVerifiedAt*: int
  ensVerificationRetries*: int
  systemTags*: seq[string]

proc toProfileModel*(account: Account): Profile =
    result = Profile(
      id: "",
      username: account.name,
      identicon: account.photoPath,
      alias: account.name,
      ensName: "",
      ensVerified: false,
      ensVerifiedAt: 0,
      ensVerificationRetries: 0,
      systemTags: @[]
    )

proc toProfileModel*(profile: JsonNode): Profile =
    var systemTags: seq[string] = @[]
    if profile["systemTags"].kind != JNull:
      systemTags = profile["systemTags"].to(seq[string])

    result = Profile(
      id: profile["id"].str,
      username: profile["alias"].str,
      identicon: profile["identicon"].str,
      address: profile["id"].str,
      alias: profile["alias"].str,
      ensName: profile["name"].str,
      ensVerified: profile["ensVerified"].getBool,
      ensVerifiedAt: profile["ensVerifiedAt"].getInt,
      ensVerificationRetries: profile["ensVerificationRetries"].getInt,
      systemTags: systemTags
    )