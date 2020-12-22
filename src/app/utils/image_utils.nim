import strutils

proc formatImagePath*(imagePath: string): string =
  result = replace(imagePath, "file://", "")
  if defined(windows):
    # Windows doesn't work with paths starting with a slash
    result.removePrefix('/')
