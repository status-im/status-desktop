{.used.}

import strformat

type CommandParameters* = object
  id*: string
  fromAddress*: string
  address*: string
  contract*: string
  value*: string
  transactionHash*: string
  commandState*: int
  signature*: string

proc `$`*(self: CommandParameters): string =
  result = fmt"CommandParameters(id:{self.id}, fromAddr:{self.fromAddress}, addr:{self.address}, contract:{self.contract}, value:{self.value}, transactionHash:{self.transactionHash}, commandState:{self.commandState}, signature:{self.signature})"