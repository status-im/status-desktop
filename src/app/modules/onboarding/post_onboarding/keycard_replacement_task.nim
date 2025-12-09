import sequtils, chronicles, sugar
import task

import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/keycardV2/service as keycard_serviceV2

export task

type KeycardReplacementTask* = ref object of PostOnboardingTask
  keyUid: string
  keycardInstanceUID: string

proc newKeycardReplacementTask*(keyUid: string,
                                keycardInstanceUID: string): KeycardReplacementTask =
  result = KeycardReplacementTask(
    kind: kPostOnboardingTaskKeycardReplacement,
    keyUid: keyUid,
    keycardInstanceUID: keycardInstanceUID,
  )

proc run*(self: KeycardReplacementTask,
            walletAccountService: wallet_account_service.Service,
            keycardServiceV2: keycard_serviceV2.Service) =

  # NOTE: This implementation was taken from `doKeycardReplacement` in `app_controller.nim`

  debug "running post-onboarding KeycardReplacementTask"

  let keypair = walletAccountService.getKeypairByKeyUid(self.keyUid)
  if keypair.isNil:
    error "cannot resolve appropriate keypair for logged in user"
    return

  if self.keycardInstanceUID.len == 0 or self.keyUid != self.keyUid:
      warn "keycard replacement process is not fully completed, try the same again"
      return

  # we have to delete all keycards with the same key uid to cover the case if user had more then a single keycard for the same keypair
  discard walletAccountService.deleteAllKeycardsWithKeyUid(self.keyUid)

  # store new keycard with accounts, in this context no need to check if accounts match the default Status derivation path,
  # cause otherwise we wouldn't be here (cannot have keycard profile with any such path)
  let accountsAddresses = keypair.accounts.filter(acc => not acc.isChat).map(acc => acc.address)
  let keycard = KeycardDto(
    keycardUid: self.keycardInstanceUID,
    keycardName: keypair.name,
    keyUid: self.keyUid,
    accountsAddresses: accountsAddresses
  )
  discard walletAccountService.addKeycardOrAccounts(keycard, password = "")

  # FIXME: store metadata to a Keycard - https://github.com/status-im/status-app/issues/17128
  # let accountsPathsToStore = keypair.accounts.filter(acc => not acc.isChat).map(acc => acc.path)
  # keycardServiceV2.asyncStoreMetadata(keypair.name, self.startupModule.getPin(), accountsPathsToStore)

  info "keycard replacement fully done"

