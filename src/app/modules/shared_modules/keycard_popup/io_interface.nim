import NimQml
import ../../../../app/core/eventemitter
from ../../../../app_service/service/keycard/service import KeycardEvent, KeyDetails

const SignalSharedKeycarModuleFlowTerminated* = "sharedKeycarModuleFlowTerminated"

type
  SharedKeycarModuleFlowTerminatedArgs* = ref object of Args
    lastStepInTheCurrentFlow*: bool

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeycardData*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBackActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
    
method onPrimaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSecondaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardResponse*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")

method runFactoryResetFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  DelegateInterface* = concept c
    #c.startupDidLoad()
    #c.userLoggedIn()
