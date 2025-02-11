type PostOnboardingTaskKind* = enum
  # NOTE: Call from Login apge when the keycard was lost and is being replaced.
  kPostOnboardingTaskKeycardReplacement = 0

  # NOTE: This syncs the list of wallets between the app and the keycard.
  kPostOnboardingSyncKeycardWallets = 1 # Onboarding V1 name: syncKeycardBasedOnAppWalletState

  # NOTE: Do when restoring same keycard from recovery phrase.
  #       In theory this means that the old UID will never be used again, as it is being destroyed on the same physical keycard. # TODO: But do we really need to bother?
  #       Comparing to the `KeycardReplacementTask` which is used when the keycard is lost and a new one is being used. Theoretically the old keycard can still be found and used. # WARNING: But is this secure?
  kPostOnboardingUpdateKeycardUid = 2 # Onboarding V1 name: changedKeycardUids

type PostOnboardingTask* = ref object of RootObj
  kind*: PostOnboardingTaskKind

# NOTE: In theory we could define a `run` {.base.} method here.
# But for now there are not many task kinds, and they require different arguments.
# proc run*(self: KeycardReplacementTask)

proc kind*(self: PostOnboardingTask): PostOnboardingTaskKind =
  return self.kind
