import chronicles

import ./dto as dto
import ./service_interface
import ../../../backend/visual_identity as status_visual_identity

export dto

type
  Service* = ref object of service_interface.ServiceInterface

proc newService*(): Service =
  result = Service()

method delete*(self: Service) =
  discard

proc emojiHashOf*(self: Service, pubkey: string): EmojiHashDto =
  try:
    let response = status_visual_identity.emojiHashOf(pubkey)

    if(not response.error.isNil):
      error "error emojiHashOf: ", errDescription = response.error.message

    result = toEmojiHashDto(response.result)

  except Exception as e:
    error "error: ", methodName = "emojiHashOf", errName = e.name,
        errDesription = e.msg

proc colorHashOf*(self: Service, pubkey: string): ColorHashDto =
  try:
    let response = status_visual_identity.colorHashOf(pubkey)

    if(not response.error.isNil):
      error "error colorHashOf: ", errDescription = response.error.message

    result = toColorHashDto(response.result)

  except Exception as e:
    error "error: ", methodName = "colorHashOf", errName = e.name,
        errDesription = e.msg
