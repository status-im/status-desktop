import strformat
import discord_import_errors_model, discord_import_error_item
import ../../../../../app_service/service/community/dto/community
type
  DiscordImportTaskItem* = object
    `type`*: string
    progress*: float
    errors*: DiscordImportErrorsModel
    stopped*: bool

proc `$`*(self: DiscordImportTaskItem): string =
  result = fmt"""DiscordImportTaskItem(
    type: {self.type},
    progress: {self.progress},
    stopped: {self.stopped},
    ]"""

proc initDiscordImportTaskItem*(
  `type`: string,
  progress: float,
  errors: seq[DiscordImportErrorItem],
  stopped: bool
): DiscordImportTaskItem =
  result.type = type
  result.progress = progress
  result.errors = newDiscordDiscordImportErrorsModel()
  result.errors.setItems(errors)
  result.stopped = stopped

proc getType*(self: DiscordImportTaskItem): string =
  return self.type

proc getProgress*(self: DiscordImportTaskItem): float =
  return self.progress

proc getErrors*(self: DiscordImportTaskItem): DiscordImportErrorsModel =
  return self.errors

proc getStopped*(self: DiscordImportTaskItem): bool =
  return self.stopped
