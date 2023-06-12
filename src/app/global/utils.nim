import NimQml, strutils, uri, strformat, strutils, stint, re
import stew/byteutils
import ./utils/qrcodegen

# Services as instances shouldn't be used in this class, just some general/global procs
import ../../app_service/common/conversion
import ../../app_service/service/visual_identity/service as procs_from_visual_identity_service

include ../../app_service/service/accounts/utils

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
    result = uri.decodeUrl(replace(imagePath, "file://", ""), decodePlus=false)
    if defined(windows):
      # Windows doesn't work with paths starting with a slash
      result.removePrefix('/')

  proc isAlias*(self: Utils, value: string): bool {.slot.} =
    result = isAlias(value)

  proc urlFromUserInput*(self: Utils, input: string): string {.slot.} =
    result = url_fromUserInput(input)

  proc eth2Wei*(self: Utils, eth: string, decimals: int): string {.slot.} =
    let uintValue = conversion.eth2Wei(parseFloat(eth), decimals)
    return uintValue.toString()

  proc eth2Hex*(self: Utils, eth: float): string {.slot.} =
    return "0x" & conversion.eth2Wei(eth, 18).toHex()

  proc wei2Eth*(self: Utils, wei: string, decimals: int): string {.slot.} =
    var weiValue = wei
    if(weiValue.startsWith("0x")):
      weiValue = fromHex(Stuint[256], weiValue).toString()
    return conversion.wei2Eth(weiValue, decimals)

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
    return stripTrailingZeroes(conversion.wei2Eth(stint.fromHex(StUint[256], value)))

  proc hex2Gwei*(self: Utils, value: string): string {.slot.} =
    return stripTrailingZeroes(conversion.wei2Eth(stint.fromHex(StUint[256], value)*1000000000))

  proc gwei2Hex*(self: Utils, gwei: float): string {.slot.} =
    return "0x" & conversion.gwei2Wei(gwei).toHex()

  proc hex2Dec*(self: Utils, value: string): string {.slot.} =
    # somehow this value crashes the app
    if value.find(re("0x0+$")) >= 0:
      return "0"
    return $stint.fromHex(StUint[256], value)

  proc generateAlias*(self: Utils, pk: string): string {.slot.} =
    return generateAliasFromPk(pk)

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

  proc copyToClipboard*(self: Utils, content: string) {.slot.} =
    setClipBoardText(content)

  proc getFromClipboard*(self: Utils): string {.slot.} =
    return getClipBoardText()

  proc copyImageToClipboard*(self: Utils, content: string) {.slot.} =
    setClipBoardImage(content)

  proc copyImageToClipboardByUrl*(self: Utils, url: string) {.slot.} =
    setClipBoardImageByUrl(url)

  proc downloadImage*(self: Utils, content: string, path: string) {.slot.} =
    downloadImage(content, path)

  proc downloadImageByUrl*(self: Utils, url: string, path: string) {.slot.} =
    downloadImageByUrl(url, path)

  proc generateQRCodeSVG*(self: Utils, text: string, border: int = 0): string =
    var qr0: array[0..qrcodegen_BUFFER_LEN_MAX, uint8]
    var tempBuffer: array[0..qrcodegen_BUFFER_LEN_MAX, uint8]
    let ok: bool = qrcodegen_encodeText(text, tempBuffer[0].addr, qr0[0].addr, qrcodegen_Ecc_MEDIUM, qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX, qrcodegen_Mask_AUTO, true);
    if not ok:
      raise newException(Exception, "Error generating QR Code")
    else:
      var parts: seq[string] = @[]
      let size = qrcodegen_getSize(qr0[0].addr);
      for y in countup(0, size):
        for x in countup(0, size):
          if qrcodegen_getModule(qr0[0].addr, x.cint, y.cint):
            parts.add(&"M{x + border},{y + border}h1v1h-1z")
      let partsStr = parts.join(" ")
      result = &"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\"><svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" viewBox=\"0 0 {size + border * 2} {size + border * 2}\" stroke=\"none\"><rect width=\"100%\" height=\"100%\" fill=\"#FFFFFF\"/><path d=\"{partsStr}\" fill=\"#000000\"/></svg>"

  proc qrCode*(self: Utils, text:string): string {.slot.} =
    result = "data:image/svg+xml;utf8," & self.generateQRCodeSVG(text, 2)

  proc plainText*(self: Utils, text: string): string {.slot.} =
    result = plain_text(text)

  proc escapeHtml*(self: Utils, text: string): string {.slot.} =
    result = escape_html(text)

  proc getEmojiHashAsJson*(self: Utils, publicKey: string): string {.slot.} =
    procs_from_visual_identity_service.getEmojiHashAsJson(publicKey)

  proc getColorHashAsJson*(self: Utils, publicKey: string): string {.slot.} =
    procs_from_visual_identity_service.getColorHashAsJson(publicKey)

  proc getColorId*(self: Utils, publicKey: string): int {.slot.} =
    int(procs_from_visual_identity_service.colorIdOf(publicKey))

  proc getCompressedPk*(self: Utils, publicKey: string): string {.slot.} =
    compressPk(publicKey)

  proc getDecompressedPk*(self: Utils, compressedKey: string): string {.slot.} =
    decompressPk(compressedKey)

  proc decompressCommunityKey*(self: Utils, publicKey: string): string {.slot.} =
    decompressCommunityKey(publicKey)

  proc compressCommunityKey*(self: Utils, publicKey: string): string {.slot.} =
    compressCommunityKey(publicKey)

  proc isCompressedPubKey*(self: Utils, publicKey: string): bool {.slot.} =
    conversion.isCompressedPubKey(publicKey)

  # Changes publicKey compression between 33-bytes and multiformat zQ..
  proc changeCommunityKeyCompression*(self: Utils, publicKey: string): string {.slot.} =
    changeCommunityKeyCompression(publicKey)
