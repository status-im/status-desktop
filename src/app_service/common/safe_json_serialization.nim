## Safe JSON Serialization Module
## ===========================
##
## This module provides safe JSON serialization and deserialization utilities.
## It ensures input strings remain alive during the entire decode operation,
## preventing potential memory issues.

import
  json_serialization,
  faststreams/inputs,
  chronicles

export json_serialization

proc safeDecode*(Format: distinct type, input: string, T: type, allowUnknownFields = false, requireAllFields = false): T =
  ## Safely decodes a JSON string into the specified type T.
  ## This version ensures the input string remains alive during the entire decode operation.
  result = Format.decode(input, T, allowUnknownFields = allowUnknownFields, requireAllFields = requireAllFields)
  ## Warning: Don't remove `input` reference here to keep it alive during the decode operation.
  if input.len == 0:
    error "Cannot decode empty input"

proc safeDecode*(Format: distinct type, input: openArray[byte], T: type, allowUnknownFields = false, requireAllFields = false): T =
  ## Safely decodes a JSON string into the specified type T.
  ## This version ensures the input string remains alive during the entire decode operation.
  result = Format.decode(input, T, allowUnknownFields = allowUnknownFields, requireAllFields = requireAllFields)
  ## Warning: Don't remove `input` reference here to keep it alive during the decode operation.
  if input.len == 0:
    error "Cannot decode empty input"
