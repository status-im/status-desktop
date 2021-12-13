include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncActivityNotificationLoadTaskArg = ref object of QObjectTaskArg
    cursor: string
    limit: int

const asyncActivityNotificationLoadTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncActivityNotificationLoadTaskArg](argEncoded)
  let activityNotificationsCallResult = status_activity_center.rpcActivityCenterNotifications(newJString(arg.cursor), arg.limit)

  let responseJson = %*{
    "activityNotifications": activityNotificationsCallResult.result
  }
  arg.finish(responseJson)
