import NimQml

import ../../../shared_models/user_model
import ./io_interface

import models/showcase_contact_generic_model
import models/showcase_contact_accounts_model
import models/showcase_contact_social_links_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      contactsModel: Model
      contactsModelVariant: QVariant
      myMutualContactsModel: Model
      myMutualContactsModelVariant: QVariant
      blockedContactsModel: Model
      blockedContactsModelVariant: QVariant
      receivedContactRequestsModel: Model
      receivedContactRequestsModelVariant: QVariant
      sentContactRequestsModel: Model
      sentContactRequestsModelVariant: QVariant
      # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
      # receivedButRejectedContactRequestsModel: Model
      # receivedButRejectedContactRequestsModelVariant: QVariant
      # sentButRejectedContactRequestsModel: Model
      # sentButRejectedContactRequestsModelVariant: QVariant
      showcaseContactCommunitiesModel: ShowcaseContactGenericModel
      showcaseContactCommunitiesModelVariant: QVariant
      showcaseContactAccountsModel: ShowcaseContactAccountModel
      showcaseContactAccountsModelVariant: QVariant
      showcaseContactCollectiblesModel: ShowcaseContactGenericModel
      showcaseContactCollectiblesModelVariant: QVariant
      showcaseContactAssetsModel: ShowcaseContactGenericModel
      showcaseContactAssetsModelVariant: QVariant
      showcaseContactSocialLinksModel: ShowcaseContactSocialLinkModel
      showcaseContactSocialLinksModelVariant: QVariant


  proc delete*(self: View) =
    self.contactsModel.delete
    self.contactsModelVariant.delete
    self.myMutualContactsModel.delete
    self.myMutualContactsModelVariant.delete
    self.blockedContactsModel.delete
    self.blockedContactsModelVariant.delete
    self.receivedContactRequestsModel.delete
    self.receivedContactRequestsModelVariant.delete
    self.sentContactRequestsModel.delete
    self.sentContactRequestsModelVariant.delete
    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # self.receivedButRejectedContactRequestsModel.delete
    # self.receivedButRejectedContactRequestsModelVariant.delete
    # self.sentButRejectedContactRequestsModelVariant.delete
    # self.sentButRejectedContactRequestsModel.delete
    self.showcaseContactCommunitiesModel.delete
    self.showcaseContactCommunitiesModelVariant.delete
    self.showcaseContactAccountsModel.delete
    self.showcaseContactAccountsModelVariant.delete
    self.showcaseContactCollectiblesModel.delete
    self.showcaseContactCollectiblesModelVariant.delete
    self.showcaseContactAssetsModel.delete
    self.showcaseContactAssetsModelVariant.delete
    self.showcaseContactSocialLinksModel.delete
    self.showcaseContactSocialLinksModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.contactsModel = newModel()
    result.contactsModelVariant = newQVariant(result.contactsModel)
    result.myMutualContactsModel = newModel()
    result.myMutualContactsModelVariant = newQVariant(result.myMutualContactsModel)
    result.blockedContactsModel = newModel()
    result.blockedContactsModelVariant = newQVariant(result.blockedContactsModel)
    result.receivedContactRequestsModel = newModel()
    result.receivedContactRequestsModelVariant = newQVariant(result.receivedContactRequestsModel)
    result.sentContactRequestsModel = newModel()
    result.sentContactRequestsModelVariant = newQVariant(result.sentContactRequestsModel)
    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # result.receivedButRejectedContactRequestsModel = newModel()
    # result.receivedButRejectedContactRequestsModelVariant = newQVariant(result.receivedButRejectedContactRequestsModel)
    # result.sentButRejectedContactRequestsModel = newModel()
    # result.sentButRejectedContactRequestsModelVariant = newQVariant(result.sentButRejectedContactRequestsModel)
    result.showcaseContactCommunitiesModel = newShowcaseContactGenericModel()
    result.showcaseContactCommunitiesModelVariant = newQVariant(result.showcaseContactCommunitiesModel)
    result.showcaseContactAccountsModel = newShowcaseContactAccountModel()
    result.showcaseContactAccountsModelVariant = newQVariant(result.showcaseContactAccountsModel)
    result.showcaseContactCollectiblesModel = newShowcaseContactGenericModel()
    result.showcaseContactCollectiblesModelVariant = newQVariant(result.showcaseContactCollectiblesModel)
    result.showcaseContactAssetsModel = newShowcaseContactGenericModel()
    result.showcaseContactAssetsModelVariant = newQVariant(result.showcaseContactAssetsModel)
    result.showcaseContactSocialLinksModel = newShowcaseContactSocialLinkModel()
    result.showcaseContactSocialLinksModelVariant = newQVariant(result.showcaseContactSocialLinksModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()
    
  proc contactsModel*(self: View): Model =
    return self.contactsModel

  proc myMutualContactsModel*(self: View): Model =
    return self.myMutualContactsModel

  proc blockedContactsModel*(self: View): Model =
    return self.blockedContactsModel

  proc receivedContactRequestsModel*(self: View): Model =
    return self.receivedContactRequestsModel
  
  proc sentContactRequestsModel*(self: View): Model =
    return self.sentContactRequestsModel

  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # proc receivedButRejectedContactRequestsModel*(self: View): Model =
  #   return self.receivedButRejectedContactRequestsModel

  # proc sentButRejectedContactRequestsModel*(self: View): Model =
  #   return self.sentButRejectedContactRequestsModel

  proc contactsModelChanged(self: View) {.signal.}
  proc getContactsModel(self: View): QVariant {.slot.} =
    return self.contactsModelVariant
  QtProperty[QVariant] contactsModel:
    read = getContactsModel
    notify = contactsModelChanged

  proc myMutualContactsModelChanged(self: View) {.signal.}
  proc getMyMutualContactsModel(self: View): QVariant {.slot.} =
    return self.myMutualContactsModelVariant
  QtProperty[QVariant] myMutualContactsModel:
    read = getMyMutualContactsModel
    notify = myMutualContactsModelChanged

  proc blockedContactsModelChanged(self: View) {.signal.}
  proc getBlockedContactsModel(self: View): QVariant {.slot.} =
    return self.blockedContactsModelVariant
  QtProperty[QVariant] blockedContactsModel:
    read = getBlockedContactsModel
    notify = blockedContactsModelChanged

  proc receivedContactRequestsModelChanged(self: View) {.signal.}
  proc getReceivedContactRequestsModel(self: View): QVariant {.slot.} =
    return self.receivedContactRequestsModelVariant
  QtProperty[QVariant] receivedContactRequestsModel:
    read = getReceivedContactRequestsModel
    notify = receivedContactRequestsModelChanged

  proc sentContactRequestsModelChanged(self: View) {.signal.}
  proc getSentContactRequestsModel(self: View): QVariant {.slot.} =
    return self.sentContactRequestsModelVariant
  QtProperty[QVariant] sentContactRequestsModel:
    read = getSentContactRequestsModel
    notify = sentContactRequestsModelChanged

  proc contactInfoRequestFinished(self: View, publicKey: string, ok: bool) {.signal.}

  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # proc receivedButRejectedContactRequestsModelChanged(self: View) {.signal.}
  # proc getReceivedButRejectedContactRequestsModel(self: View): QVariant {.slot.} =
  #   return self.receivedButRejectedContactRequestsModelVariant
  # QtProperty[QVariant] receivedButRejectedContactRequestsModel:
  #   read = getReceivedButRejectedContactRequestsModel
  #   notify = receivedButRejectedContactRequestsModelChanged

  # proc sentButRejectedContactRequestsModelChanged(self: View) {.signal.}
  # proc getSentButRejectedContactRequestsModel(self: View): QVariant {.slot.} =
  #   return self.sentButRejectedContactRequestsModelVariant
  # QtProperty[QVariant] sentButRejectedContactRequestsModel:
  #   read = getSentButRejectedContactRequestsModel
  #   notify = sentButRejectedContactRequestsModelChanged

  proc isMyMutualContact*(self: View, publicKey: string): bool {.slot.} =
    return self.myMutualContactsModel.isContactWithIdAdded(publicKey)

  proc isBlockedContact*(self: View, publicKey: string): bool {.slot.} =
    return self.blockedContactsModel.isContactWithIdAdded(publicKey)

  proc hasPendingContactRequest*(self: View, publicKey: string): bool {.slot.} =
    return self.sentContactRequestsModel.isContactWithIdAdded(publicKey)

  proc sendContactRequest*(self: View, publicKey: string, message: string) {.slot.} =
    self.delegate.sendContactRequest(publicKey, message)

  proc switchToOrCreateOneToOneChat*(self: View, publicKey: string) {.slot.} =
    self.delegate.switchToOrCreateOneToOneChat(publicKey)

  proc acceptContactRequest*(self: View, publicKey: string, contactRequestId: string) {.slot.} =
    self.delegate.acceptContactRequest(publicKey, contactRequestId)

  proc dismissContactRequest*(self: View, publicKey: string, contactRequestId: string) {.slot.} =
    self.delegate.dismissContactRequest(publicKey, contactRequestId)

  proc getLatestContactRequestForContactAsJson*(self: View, publicKey: string): string {.slot.} =
    self.delegate.getLatestContactRequestForContactAsJson(publicKey)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    self.delegate.changeContactNickname(publicKey, nickname)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.unblockContact(publicKey)

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)

  proc markAsTrusted*(self: View, publicKey: string) {.slot.} =
    self.delegate.markAsTrusted(publicKey)

  proc markUntrustworthy*(self: View, publicKey: string) {.slot.} =
    self.delegate.markUntrustworthy(publicKey)

  proc removeTrustStatus*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeTrustStatus(publicKey)

  proc removeTrustVerificationStatus*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeTrustVerificationStatus(publicKey)

  proc shareUserUrlWithData*(self: View, pubkey: string): string {.slot.} =
    return self.delegate.shareUserUrlWithData(pubkey)

  proc shareUserUrlWithChatKey*(self: View, pubkey: string): string {.slot.} =
    return self.delegate.shareUserUrlWithChatKey(pubkey)

  proc shareUserUrlWithENS*(self: View, pubkey: string): string {.slot.} =
    return self.delegate.shareUserUrlWithENS(pubkey)

  proc requestContactInfo*(self: View, publicKey: string) {.slot.} =
    self.delegate.requestContactInfo(publicKey)

  proc onContactInfoRequestFinished*(self: View, publicKey: string, ok: bool) {.slot.} =
    self.contactInfoRequestFinished(publicKey, ok)

  # Showcase models for a contact
  proc getShowcaseContactCommunitiesModel(self: View): QVariant {.slot.} =
    return self.showcaseContactCommunitiesModelVariant
  QtProperty[QVariant] showcaseContactCommunitiesModel:
    read = getShowcaseContactCommunitiesModel

  proc getShowcaseContactAccountsModel(self: View): QVariant {.slot.} =
    return self.showcaseContactAccountsModelVariant
  QtProperty[QVariant] showcaseContactAccountsModel:
    read = getShowcaseContactAccountsModel

  proc getShowcaseContactCollectiblesModel(self: View): QVariant {.slot.} =
    return self.showcaseContactCollectiblesModelVariant
  QtProperty[QVariant] showcaseContactCollectiblesModel:
    read = getShowcaseContactCollectiblesModel

  proc getShowcaseContactAssetsModel(self: View): QVariant {.slot.} =
    return self.showcaseContactAssetsModelVariant
  QtProperty[QVariant] showcaseContactAssetsModel:
    read = getShowcaseContactAssetsModel

  proc getShowcaseContactSocialLinksModel(self: View): QVariant {.slot.} =
    return self.showcaseContactSocialLinksModelVariant
  QtProperty[QVariant] showcaseContactSocialLinksModel:
    read = getShowcaseContactSocialLinksModel

  # Support models for showcase for a contact
  proc showcaseCollectiblesModelChanged*(self: View) {.signal.}
  proc getShowcaseCollectiblesModel(self: View): QVariant {.slot.} =
    return self.delegate.getShowcaseCollectiblesModel()
  QtProperty[QVariant] showcaseCollectiblesModel:
    read = getShowcaseCollectiblesModel
    notify = showcaseCollectiblesModelChanged

  proc showcaseForAContactLoadingChanged*(self: View) {.signal.}
  proc emitShowcaseForAContactLoadingChangedSignal*(self: View) =
    self.showcaseForAContactLoadingChanged()
  proc isShowcaseForAContactLoading*(self: View): bool {.slot.} =
    return self.delegate.isShowcaseForAContactLoading()
  QtProperty[bool] showcaseForAContactLoading:
    read = isShowcaseForAContactLoading
    notify = showcaseForAContactLoadingChanged

  proc fetchProfileShowcaseAccountsByAddress*(self: View, address: string) {.slot.} =
    self.delegate.fetchProfileShowcaseAccountsByAddress(address)

  proc profileShowcaseAccountsByAddressFetched*(self: View, accounts: string) {.signal.}
  proc emitProfileShowcaseAccountsByAddressFetchedSignal*(self: View, accounts: string) =
    self.profileShowcaseAccountsByAddressFetched(accounts)

  proc requestProfileShowcase(self: View, publicKey: string) {.slot.} =
    self.delegate.requestProfileShowcase(publicKey)

  proc clearShowcaseModels*(self: View) {.slot.} =
    self.showcaseContactCommunitiesModel.clear()
    self.showcaseContactAccountsModel.clear()
    self.showcaseContactCollectiblesModel.clear()
    self.showcaseContactAssetsModel.clear()
    self.showcaseContactSocialLinksModel.clear()

  proc loadProfileShowcaseContactCommunities*(self: View, items: seq[ShowcaseContactGenericItem]) =
    self.showcaseContactCommunitiesModel.setItems(items)

  proc loadProfileShowcaseContactAccounts*(self: View, items: seq[ShowcaseContactAccountItem]) =
    self.showcaseContactAccountsModel.setItems(items)

  proc loadProfileShowcaseContactCollectibles*(self: View, items: seq[ShowcaseContactGenericItem]) =
    self.showcaseContactCollectiblesModel.setItems(items)

  proc loadProfileShowcaseContactAssets*(self: View, items: seq[ShowcaseContactGenericItem]) =
    self.showcaseContactAssetsModel.setItems(items)

  proc loadProfileShowcaseContactSocialLinks*(self: View, items: seq[ShowcaseContactSocialLinkItem]) =
    self.showcaseContactSocialLinksModel.setItems(items)
