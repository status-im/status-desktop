include ../../common/json_utils
include ../../../app/core/tasks/common

type AsyncActivityNotificationLoadTaskArg = ref object of QObjectTaskArg
  cursor: string
  limit: int
  group: ActivityCenterGroup
  readType: ActivityCenterReadType

proc asyncActivityNotificationLoadTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncActivityNotificationLoadTaskArg](argEncoded)
  try:
    let activityTypes = activityCenterNotificationTypesByGroup(arg.group)
    let activityNotificationsCallResult = backend.activityCenterNotifications(
      backend.ActivityCenterNotificationsRequest(
        cursor: arg.cursor,
        limit: arg.limit,
        activityTypes: activityTypes,
        readType: arg.readType.int,
      )
    )
    arg.finish(
      %*{
        "activityNotifications": activityNotificationsCallResult.result,
        "error": activityNotificationsCallResult.error,
      }
    )
  except Exception as e:
    arg.finish(%*{"error": e.msg})
