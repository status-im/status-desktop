import chronicles
import task
import ../io_interface

import app_service/service/accounts/service as accounts_service

export task

type SaveBiometricsTask* = ref object of PostOnboardingTask
  credential*: string

proc newSaveBiometricsTask*(credential: string): SaveBiometricsTask =
  result = SaveBiometricsTask(
      kind: kPostOnboardingTaskSaveBiometrics,
      credential: credential,
    )

proc run*(self: SaveBiometricsTask, accountsService: accounts_service.Service, onboardingModule: AccessInterface) =
  debug "running post-onboarding SaveBiometricsTask"

  let keyUid = accountsService.getLoggedInAccount().keyUid
  onboardingModule.requestSaveBiometrics(keyUid, self.credential)

