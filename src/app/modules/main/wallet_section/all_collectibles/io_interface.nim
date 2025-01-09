import app/modules/shared_models/collectibles_model as collectibles_model

type AccessInterface* {.pure, inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllCollectiblesModel*(
    self: AccessInterface
): collectibles_model.Model {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshNetworks*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshWalletAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateCollectiblePreferences*(
    self: AccessInterface, collectiblePreferencesJson: string
) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectiblePreferencesJson*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectibleGroupByCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleCollectibleGroupByCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectibleGroupByCollection*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleCollectibleGroupByCollection*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccount*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")
