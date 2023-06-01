import ../../../../app/core/eventemitter
import ../../accounts/dto/accounts
import installation
import local_pairing_event

type
  LocalPairingState* {.pure.} = enum
    Idle = 0
    Transferring
    Error
    Finished

type
  LocalPairingMode* {.pure.} = enum
    Idle = 0
    Sender
    Receiver

type
  LocalPairingStatus* = ref object of Args
    mode*: LocalPairingMode
    state*: LocalPairingState
    account*: AccountDTO
    password*: string
    installation*: InstallationDto
    error*: string

proc reset*(self: LocalPairingStatus) =
  self.mode = LocalPairingMode.Idle
  self.state = LocalPairingState.Idle
  self.error = ""
  self.installation = InstallationDto()

proc setup(self: LocalPairingStatus) =
  self.reset()

proc delete*(self: LocalPairingStatus) =
  discard

proc newLocalPairingStatus*(): LocalPairingStatus =
  new(result, delete)
  result.setup()

proc update*(self: LocalPairingStatus, data: LocalPairingEventArgs) =
 
  self.error = data.error

 # process any incoming data
  case data.eventType:
  of EventReceivedAccount:
    self.account = data.accountData.account
    self.password = data.accountData.password
  of EventReceivedInstallation:
    self.installation = data.installation
  of EventConnectionError:
      self.state = LocalPairingState.Error
  of EventTransferError:
      self.state = LocalPairingState.Error
  of EventProcessError:
      self.state = LocalPairingState.Error
  else:
    discard

  if self.state == LocalPairingState.Error:
    return

  # Detect finished state
  if (self.mode == LocalPairingMode.Sender and 
      data.eventType == EventProcessSuccess and
      data.action == ActionPairingInstallation):
    self.state = LocalPairingState.Finished

  if (self.mode == LocalPairingMode.Receiver and
      data.eventType == EventTransferSuccess and
      data.action == ActionPairingInstallation):
    self.state = LocalPairingState.Finished

  if self.state == LocalPairingState.Finished:
    return

  self.state = LocalPairingState.Transferring

