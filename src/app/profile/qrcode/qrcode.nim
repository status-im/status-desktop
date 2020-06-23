import strformat
import strutils
import qrcodegen

proc generateQRCodeSVG*(text: string, border: int = 0): string =
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

        
