import strutils, sequtils, sugar, chronicles

import ../shared_models/[keypair_item]
import ../../global/global_singleton

import ../../../app_service/service/wallet_account/[dto, key_pair_dto]

export keypair_item

logScope:
  topics = "shared-keypairs"

proc buildKeyPairsList*(allWalletAccounts: seq[WalletAccountDto], allMigratedKeypairs: seq[KeyPairDto], 
  excludeAlreadyMigratedPairs: bool, excludePrivateKeyKeypairs: bool): seq[KeyPairItem] =
  let keyPairMigrated = proc(keyUid: string): bool =
    result = false
    for kp in allMigratedKeypairs:
      if kp.keyUid == keyUid:
        return true

  let containsItemWithKeyUid = proc(items: seq[KeyPairItem], keyUid: string): bool =
    return items.any(x => cmpIgnoreCase(x.getKeyUid(), keyUid) == 0)

  var items: seq[KeyPairItem]
  for a in allWalletAccounts:
    let kpMigrated = keyPairMigrated(a.keyUid)
    if a.isChat or a.walletType == WalletTypeWatch or (excludeAlreadyMigratedPairs and kpMigrated):
      continue
    if a.walletType == WalletTypeDefaultStatusAccount:
      var item = newKeyPairItem(keyUid = a.keyUid,
        pubKey = a.publicKey,
        locked = false,
        name = singletonInstance.userProfile.getName(),
        image = singletonInstance.userProfile.getIcon(),
        icon = "",
        pairType = KeyPairType.Profile,
        derivedFrom = a.derivedfrom,
        lastUsedDerivationIndex = a.lastUsedDerivationIndex,
        migratedToKeycard = kpMigrated)
      for ga in allWalletAccounts:
        if cmpIgnoreCase(ga.derivedfrom, a.derivedfrom) != 0:
          continue
        var icon = ""
        if a.walletType == WalletTypeDefaultStatusAccount:
          icon = "wallet"
        item.addAccount(newKeyPairAccountItem(ga.name, ga.path, ga.address, ga.publicKey, ga.emoji, ga.color, icon, balance = 0.0))
      items.insert(item, 0) # Status Account must be at first place
      continue
    if a.walletType == WalletTypeSeed and not containsItemWithKeyUid(items, a.keyUid):
      var item = newKeyPairItem(keyUid = a.keyUid,
        pubKey = a.publicKey,
        locked = false,
        name = a.keypairName,
        image = "",
        icon = if keyPairMigrated(a.keyUid): "keycard" else: "key_pair_seed_phrase",
        pairType = KeyPairType.SeedImport,
        derivedFrom = a.derivedfrom,
        lastUsedDerivationIndex = a.lastUsedDerivationIndex,
        migratedToKeycard = kpMigrated)
      for ga in allWalletAccounts:
        if cmpIgnoreCase(ga.derivedfrom, a.derivedfrom) != 0:
          continue
        item.addAccount(newKeyPairAccountItem(ga.name, ga.path, ga.address, ga.publicKey, ga.emoji, ga.color, icon = "", balance = 0.0))
      items.add(item)
      continue
    if a.walletType == WalletTypeKey and not excludePrivateKeyKeypairs and not containsItemWithKeyUid(items, a.keyUid):
      var item = newKeyPairItem(keyUid = a.keyUid,
        pubKey = a.publicKey,
        locked = false,
        name = a.keypairName,
        image = "",
        icon = if keyPairMigrated(a.keyUid): "keycard" else: "key_pair_private_key",
        pairType = KeyPairType.PrivateKeyImport,
        derivedFrom = a.derivedfrom,
        lastUsedDerivationIndex = a.lastUsedDerivationIndex,
        migratedToKeycard = kpMigrated)
      item.addAccount(newKeyPairAccountItem(a.name, a.path, a.address, a.publicKey, a.emoji, a.color, icon = "", balance = 0.0))
      items.add(item)
      continue
  if items.len == 0:
    debug "sm_there is no any key pair for the logged in user that is not already migrated to a keycard"
  return items