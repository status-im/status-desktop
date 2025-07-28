import chronicles
import task
import ../io_interface

export task

type LocalBackupTask* = ref object of PostOnboardingTask
  backupImportFileUrl*: string

proc newLocalBackupTask*(backupImportFileUrl: string): LocalBackupTask =
  result = LocalBackupTask(
      kind: kPostOnboardingTaskLocalBackup,
      backupImportFileUrl: backupImportFileUrl,
    )

proc run*(self: LocalBackupTask, onboardingModule: AccessInterface) =
  debug "running post-onboarding LocalBackupTask"

  onboardingModule.requestLocalBackup(self.backupImportFileUrl)

