import NimQml
import ../../../../../app_service/service/contacts/dto/contacts as contacts

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchToOrCreateOneToOneChat*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendContactRequest*(self: AccessInterface, publicKey: string, message: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissContactRequests*(self: AccessInterface, publicKeysJSON: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changeContactNickname*(self: AccessInterface, publicKey: string, nickname: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContactRequestRejection*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

# Controller Delegate Interface

method contactAdded*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactBlocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUnblocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactRemoved*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactNicknameChanged*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactTrustStatusChanged*(self: AccessInterface, publicKey: string, isUntrustworthy: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUpdated*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method markUntrustworthy*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method removeTrustStatus*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method getSentVerificationDetailsAsJson*(self: AccessInterface, publicKey: string): string =
  raise newException(ValueError, "No implementation available")

method getVerificationDetailsFromAsJson*(self: AccessInterface, publicKey: string): string =
  raise newException(ValueError, "No implementation available")

method sendVerificationRequest*(self: AccessInterface, publicKey: string, challenge: string) =
  raise newException(ValueError, "No implementation available")

method cancelVerificationRequest*(self: AccessInterface, publicKey: string) =
  raise newException(ValueError, "No implementation available")

method verifiedTrusted*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method verifiedUntrustworthy*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method declineVerificationRequest*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptVerificationRequest*(self: AccessInterface, publicKey: string, response: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method contactRequestRejectionRemoved*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getReceivedVerificationRequests*(self: AccessInterface): seq[VerificationRequest] {.base.} =
  raise newException(ValueError, "No implementation available")

method hasReceivedVerificationRequestFrom*(self: AccessInterface, fromId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method onVerificationRequestDeclined*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onVerificationRequestUpdatedOrAdded*(self: AccessInterface, VerificationRequest: VerificationRequest) {.base.} =
  raise newException(ValueError, "No implementation available")