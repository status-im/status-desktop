include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncActivityNotificationLoadTaskArg = ref object of QObjectTaskArg
    cursor: string
    limit: int
    group: ActivityCenterGroup
    readType: ActivityCenterReadType

const asyncActivityNotificationLoadTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncActivityNotificationLoadTaskArg](argEncoded)
  let activityTypes = activityCenterNotificationTypesByGroup(arg.group)
  let activityNotificationsCallResult = backend.activityCenterNotifications(
    backend.ActivityCenterNotificationsRequest(
      cursor: arg.cursor,
      limit: arg.limit,
      activityTypes: activityTypes,
      readType: arg.readType.int
    )
  )

  let responseJson = %*{
    "activityNotifications": activityNotificationsCallResult.result
  }
  arg.finish(responseJson)
