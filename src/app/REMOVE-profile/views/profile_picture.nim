import NimQml
import chronicles
import profile_info
import ../../utils/image_utils
import status/profile as status_profile
import status/status


logScope:
  topics = "profile-picture-view"

QtObject:
  type ProfilePictureView* = ref object of QObject
    status*: Status
    profile*: ProfileInfoView
    
  proc setup(self: ProfilePictureView) =
    self.QObject.setup

  proc delete*(self: ProfilePictureView) =
    self.QObject.delete

  proc newProfilePictureView*(status: Status, profile: ProfileInfoView): ProfilePictureView =
    new(result, delete)
    result.status = status
    result.profile = profile
    result.setup

  proc upload*(self: ProfilePictureView, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    var image = image_utils.formatImagePath(imageUrl)
    # FIXME the function to get the file size is messed up
    # var size = image_getFileSize(image)
    # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
    # return "Max file size is 20MB"

    try:
      # TODO add crop tool for the image
      let identityImage = self.status.profile.storeIdentityImage(self.profile.address, image, aX, aY, bX, bY)
      self.profile.setIdentityImage(identityImage)
      result = ""
    except Exception as e:
      error "Error storing identity image", msg=e.msg
      result = "Error storing identity image: " & e.msg

  proc remove*(self: ProfilePictureView): string {.slot.} =
    result = self.status.profile.deleteIdentityImage(self.profile.address)
    if (result == ""):
      self.profile.removeIdentityImage()
