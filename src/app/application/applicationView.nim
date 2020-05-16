import NimQml

# Probably all QT classes will look like this:
QtObject:
  type ApplicationView* = ref object of QObject
    app: QApplication
    lastMessage: string

  # Constructor
  proc newApplicationView*(app: QApplication): ApplicationView =
    new(result)
    result.app = app
    result.lastMessage = ""
    result.setup()

  proc setup(self: ApplicationView) =
    self.QObject.setup

  proc delete*(self: ApplicationView) =
    self.QObject.delete

  proc onExitTriggered(self: ApplicationView) {.slot.} =
    echo "exiting..."
    self.app.quit

  proc lastMessage*(self: ApplicationView): string {.slot.} =
    result = self.lastMessage

  proc receivedMessage*(self: ApplicationView, lastMessage: string) {.signal.}

  proc setLastMessage(self: ApplicationView, lastMessage: string) {.slot.} =
    self.lastMessage = lastMessage
    self.receivedMessage(lastMessage)

  QtProperty[string] lastMessage:
    read = lastMessage
    write = setLastMessage
    notify = receivedMessage
