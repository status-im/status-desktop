import ../../../../app/core/eventemitter
import ../../accounts/dto/accounts
import local_pairing_event

type
  LocalPairingState* {.pure.} = enum
    Idle = 0
    WaitingForConnection
    Transferring
    Error
    Finished

type
  LocalPairingMode* {.pure.} = enum
    Idle = 0
    BootstrapingOtherDevice
    BootstrapingThisDevice

type
  LocalPairingStatus* = ref object of Args
    mode*: LocalPairingMode
    state*: LocalPairingState
    account*: AccountDTO
    error*: string

proc reset*(self: LocalPairingStatus) =
  self.mode = LocalPairingMode.Idle
  self.state = LocalPairingState.Idle
  self.error = ""

proc setup(self: LocalPairingStatus) =
  self.reset()

proc delete*(self: LocalPairingStatus) =
  discard

proc newLocalPairingStatus*(): LocalPairingStatus =
  new(result, delete)
  result.setup()

proc update*(self: LocalPairingStatus, eventType: EventType, action: Action, account: AccountDTO, error: string) =
  case eventType:
  of EventConnectionSuccess:
    self.state = LocalPairingState.WaitingForConnection
  of EventTransferSuccess:
    self.state = case self.mode:
      of LocalPairingMode.BootstrapingOtherDevice:
        LocalPairingState.Finished # For servers, `transfer` is last event
      of LocalPairingMode.BootstrapingThisDevice:
        LocalPairingState.Transferring # For clients, `process` is last event
      else:
        LocalPairingState.Idle
  of EventProcessSuccess:
    self.state = LocalPairingState.Finished
  of EventConnectionError:
      self.state = LocalPairingState.Error
  of EventTransferError:
      self.state = LocalPairingState.Error
  of EventProcessError:
      self.state = LocalPairingState.Error
  of EventReceivedAccount:
    self.account = account
  else:
    discard
  
  self.error = error