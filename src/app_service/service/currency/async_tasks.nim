type
  FetchAllCurrencyFormatsTaskArg = ref object of QObjectTaskArg
    discard

proc fetchAllCurrencyFormatsTaskArg(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchAllCurrencyFormatsTaskArg](argEncoded)
  let output = %* {
    "formats": ""
  }
  try:
    let response = backend.fetchAllCurrencyFormats()
    output["formats"] = response.result
  except Exception as e:
    let errDesription = e.msg
    error "error fetchAllCurrencyFormatsTaskArg: ", errDesription
  arg.finish(output)
