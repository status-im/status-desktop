import NimQml
import ../../../status/profile/profile

QtObject:
  type ProfileInfoView* = ref object of QObject
    username*: string
    identicon*: string
    pubKey*: string

  proc setup(self: ProfileInfoView) =
    self.QObject.setup

  proc delete*(self: ProfileInfoView) =
    self.QObject.delete

  proc newProfileInfoView*(): ProfileInfoView =
    new(result, delete)
    result = ProfileInfoView()
    result.pubKey = ""
    result.username = ""
    result.identicon = ""
    result.setup

  proc profileChanged*(self: ProfileInfoView) {.signal.}

  proc setProfile*(self: ProfileInfoView, profile: Profile) =
    self.username = profile.username
    self.identicon = profile.identicon
    self.pubKey = profile.id
    self.profileChanged()

  proc username*(self: ProfileInfoView): string {.slot.} = result = self.username
  QtProperty[string] username:
    read = username
    notify = profileChanged

  proc identicon*(self: ProfileInfoView): string {.slot.} = result = self.identicon
  QtProperty[string] identicon:
    read = identicon
    notify = profileChanged

  proc pubKey*(self: ProfileInfoView): string {.slot.} = self.pubKey

  proc setPubKey*(self: ProfileInfoView, pubKey: string) {.slot.} =
    self.pubKey = pubKey
    self.profileChanged()

  QtProperty[string] pubKey:
    read = pubKey
    notify = profileChanged
