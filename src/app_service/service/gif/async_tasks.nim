include ../../common/json_utils
include ../../../app/core/tasks/common
import ../../../backend/gifs as status_go

type
  AsyncGetRecentGifsTaskArg = ref object of QObjectTaskArg

const asyncGetRecentGifsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetRecentGifsTaskArg](argEncoded)
  let response = status_go.getRecentGifs()
  arg.finish(response)

type
  AsyncGetFavoriteGifsTaskArg = ref object of QObjectTaskArg

const asyncGetFavoriteGifsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetFavoriteGifsTaskArg](argEncoded)
  let response = status_go.getFavoriteGifs()
  arg.finish(response)
