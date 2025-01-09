include ../../common/json_utils
include ../../../app/core/tasks/common

type AsyncGetRecentGifsTaskArg = ref object of QObjectTaskArg

proc asyncGetRecentGifsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetRecentGifsTaskArg](argEncoded)
  try:
    let response = status_go.getRecentGifs()
    arg.finish(response)
  except Exception as e:
    arg.finish(%*{"error": e.msg})

type AsyncGetFavoriteGifsTaskArg = ref object of QObjectTaskArg

proc asyncGetFavoriteGifsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetFavoriteGifsTaskArg](argEncoded)
  try:
    let response = status_go.getFavoriteGifs()
    arg.finish(response)
  except Exception as e:
    arg.finish(%*{"error": e.msg})

type AsyncTenorQueryArg = ref object of QObjectTaskArg
  apiKeySet: bool
  apiKey: string
  query: string
  event: string
  errorEvent: string

proc asyncTenorQuery(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncTenorQueryArg](argEncoded)
  try:
    if not arg.apiKeySet:
      let response = status_go.setTenorAPIKey(arg.apiKey)
      if (not response.error.isNil):
        raise newException(RpcException, response.error.message)

    let response = status_go.fetchGifs(arg.query)
    let doc = response.result.str.parseJson()

    var items: seq[GifDto] = @[]
    for json in doc["results"]:
      items.add(tenorToGifDto(json))

    arg.finish(
      %*{"items": items, "event": arg.event, "errorEvent": arg.errorEvent, "error": ""}
    )
  except Exception as e:
    error "error: ",
      procName = "asyncTenorQuery", query = arg.query, errDesription = e.msg

    arg.finish(%*{"error": e.msg, "event": arg.event, "errorEvent": arg.errorEvent})
