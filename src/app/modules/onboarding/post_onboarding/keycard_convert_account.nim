import task
import chronicles

export task

import app_service/service/accounts/service as accounts_service

type KeycardConvertAccountTask* = ref object of PostOnboardingTask
  mnemonic: string
  newPassword*: string

proc newKeycardConvertAccountTask*(mnemonic: string,
                                newPassword: string): KeycardConvertAccountTask =
  result = KeycardConvertAccountTask(
    kind: kConvertKeycardAccountToRegular,
    mnemonic: mnemonic,
    newPassword: newPassword,
  )

proc run*(self: KeycardConvertAccountTask, accountsService: accounts_service.Service) =

  debug "running kConvertKeycardAccountToRegular"

  # TODO: Implement V2 endpoint in status-go which automatically calculates current password
  let account = accountsService.createAccountFromMnemonic(self.mnemonic, includeEncryption = true)
  let currentPassword = account.derivedAccounts.encryption.publicKey

  accountsService.convertKeycardProfileKeypairToRegular(
      self.mnemonic,
      currentPassword,
      self.newPassword)

  # WARNING: If biometrics were enabled, save the new passsword to it, instead of the pin
