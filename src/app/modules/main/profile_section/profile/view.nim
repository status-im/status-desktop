import NimQml

import ./item
import ./model
import ./io_interface
import status/profile as status_profile
import status/status
import ../../../../utils/image_utils

import status/types/[identity_image, profile]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}

  proc getModel*(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc setProfile*(self: View, profile: Item) =
    self.model.setProfile(profile)
    self.modelChanged()

  proc upload*(self: View, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    var image = image_utils.formatImagePath(imageUrl)
    # FIXME the function to get the file size is messed up
    # var size = image_getFileSize(image)
    # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
    # return "Max file size is 20MB"

    try:
      # TODO add crop tool for the image
      let identityImage = self.delegate.storeIdentityImage(self.model.address, image, aX, aY, bX, bY)
      # TODO use only one type
      let identityImageConverted = item.IdentityImage(
        thumbnail: identityImage.thumbnail,
        large: identityImage.thumbnail
      )
      self.model.setIdentityImage(identityImageConverted)
      result = ""
    except Exception as e:
      echo "Error storing identity image", e.msg
      result = "Error storing identity image: " & e.msg

  proc remove*(self: View): string {.slot.} =
    result = self.delegate.deleteIdentityImage(self.model.address)
    if (result == ""):
      self.model.removeIdentityImage()
