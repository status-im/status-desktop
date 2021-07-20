import NimQml, os
import chronicles
import profile_info
import ../../../status/status
import ../../../status/constants as accountConstants

logScope:
  topics = "profile-settings-view"

const UNKNOWN_ACCOUNT = "unknownAccount"

QtObject:
  type ProfileSettingsView* = ref object of QObject
    status*: Status
    profile*: ProfileInfoView
    
  proc setup(self: ProfileSettingsView) =
    self.QObject.setup

  proc delete*(self: ProfileSettingsView) =
    self.QObject.delete

  proc newProfileSettingsView*(status: Status, profile: ProfileInfoView): ProfileSettingsView =
    new(result, delete)
    result.status = status
    result.profile = profile
    result.setup

  proc settingsFileChanged*(self: ProfileSettingsView) {.signal.}

  proc getSettingsFile(self: ProfileSettingsView): string {.slot.} =
    let pubkey =
      if (self.profile.pubKey == ""):
        UNKNOWN_ACCOUNT
      else:
        self.profile.pubKey

    return os.joinPath(accountConstants.DATADIR, "qt", pubkey)

  QtProperty[string] settingsFile:
    read = getSettingsFile
    notify = settingsFileChanged

  proc getGlobalSettingsFile(self: ProfileSettingsView): string {.slot.} =
    return os.joinPath(accountConstants.DATADIR, "qt", "global")

  proc globalSettingsFileChanged*(self: ProfileSettingsView) {.signal.}

  QtProperty[string] globalSettingsFile:
    read = getGlobalSettingsFile
    notify = globalSettingsFileChanged
    
  proc removeUnknownAccountSettings*(self: ProfileSettingsView) =
    # Remove old 'unknownAccount' settings file if it was created
    self.settingsFileChanged()
    let unknownSettingsPath = os.joinPath(accountConstants.DATADIR, "qt", UNKNOWN_ACCOUNT)
    if (not unknownSettingsPath.tryRemoveFile):
      # Only fails if the file exists and an there was an error removing it
      # More info: https://nim-lang.org/docs/os.html#tryRemoveFile%2Cstring
      warn "Failed to remove unused settings file", file=unknownSettingsPath
      