import strutils, sequtils, sugar, chronicles

import ../shared_models/[keypair_item]
import ../../global/global_singleton

import ../../../app_service/service/wallet_account/[keypair_dto, keycard_dto]

export keypair_item

logScope:
  topics = "shared-keypairs"

proc buildKeyPairsList*(keypairs: seq[KeypairDto], allMigratedKeypairs: seq[KeycardDto], 
  excludeAlreadyMigratedPairs: bool, excludePrivateKeyKeypairs: bool): seq[KeyPairItem] =
  let keyPairMigrated = proc(keyUid: string): bool =
    result = false
    for kp in allMigratedKeypairs:
      if kp.keyUid == keyUid:
        return true

  var items: seq[KeyPairItem]
  for kp in keypairs:
    if kp.accounts.len == 0:
      ## we should never be here
      error "there must not be any keypair without accounts", keyUid=kp.keyUid
      return
    let publicKey = kp.accounts[0].publicKey # in case of other but the profile keypair we take public key of first account as keypair's public key
    let kpMigrated = keyPairMigrated(kp.keyUid)
    if excludeAlreadyMigratedPairs and kpMigrated:
      continue
    if kp.keypairType == KeypairTypeProfile:
      var item = newKeyPairItem(keyUid = kp.keyUid,
        pubKey = singletonInstance.userProfile.getPubKey(),
        locked = false,
        name = singletonInstance.userProfile.getName(),
        image = singletonInstance.userProfile.getIcon(),
        icon = "",
        pairType = KeyPairType.Profile,
        derivedFrom = kp.derivedFrom,
        lastUsedDerivationIndex = kp.lastUsedDerivationIndex,
        migratedToKeycard = kpMigrated)
      for acc in kp.accounts:
        if acc.isChat:
          continue
        var icon = ""
        if acc.emoji.len == 0:
          icon = "wallet"
        item.addAccount(newKeyPairAccountItem(acc.name, acc.path, acc.address, acc.publicKey, acc.emoji, acc.color, icon, balance = 0.0))
      items.insert(item, 0) # Status Account must be at first place
      continue
    if kp.keypairType == KeypairTypeSeed:
      var item = newKeyPairItem(keyUid = kp.keyUid,
        pubKey = publicKey,
        locked = false,
        name = kp.name,
        image = "",
        icon = if keyPairMigrated(kp.keyUid): "keycard" else: "key_pair_seed_phrase",
        pairType = KeyPairType.SeedImport,
        derivedFrom = kp.derivedFrom,
        lastUsedDerivationIndex = kp.lastUsedDerivationIndex,
        migratedToKeycard = kpMigrated)
      for acc in kp.accounts:
        var icon = ""
        if acc.emoji.len == 0:
          icon = "wallet"
        item.addAccount(newKeyPairAccountItem(acc.name, acc.path, acc.address, acc.publicKey, acc.emoji, acc.color, icon, balance = 0.0))
      items.add(item)
      continue
    if kp.keypairType == KeypairTypeKey:
      if excludePrivateKeyKeypairs:
        continue
      var item = newKeyPairItem(keyUid = kp.keyUid,
        pubKey = publicKey,
        locked = false,
        name = kp.name,
        image = "",
        icon = if keyPairMigrated(kp.keyUid): "keycard" else: "key_pair_private_key",
        pairType = KeyPairType.PrivateKeyImport,
        derivedFrom = kp.derivedFrom,
        lastUsedDerivationIndex = kp.lastUsedDerivationIndex,
        migratedToKeycard = kpMigrated)
      for acc in kp.accounts:
        var icon = ""
        if acc.emoji.len == 0:
          icon = "wallet"
        item.addAccount(newKeyPairAccountItem(acc.name, acc.path, acc.address, acc.publicKey, acc.emoji, acc.color, icon, balance = 0.0))
      items.add(item)
      continue
  if items.len == 0:
    debug "sm_there is no any key pair for the logged in user that is not already migrated to a keycard"
  return items