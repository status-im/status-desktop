import NimQml, strutils, uri
import stew/byteutils
import stint

# Services as instances shouldn't be used in this class, just some general/global procs
import ../../app_service/service/eth/utils as procs_from_utils
import ../../app_service/service/accounts/service as procs_from_accounts


QtObject:
  type Utils* = ref object of QObject
    
  proc setup(self: Utils) =
    self.QObject.setup

  proc delete*(self: Utils) =
    self.QObject.delete

  proc newUtils*(): Utils =
    new(result, delete)
    result.setup

  proc formatImagePath*(self: Utils, imagePath: string): string =
    result = uri.decodeUrl(replace(imagePath, "file://", ""))
    if defined(windows):
      # Windows doesn't work with paths starting with a slash
      result.removePrefix('/')

  proc urlFromUserInput*(self: Utils, input: string): string {.slot.} =
    result = url_fromUserInput(input)

  proc eth2Wei*(self: Utils, eth: string, decimals: int): string {.slot.} =
    let uintValue = procs_from_utils.eth2Wei(parseFloat(eth), decimals)
    return uintValue.toString()

  proc wei2Eth*(self: Utils, wei: string, decimals: int): string {.slot.} =
    var weiValue = wei
    if(weiValue.startsWith("0x")):
      weiValue = fromHex(Stuint[256], weiValue).toString()
    return procs_from_utils.wei2Eth(weiValue, decimals)

  proc hex2Ascii*(self: Utils, value: string): string {.slot.} =
    result = string.fromBytes(hexToSeqByte(value))

  proc ascii2Hex*(self: Utils, value: string): string {.slot.} = 
    result = "0x" & toHex(value)

  proc stripTrailingZeroes(value: string): string =
    var str = value.strip(leading = false, chars = {'0'})
    if str[str.len - 1] == '.':
      add(str, "0")
    return str

  proc hex2Eth*(self: Utils, value: string): string {.slot.} =
    return stripTrailingZeroes(procs_from_utils.wei2Eth(stint.fromHex(StUint[256], value)))

  proc hex2Dec*(self: Utils, value: string): string {.slot.} =
    # somehow this value crashes the app
    if value == "0x0":
      return "0"
    return $stint.fromHex(StUint[256], value)

  proc generateAlias*(self: Utils, pk: string): string {.slot.} =
    return procs_from_accounts.generateAliasFromPk(pk)

  proc generateIdenticon*(self: Utils, pk: string): string {.slot.} =
    return procs_from_accounts.generateIdenticonFromPk(pk)

  proc getFileSize*(self: Utils, filename: string): string {.slot.} =
    var f: File = nil
    if f.open(self.formatImagePath(filename)):
      try:
        result = $(f.getFileSize())
      finally:
        close(f)
    else:
      raise newException(IOError, "cannot open: " & filename)

  proc readTextFile*(self: Utils, filepath: string): string {.slot.} =
    try:
      return readFile(filepath)
    except:
      return ""

  proc writeTextFile*(self: Utils, filepath: string, text: string): bool {.slot.} =
    try:
      writeFile(filepath, text)
      return true
    except:
      return false