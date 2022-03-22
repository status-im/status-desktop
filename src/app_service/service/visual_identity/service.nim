import chronicles, marshal, json

import ./dto as dto
import ../../../backend/visual_identity as status_visual_identity

export dto

proc emojiHashOf*(pubkey: string): EmojiHashDto =
  try:
    let response = status_visual_identity.emojiHashOf(pubkey)

    if(not response.error.isNil):
      error "error emojiHashOf: ", errDescription = response.error.message

    result = toEmojiHashDto(response.result)

  except Exception as e:
    error "error: ", procName = "emojiHashOf", errName = e.name,
        errDesription = e.msg

proc colorHashOf*(pubkey: string): ColorHashDto =
  try:
    let response = status_visual_identity.colorHashOf(pubkey)

    if(not response.error.isNil):
      error "error colorHashOf: ", errDescription = response.error.message

    result = toColorHashDto(response.result)

  except Exception as e:
    error "error: ", procName = "colorHashOf", errName = e.name,
        errDesription = e.msg

proc getEmojiHashAsJson*(publicKey: string): string =
  return $$emojiHashOf(publicKey)

proc getColorHashAsJson*(publicKey: string): string =
  let colorHash =  colorHashOf(publicKey)
  let json = newJArray()
  for segment in colorHash:
    json.add(%* {"segmentLength": segment.len, "colorId": segment.colorIdx})
  return $json
