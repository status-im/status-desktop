import strutils, os

proc formatImagePath*(imagePath: string): string =
  var image: string = replace(imagePath, "file://", "")
  if defined(windows):
    # Windows doesn't work with paths starting with a slash
    image.removePrefix('/')
  return image