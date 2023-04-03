include ../../common/json_utils
import ../../../backend/eth
import ../../../app/core/tasks/common
import ../../../app/core/tasks/qt
import ../transaction/dto

type
  AsyncGetSuggestedFees = ref object of QObjectTaskArg
    chainId: int

const asyncGetSuggestedFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetSuggestedFees](argEncoded)
  try:
    let response = eth.suggestedFees(arg.chainId).result
    arg.finish(%* {
      "fees": response.toSuggestedFeesDto(),
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

