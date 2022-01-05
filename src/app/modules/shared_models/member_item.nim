import strformat

type 
  MemberItem* = ref object
    id: string
    roles*: seq[int]

proc initItem*(
  id: string,
  roles: seq[int]
  ): MemberItem =
  result = MemberItem()
  result.id = id
  result.roles = roles

proc `$`*(self: MemberItem): string =
  result = fmt"""MemberItem(
    id: {self.id},
    roles: {$self.roles}
    ]"""


proc id*(self: MemberItem): string {.inline.} = 
  self.id

proc roles*(self: MemberItem): seq[int] {.inline.} = 
  self.roles
