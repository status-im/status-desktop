import json

#[ Represent a part of an image
    image: path to the image
    x, y, width, height: crop rectangle in image coordinates
]#
type CroppedImage* = ref object
  imagePath*: string
  x*: int
  y*: int
  width*: int
  height*: int

proc newCroppedImage*(jsonStr: string): CroppedImage =
  let rootNode = parseJson(jsonStr)
  result = CroppedImage()
  result.imagePath = rootNode["imagePath"].getStr()
  let cropRect = rootNode["cropRect"]
  result.x = int(cropRect["x"].getFloat())
  result.y = int(cropRect["y"].getFloat())
  result.width = int(cropRect["width"].getFloat())
  result.height = int(cropRect["height"].getFloat())
