import strutils
import uri as uri

proc formatImagePath*(imagePath: string): string =
  result = uri.decodeUrl(replace(imagePath, "file://", ""))
  if defined(windows):
    # Windows doesn't work with paths starting with a slash
    result.removePrefix('/')
