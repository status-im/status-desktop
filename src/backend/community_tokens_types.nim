type
  # see protocol/communities/token/community_token.go PrivilegesLevel
  PrivilegesLevel* {.pure.} = enum
    Owner, Master, Community
