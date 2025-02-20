include app_service/common/mnemonics

proc generateRandomPUK*(): string =
  randomize()
  for i in 0 ..< PUKLengthForStatusApp:
    result = result & $rand(0 .. 9)

proc buildSeedPhrasesFromIndexes*(seedPhraseIndexes: JsonNode): seq[string] =
  var seedPhrase: seq[string]
  for ind in seedPhraseIndexes.items:
    seedPhrase.add(englishWords[ind.getInt])
  return seedPhrase