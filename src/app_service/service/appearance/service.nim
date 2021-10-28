import os, json, json_serialization, sequtils, chronicles

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "privacy-service"

type 
  Service* = ref object of ServiceInterface
    # profile: Dto

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    echo "init"

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method readTextFile*(self: Service, filepath: string): string =
  try:
    return readFile(filepath)
  except:
    return ""

method writeTextFile*(self: Service, filepath: string, text: string): bool =
  try:
    writeFile(filepath, text)
    return true
  except:
    return false
