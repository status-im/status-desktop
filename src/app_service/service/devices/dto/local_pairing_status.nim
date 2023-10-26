import ../../../../app/core/eventemitter
import ../../accounts/dto/accounts
import installation
import local_pairing_event

type
  PairingType* {.pure.} = enum
    AppSync = 0
    KeypairSync

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
    pairingType*: PairingType
    mode*: LocalPairingMode
    state*: LocalPairingState
    account*: AccountDto
    password*: string
    chatKey*: string
    installation*: InstallationDto
    transferredKeypairs*: seq[string] ## seq[keypair_key_uid]
    error*: string

proc delete*(self: LocalPairingStatus) =
  discard

proc newLocalPairingStatus*(pairingType: PairingType, mode: LocalPairingMode): LocalPairingStatus =
  new(result, delete)
  result.pairingType = pairingType
  result.mode = mode
  result.state = LocalPairingState.Idle
  result.installation = InstallationDto()

proc update*(self: LocalPairingStatus, data: LocalPairingEventArgs) =

  self.error = data.error

 # process any incoming data
  case data.eventType:
  of EventReceivedAccount:
    self.account = data.accountData.account
    self.password = data.accountData.password
    self.chatKey = data.accountData.chatKey
  of EventReceivedInstallation:
    self.installation = data.installation
  of EventReceivedKeystoreFiles:
    self.transferredKeypairs = data.transferredKeypairs
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
  if self.mode == LocalPairingMode.Sender and
    data.eventType == EventProcessSuccess:
    if self.pairingType == PairingType.AppSync and
      data.action == ActionPairingInstallation or
      self.pairingType == PairingType.KeypairSync:
        self.state = LocalPairingState.Finished

  if self.mode == LocalPairingMode.Receiver and
    data.eventType == EventCompletedAndNodeReady:
      if self.pairingType == PairingType.AppSync and
        data.action == ActionPairingInstallation or
        self.pairingType == PairingType.KeypairSync:
          self.state = LocalPairingState.Finished

  if self.state == LocalPairingState.Finished:
    return

  self.state = LocalPairingState.Transferring

