import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc upload*(self: View, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    # var image = singletonInstance.utils.formatImagePath(imageUrl)
    # FIXME the function to get the file size is messed up
    # var size = image_getFileSize(image)
    # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
    # return "Max file size is 20MB"

    self.delegate.storeIdentityImage(imageUrl, aX, aY, bX, bY)


  proc remove*(self: View): string {.slot.} =
    self.delegate.deleteIdentityImage()
