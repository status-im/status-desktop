# NOTE: Keep in sync with OnboardingFlow in ui/StatusQ/src/onboarding/enums.h
type OnboardingFlow* {.pure} = enum
  Unknown = 0,

  CreateProfileWithPassword,
  CreateProfileWithSeedphrase,
  CreateProfileWithKeycardNewSeedphrase,
  CreateProfileWithKeycardExistingSeedphrase,

  LoginWithSeedphrase,
  LoginWithSyncing,
  LoginWithKeycard,
  LoginWithLostKeycardSeedphrase,
  LoginWithRestoredKeycard

type LoginMethod* {.pure} = enum
  Unknown = 0,
  Password,
  Keycard,

type ProgressState* {.pure.} = enum
  Idle,
  InProgress,
  Success,
  Failed,

type AuthorizationState* {.pure.} = enum
  Idle
  InProgress
  Authorized
  WrongPIN
  Error
