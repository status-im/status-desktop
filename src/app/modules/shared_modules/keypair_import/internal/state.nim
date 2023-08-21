import ../controller

type StateType* {.pure.} = enum
  NoState = "NoState"
  SelectKeypair = "SelectKeypair"
  SelectImportMethod = "SelectImportMethod"
  ExportKeypair = "ExportKeypair"
  ImportQr = "ImportQr"
  ImportSeedPhrase = "ImportSeedPhrase"
  ImportPrivateKey = "ImportPrivateKey"
  DisplayInstructions = "DisplayInstructions"


## This is the base class for all states
## We should not instance of this class (in c++ this will be an abstract class).
type
  State* {.pure inheritable.} = ref object of RootObj
    stateType: StateType
    backState: State

proc setup*(self: State, stateType: StateType, backState: State) =
  self.stateType = stateType
  self.backState = backState

## `stateType` - detemines the state this instance describes
## `backState` - the sate (instance) we're moving to if user clicks "back" button,
##               in case we should not display "back" button for this state, set it to `nil`
proc newState*(self: State, stateType: StateType, backState: State): State =
  result = State()
  result.setup(stateType, backState)

proc delete*(self: State) =
  discard

## Returns state type
method stateType*(self: State): StateType {.inline base.} =
  self.stateType

## Returns back state instance
method getBackState*(self: State): State {.inline base.} =
  self.backState

## Returns true if we should display "back" button, otherwise false
method displayBackButton*(self: State): bool {.inline base.} =
  return not self.backState.isNil

## Returns next state instance if "primary" action is triggered
method getNextPrimaryState*(self: State, controller: Controller): State  {.inline base.} =
  return nil

## Returns next state instance if "secondary" action is triggered
method getNextSecondaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## Returns next state instance in case the "tertiary" action is triggered
method getNextTertiaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## Returns next state instance in case the "quaternary" action is triggered
method getNextQuaternaryState*(self: State, controller: Controller): State {.inline base.} =
  return nil

## This method is executed if "cancel" action is triggered (invalidates current flow)
method executeCancelCommand*(self: State, controller: Controller) {.inline base.} =
  controller.closeKeypairImportPopup()

## This method is executed before back state is set, if "back" action is triggered
method executePreBackStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed before primary state is set, if "primary" action is triggered
method executePrePrimaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed before secondary state is set, if "secondary" action is triggered
method executePreSecondaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed in case "tertiary" action is triggered
method executePreTertiaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard

## This method is executed in case "quaternary" action is triggered
method executePreQuaternaryStateCommand*(self: State, controller: Controller) {.inline base.} =
  discard