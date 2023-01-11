{.used.}

import json, strformat, hashes
include ../../../common/json_utils

type EnsUsernameDto* = ref object
  chainId*: int
  username*: string

proc `==`*(l, r: EnsUsernameDto): bool =
    return l.chainId == r.chainid and l.username == r.username

proc `$`*(self: EnsUsernameDto): string =
  result = fmt"""ContactDto(
    chainId: {self.chainId},
    username: {self.username}
    )"""

proc hash*(dto: EnsUsernameDto): Hash =
    return ($dto).hash

proc toEnsUsernameDto*(jsonObj: JsonNode): EnsUsernameDto =
  result = EnsUsernameDto()
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("username", result.username)