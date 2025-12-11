import nimqml
import io_interface
import ../wallet_section/activity/controller as activity_controller

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      activityController: activity_controller.Controller

  proc setup(self: View)
  proc delete*(self: View)
  proc newView*(delegate: io_interface.AccessInterface,
                activityController: activity_controller.Controller): View =
    new(result, delete)
    result.delegate = delegate
    result.activityController = activityController
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc openUrl*(self: View, url: string) {.signal.}
  proc sendOpenUrlSignal*(self: View, url: string) =
    self.openUrl(url)

  proc getActivityController*(self: View): QVariant {.slot.} =
    return newQVariant(self.activityController)

  QtProperty[QVariant] activityController:
    read = getActivityController

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

