import json
import ../libstatus/types

type Profile* = ref object
  id*, alias*, username*, identicon*, address*, ensName*, localNickname*: string
  ensVerified*: bool
  ensVerifiedAt*, ensVerificationRetries*, appearance*: int
  systemTags*: seq[string]

proc isContact*(self: Profile): bool =
  result = self.systemTags.contains(":contact/added") and not self.systemTags.contains(":contact/blocked")

proc isBlocked*(self: Profile): bool =
  result = self.systemTags.contains(":contact/blocked")

proc toProfileModel*(account: Account): Profile =
  result = Profile(
    id: "",
    username: account.name,
    identicon: account.photoPath,
    alias: account.name,
    ensName: "",
    ensVerified: false,
    ensVerifiedAt: 0,
    appearance: 0,
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
    ensName: "",
    ensVerified: profile["ensVerified"].getBool,
    appearance: 0,
    ensVerifiedAt: profile["ensVerifiedAt"].getInt,
    ensVerificationRetries: profile["ensVerificationRetries"].getInt,
    systemTags: systemTags
  )
  
  if profile.hasKey("name"):
    result.ensName = profile["name"].str
  
  if profile.hasKey("localNickname"):
    result.localNickname = profile["localNickname"].str
