import strformat
import discord_import_errors_model, discord_import_error_item
import ../../../../../app_service/service/community/dto/community
type
  DiscordImportTaskItem* = object
    `type`*: string
    progress*: float
    errors*: DiscordImportErrorsModel

proc `$`*(self: DiscordImportTaskItem): string =
  result = fmt"""DiscordImportTaskItem(
    type: {self.type},
    progress: {self.progress},
    ]"""

proc initDiscordImportTaskItem*(
  `type`: string,
  progress: float,
  errors: seq[DiscordImportErrorItem]
): DiscordImportTaskItem =
  result.type = type
  result.progress = progress
  result.errors = newDiscordDiscordImportErrorsModel()
  result.errors.setItems(errors)

proc getType*(self: DiscordImportTaskItem): string =
  return self.type

proc getProgress*(self: DiscordImportTaskItem): float =
  return self.progress

proc getErrors*(self: DiscordImportTaskItem): DiscordImportErrorsModel =
  return self.errors

