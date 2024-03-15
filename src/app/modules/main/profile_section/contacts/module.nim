import NimQml, chronicles

import io_interface, view, controller, json
import ../../../shared_models/user_item
import ../../../shared_models/user_model
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../core/eventemitter
import app_service/common/types
import app_service/service/contacts/dto/contacts as contacts_dto
import app_service/service/contacts/service as contacts_service
import app_service/service/chat/service as chat_service
import app_service/service/network/service as network_service

import app/modules/shared_modules/collectibles/controller as collectiblesc
import backend/collectibles as backend_collectibles
import app_service/service/contacts/dto/profile_showcase

import models/showcase_contact_generic_model
import models/showcase_contact_accounts_model
import models/showcase_contact_social_links_model

export io_interface

logScope:
  topics = "profile-section-contacts-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.Controller
    collectiblesController: collectiblesc.Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    showcasePublicKey: string

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  networkService: network_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, contactsService, chatService, networkService)
  result.collectiblesController = collectiblesc.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.ProfileShowcase),
    loadType = collectiblesc.LoadType.AutoLoadSingleUpdate,
    networkService = networkService,
    events = events
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.collectiblesController.delete

proc createItemFromPublicKey(self: Module, publicKey: string): UserItem =
  let contactDetails = self.controller.getContactDetails(publicKey)

  return initUserItem(
    pubKey = contactDetails.dto.id,
    displayName = contactDetails.dto.displayName,
    ensName = contactDetails.dto.name,
    isEnsVerified = contactDetails.dto.ensVerified,
    localNickname = contactDetails.dto.localNickname,
    alias = contactDetails.dto.alias,
    icon = contactDetails.icon,
    colorId = contactDetails.colorId,
    colorHash = contactDetails.colorHash,
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(publicKey).statusType),
    isContact = contactDetails.dto.isContact(),
    isVerified = contactDetails.dto.isContactVerified(),
    isUntrustworthy = contactDetails.dto.isContactUntrustworthy(),
    isBlocked = contactDetails.dto.isBlocked(),
  )

proc buildModel(self: Module, model: Model, group: ContactsGroup) =
  var items: seq[UserItem]
  let contacts =  self.controller.getContacts(group)
  for c in contacts:
    let item = self.createItemFromPublicKey(c.id)
    items.add(item)

  model.addItems(items)

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.buildModel(self.view.myMutualContactsModel(), ContactsGroup.MyMutualContacts)
  self.buildModel(self.view.blockedContactsModel(), ContactsGroup.BlockedContacts)
  self.buildModel(self.view.receivedContactRequestsModel(), ContactsGroup.IncomingPendingContactRequests)
  self.buildModel(self.view.sentContactRequestsModel(), ContactsGroup.OutgoingPendingContactRequests)
  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # self.buildModel(self.view.receivedButRejectedContactRequestsModel(), ContactsGroup.IncomingRejectedContactRequests)
  # self.buildModel(self.view.sentButRejectedContactRequestsModel(), ContactsGroup.IncomingRejectedContactRequests)
  
  let receivedVerificationRequests = self.controller.getReceivedVerificationRequests()
  var receivedVerificationRequestItems: seq[UserItem] = @[]
  for receivedVerificationRequest in receivedVerificationRequests:
    if receivedVerificationRequest.status == VerificationStatus.Verifying or
        receivedVerificationRequest.status == VerificationStatus.Verified:
      let contactItem = self.createItemFromPublicKey(receivedVerificationRequest.fromID)
      contactItem.incomingVerificationStatus = toVerificationRequestStatus(receivedVerificationRequest.status)
      receivedVerificationRequestItems.add(contactItem)
  self.view.receivedContactRequestsModel().addItems(receivedVerificationRequestItems)

  self.moduleLoaded = true
  self.delegate.contactsModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method sendContactRequest*(self: Module, publicKey: string, message: string) =
  self.controller.sendContactRequest(publicKey, message)

method acceptContactRequest*(self: Module, publicKey: string, contactRequestId: string) =
  self.controller.acceptContactRequest(publicKey, contactRequestId)

method dismissContactRequest*(self: Module, publicKey: string, contactRequestId: string) =
  self.controller.dismissContactRequest(publicKey, contactRequestId)

method getLatestContactRequestForContactAsJson*(self: Module, publicKey: string): string =
  let contactRequest = self.controller.getLatestContactRequestForContact(publicKey)
  let jsonObj = %* {
    "id": contactRequest.id,
    "from": contactRequest.from,
    "clock": contactRequest.clock,
    "text": contactRequest.text,
    "contactRequestState": contactRequest.contactRequestState.int,
  }
  return $jsonObj

method switchToOrCreateOneToOneChat*(self: Module, publicKey: string) =
  self.controller.switchToOrCreateOneToOneChat(publicKey)

method unblockContact*(self: Module, publicKey: string) =
  self.controller.unblockContact(publicKey)

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method removeContact*(self: Module, publicKey: string) =
  self.controller.removeContact(publicKey)

method changeContactNickname*(self: Module, publicKey: string, nickname: string) =
  self.controller.changeContactNickname(publicKey, nickname)

proc addItemToAppropriateModel(self: Module, item: UserItem) =
  if(singletonInstance.userProfile.getPubKey() == item.pubKey):
    return
  let contact = self.controller.getContact(item.pubKey())

  if contact.isBlocked():
    self.view.blockedContactsModel().addItem(item)
    return

  case contact.contactRequestState:
    of ContactRequestState.Received:
      self.view.receivedContactRequestsModel().addItem(item)
    of ContactRequestState.Sent:
      self.view.sentContactRequestsModel().addItem(item)
    of ContactRequestState.Mutual:
      self.view.myMutualContactsModel().addItem(item)
    else:
      return

proc removeItemWithPubKeyFromAllModels(self: Module, publicKey: string) =
  self.view.myMutualContactsModel().removeItemById(publicKey)
  self.view.receivedContactRequestsModel().removeItemById(publicKey)
  self.view.sentContactRequestsModel().removeItemById(publicKey)
  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # self.view.receivedButRejectedContactRequestsModel().removeItemById(publicKey)
  # self.view.sentButRejectedContactRequestsModel().removeItemById(publicKey)
  self.view.blockedContactsModel().removeItemById(publicKey)

proc removeIfExistsAndAddToAppropriateModel(self: Module, publicKey: string) =
  self.removeItemWithPubKeyFromAllModels(publicKey)
  let item = self.createItemFromPublicKey(publicKey)
  self.addItemToAppropriateModel(item)

method contactAdded*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactBlocked*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactUnblocked*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactRemoved*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactUpdated*(self: Module, publicKey: string) =
  self.removeIfExistsAndAddToAppropriateModel(publicKey)

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    let status = toOnlineStatus(s.statusType)
    self.view.myMutualContactsModel().setOnlineStatus(s.publicKey, status)

method contactNicknameChanged*(self: Module, publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  let displayName = contactDetails.dto.displayName
  let ensName = contactDetails.dto.name
  let localNickname = contactDetails.dto.localNickname

  self.view.myMutualContactsModel().setName(publicKey, displayName, ensName, localNickname)
  self.view.receivedContactRequestsModel().setName(publicKey, displayName, ensName, localNickname)
  self.view.sentContactRequestsModel().setName(publicKey, displayName, ensName, localNickname)
  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # self.view.receivedButRejectedContactRequestsModel().setName(publicKey, displayName, ensName, localNickname)
  # self.view.sentButRejectedContactRequestsModel().setName(publicKey, displayName, ensName, localNickname)
  self.view.blockedContactsModel().setName(publicKey, displayName, ensName, localNickname)

method contactTrustStatusChanged*(self: Module, publicKey: string, isUntrustworthy: bool) =
  self.view.myMutualContactsModel().updateTrustStatus(publicKey, isUntrustworthy)
  self.view.blockedContactsModel().updateTrustStatus(publicKey, isUntrustworthy)

method markAsTrusted*(self: Module, publicKey: string): void =
  self.controller.markAsTrusted(publicKey)

method markUntrustworthy*(self: Module, publicKey: string): void =
  self.controller.markUntrustworthy(publicKey)

method removeTrustStatus*(self: Module, publicKey: string): void =
  self.controller.removeTrustStatus(publicKey)

method getSentVerificationDetailsAsJson*(self: Module, publicKey: string): string =
  let verificationRequest = self.controller.getVerificationRequestSentTo(publicKey)
  let (name, image, largeImage) = self.controller.getContactNameAndImage(publicKey)
  let jsonObj = %* {
    "challenge": verificationRequest.challenge,
    "response": verificationRequest.response,
    "requestedAt": verificationRequest.requestedAt,
    "requestStatus": verificationRequest.status.int,
    "repliedAt": verificationRequest.repliedAt,
    "icon": image,
    "largeImage": largeImage,
    "displayName": name
  }
  return $jsonObj

method getVerificationDetailsFromAsJson*(self: Module, publicKey: string): string =
  let verificationRequest = self.controller.getVerificationRequestFrom(publicKey)
  let (name, image, largeImage) = self.controller.getContactNameAndImage(publicKey)
  let jsonObj = %* {
    "from": verificationRequest.fromId,
    "challenge": verificationRequest.challenge,
    "response": verificationRequest.response,
    "requestedAt": verificationRequest.requestedAt,
    "requestStatus": verificationRequest.status.int,
    "repliedAt": verificationRequest.repliedAt,
    "icon": image,
    "largeImage": largeImage,
    "displayName": name
  }
  return $jsonObj

method sendVerificationRequest*(self: Module, publicKey: string, challenge: string) =
  self.controller.sendVerificationRequest(publicKey, challenge)

method cancelVerificationRequest*(self: Module, publicKey: string) =
  self.controller.cancelVerificationRequest(publicKey)

method verifiedTrusted*(self: Module, publicKey: string) =
  self.controller.verifiedTrusted(publicKey)

method verifiedUntrustworthy*(self: Module, publicKey: string) =
  self.controller.verifiedUntrustworthy(publicKey)

method declineVerificationRequest*(self: Module, publicKey: string) =
  self.controller.declineVerificationRequest(publicKey)

method acceptVerificationRequest*(self: Module, publicKey: string, response: string) =
  self.controller.acceptVerificationRequest(publicKey, response)

method getReceivedVerificationRequests*(self: Module): seq[VerificationRequest] =
  self.controller.getReceivedVerificationRequests()

method onVerificationRequestDeclined*(self: Module, publicKey: string) =
  self.view.receivedContactRequestsModel.removeItemById(publicKey)

method onVerificationRequestCanceled*(self: Module, publicKey: string) =
  self.view.receivedContactRequestsModel.removeItemById(publicKey)

method onVerificationRequestUpdatedOrAdded*(self: Module, request: VerificationRequest) =
  let item =  self.createItemFromPublicKey(request.fromID)
  item.incomingVerificationStatus = toVerificationRequestStatus(request.status)
  if (self.view.receivedContactRequestsModel.containsItemWithPubKey(request.fromID)):
    if request.status != VerificationStatus.Verifying and
        request.status != VerificationStatus.Verified:
      self.view.receivedContactRequestsModel.removeItemById(request.fromID)
      return
    self.view.receivedContactRequestsModel.updateIncomingRequestStatus(
      item.pubKey,
      item.incomingVerificationStatus
    )
    return
  self.view.receivedContactRequestsModel.addItem(item)

method requestContactInfo*(self: Module, publicKey: string) =
  self.controller.requestContactInfo(publicKey)

method onContactInfoRequestFinished*(self: Module, publicKey: string, ok: bool) =
  self.view.onContactInfoRequestFinished(publicKey, ok)

method shareUserUrlWithData*(self: Module, pubkey: string): string =
  return self.controller.shareUserUrlWithData(pubkey)

method shareUserUrlWithChatKey*(self: Module, pubkey: string): string =
  return self.controller.shareUserUrlWithChatKey(pubkey)

method shareUserUrlWithENS*(self: Module, pubkey: string): string =
  return self.controller.shareUserUrlWithENS(pubkey)

# Profile showcase for a contanct related stuff
method requestProfileShowcase*(self: Module, publicKey: string) =
  if self.showcasePublicKey != publicKey:
    self.view.clearShowcaseModels()
  self.showcasePublicKey = publicKey

  self.controller.requestProfileShowcaseForContact(publicKey)

method updateProfileShowcase(self: Module, profileShowcase: ProfileShowcaseDto) =
  if self.showcasePublicKey != profileShowcase.contactId:
    warn "Got profile showcase for wrong contact id"
    return

  var communityItems: seq[ShowcaseContactGenericItem] = @[]
  for community in profileShowcase.communities:
    # TODO: https://github.com/status-im/status-desktop/issues/14084
    # if community.membershipStatus == ProfileShowcaseMembershipStatus.ProvenMember:
    communityItems.add(ShowcaseContactGenericItem(
      showcaseKey: community.communityId,
      showcasePosition: community.order
    ))
  self.view.updateProfileShowcaseContactCommunities(communityItems)

  var accountItems: seq[ShowcaseContactAccountItem] = @[]
  var accountAddresses: seq[string] = @[]
  for account in profileShowcase.accounts:
    accountItems.add(ShowcaseContactAccountItem(
      address: account.address,
      name: account.name,
      emoji: account.emoji,
      colorId: account.colorId,
      showcasePosition: account.order
    ))
    accountAddresses.add(account.address)
  self.view.updateProfileShowcaseContactAccounts(accountItems)

  var collectibleItems: seq[ShowcaseContactGenericItem] = @[]
  for collectible in profileShowcase.collectibles:
    collectibleItems.add(ShowcaseContactGenericItem(
      showcaseKey: collectible.toCombinedCollectibleId(),
      showcasePosition: collectible.order
    ))
  self.view.updateProfileShowcaseContactCollectibles(collectibleItems)

  var assetItems: seq[ShowcaseContactGenericItem] = @[]
  for token in profileShowcase.verifiedTokens:
    assetItems.add(ShowcaseContactGenericItem(
      showcaseKey: token.symbol,
      showcasePosition: token.order
    ))
  for token in profileShowcase.unverifiedTokens:
    assetItems.add(ShowcaseContactGenericItem(
      showcaseKey: token.toCombinedTokenId(),
      showcasePosition: token.order
    ))
  self.view.updateProfileShowcaseContactAssets(assetItems)

  var socialLinkItems: seq[ShowcaseContactSocialLinkItem] = @[]
  for socialLink in profileShowcase.socialLinks:
    socialLinkItems.add(ShowcaseContactSocialLinkItem(
      url: socialLink.url,
      text: socialLink.text,
      showcasePosition: socialLink.order
    ))
  self.view.updateProfileShowcaseContactSocialLinks(socialLinkItems)

  let chainIds = self.controller.getChainIds()
  self.collectiblesController.setFilterAddressesAndChains(accountAddresses, chainIds)

method fetchProfileShowcaseAccountsByAddress*(self: Module, address: string) =
  self.controller.fetchProfileShowcaseAccountsByAddress(address)

method onProfileShowcaseAccountsByAddressFetched*(self: Module, accounts: seq[ProfileShowcaseAccount]) =
  let jsonObj = % accounts
  self.view.emitProfileShowcaseAccountsByAddressFetchedSignal($jsonObj)

method getShowcaseCollectiblesModel*(self: Module): QVariant =
  return self.collectiblesController.getModelAsVariant()
