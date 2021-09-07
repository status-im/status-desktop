import NimQml, Tables, json, strutils, chronicles, json_serialization

import result_model, result_item, location_menu_model, location_menu_item, location_menu_sub_item
import constants as sr_constants

import ../../../../status/[status]
import ../../../../status/chat/[chat]
import ../../../../status/types/[message, setting]
import ../../../../status/libstatus/[settings]
import ../../../../app_service/[main]
import ../communities
import ../channel
import ../chat_item
import ../channels_list
import ../community_list

logScope:
  topics = "search-messages-view-controller"

type ResultItemInfo = object
  communityId*: string
  channelId*: string
  messageId*: string

method isEmpty*(self: ResultItemInfo): bool {.base.} =
  self.communityId.len == 0 and 
  self.channelId.len == 0 and 
  self.messageId.len == 0

QtObject:
  type MessageSearchViewController* = ref object of QObject
    status: Status
    appService: AppService
    channelView: ChannelView
    communitiesView: CommunitiesView
    resultItems: Table[string, ResultItemInfo] # [resuiltItemId, ResultItemInfo]

    messageSearchResultModel: MessageSearchResultModel 
    messageSearchLocationMenuModel: MessageSearchLocationMenuModel
    meassgeSearchTerm: string
    meassgeSearchLocation: string
    meassgeSearchSubLocation: string

  proc setup(self: MessageSearchViewController) = 
    self.QObject.setup

  proc delete*(self: MessageSearchViewController) =
    self.messageSearchResultModel.delete
    self.messageSearchLocationMenuModel.delete
    self.resultItems.clear
    self.QObject.delete    

  proc newMessageSearchViewController*(status: Status, appService: AppService, 
    channelView: ChannelView, communitiesView: CommunitiesView): 
    MessageSearchViewController =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.channelView = channelView
    result.communitiesView = communitiesView
    result.resultItems = initTable[string, ResultItemInfo]()
    result.messageSearchResultModel = newMessageSearchResultModel()
    result.messageSearchLocationMenuModel = newMessageSearchLocationMenuModel()
    result.setup

  proc getMessageSearchResultModel*(self: MessageSearchViewController): 
    QVariant {.slot.} = 
    newQVariant(self.messageSearchResultModel)

  QtProperty[QVariant] resultModel:
    read = getMessageSearchResultModel

  proc getMessageSearchLocationMenuModel*(self: MessageSearchViewController): 
    QVariant {.slot.} = 
    newQVariant(self.messageSearchLocationMenuModel)

  QtProperty[QVariant] locationMenuModel:
    read = getMessageSearchLocationMenuModel

  proc getSearchLocationObject*(self: MessageSearchViewController): string {.slot.} = 
    ## This method returns location and subLocation with their details so we
    ## may set initial search location on the side of qml.
    var found = false
    let subItem = self.messageSearchLocationMenuModel.getLocationSubItemForChatId(
        self.channelView.activeChannel.id, found
      )

    var jsonObject = %* {
      "location": "", 
      "subLocation": ""
    }

    if(found):
      jsonObject["subLocation"] = subItem.toJsonNode() 

    if(self.channelView.activeChannel.communityId.len == 0):
      jsonObject["location"] = %* {
        "value":sr_constants.SEARCH_MENU_LOCATION_CHAT_SECTION_NAME,
        "title":sr_constants.SEARCH_MENU_LOCATION_CHAT_SECTION_NAME
      } 
    else:
      let item = self.messageSearchLocationMenuModel.getLocationItemForCommunityId(
        self.channelView.activeChannel.communityId, found
      )

      if(found):
        jsonObject["location"] = item.toJsonNode()

    result = Json.encode(jsonObject)
  
  proc prepareLocationMenuModel*(self: MessageSearchViewController)
    {.slot.} = 
    self.messageSearchLocationMenuModel.prepareLocationMenu(
      self.status,
      self.channelView.chats.chats, 
      self.communitiesView.joinedCommunityList.communities)

  proc setSearchLocation*(self: MessageSearchViewController, location: string = "", 
    subLocation: string = "") {.slot.} = 
    ## Setting location and subLocation to an empty string means we're 
    ## searching in all available chats/channels/communities.
    self.meassgeSearchLocation = location
    self.meassgeSearchSubLocation = subLocation

  proc searchMessages*(self: MessageSearchViewController, searchTerm: string) 
    {.slot.} =
    self.meassgeSearchTerm = searchTerm
    self.resultItems.clear

    if (self.meassgeSearchTerm.len == 0):
      self.messageSearchResultModel.clear()
      return

    var chats: seq[string]
    var communities: seq[string]

    if (self.meassgeSearchSubLocation.len > 0):
      chats.add(self.meassgeSearchSubLocation)
    elif (self.meassgeSearchLocation.len > 0):
      # If "Chat" is set for the meassgeSearchLocation that means we need to 
      # search in all chats from the chat section.
      if (self.meassgeSearchLocation != sr_constants.SEARCH_MENU_LOCATION_CHAT_SECTION_NAME):
        communities.add(self.meassgeSearchLocation)
      else:
        for c in self.channelView.chats.chats:
          chats.add(c.id)

    if (communities.len == 0 and chats.len == 0):
      for c in self.channelView.chats.chats:
        chats.add(c.id)

      for co in self.communitiesView.joinedCommunityList.communities:
        communities.add(co.id)

    self.appService.chatService.asyncSearchMessages(communities, chats, 
      self.meassgeSearchTerm, false)

  proc onSearchMessagesLoaded*(self: MessageSearchViewController, 
    messages: seq[Message]) =
    
    self.resultItems.clear

    var items: seq[SearchResultItem]
    var channels: seq[SearchResultItem]
    let myPublicKey = getSetting[string](Setting.PublicKey, "0x0")

    # Add communities
    for co in self.communitiesView.joinedCommunityList.communities:
      if(self.meassgeSearchLocation.len == 0 and
        co.name.toLower.startsWith(self.meassgeSearchTerm.toLower)):
        let item = initSearchResultItem(co.id, "", "", co.id, co.name, 
          sr_constants.SEARCH_RESULT_COMMUNITIES_SECTION_NAME, 
          co.communityImage.thumbnail, co.communityColor, "", "", 
          co.communityImage.thumbnail, co.communityColor)

        self.resultItems.add(co.id, ResultItemInfo(communityId: co.id))
        items.add(item)

      # Add channels
      if(self.meassgeSearchSubLocation.len == 0 and 
        self.meassgeSearchLocation.len == 0 or
        self.meassgeSearchLocation == co.name):
        for c in co.chats:
          let chatName = self.status.chat.chatName(c)
          var chatNameRaw = chatName
          if(chatName.startsWith("@")):
            chatNameRaw = chatName[1 ..^ 1]

          if(chatNameRaw.toLower.startsWith(self.meassgeSearchTerm.toLower)):
            let item = initSearchResultItem(c.id, "", "", c.id, chatName, 
            sr_constants.SEARCH_RESULT_CHANNELS_SECTION_NAME, 
            c.identicon, c.color, "", "", c.identicon, c.color, 
            c.identicon.len > 0)

            self.resultItems.add(c.id, ResultItemInfo(communityId: co.id, 
            channelId: c.id))
            channels.add(item)

    # Add chats
    if(self.meassgeSearchLocation.len == 0 or 
      self.meassgeSearchLocation == sr_constants.SEARCH_RESULT_CHATS_SECTION_NAME):
      for c in self.channelView.chats.chats:
        let chatName = self.status.chat.chatName(c)
        var chatNameRaw = chatName
        if(chatName.startsWith("@")):
          chatNameRaw = chatName[1 ..^ 1]

        if(chatNameRaw.toLower.startsWith(self.meassgeSearchTerm.toLower)):
          let item = initSearchResultItem(c.id, "", "", c.id, chatName, 
          sr_constants.SEARCH_RESULT_CHATS_SECTION_NAME, c.identicon, c.color,
          "", "", c.identicon, c.color, c.identicon.len > 0)

          self.resultItems.add(c.id, ResultItemInfo(communityId: "", 
            channelId: c.id))
          items.add(item)

    # Add channels in order as requested by design
    items.add(channels)

    # Add messages
    for m in messages:
      if (m.contentType != ContentType.Message):
        continue

      var found = false
      var chat = self.channelView.chats.getChannelById(m.chatId, found)
      let image = if(m.image.len > 0): m.image else: m.identicon
      if (found):
        var channel = self.status.chat.chatName(chat)
        if (channel.endsWith(".stateofus.eth")):
          channel = channel[0 .. ^15]

        var alias = self.status.chat.userNameOrAlias(m.fromAuthor, true)
        if (myPublicKey == m.fromAuthor):
          alias = "You"

        let item = initSearchResultItem(m.id, m.text, m.timestamp, m.fromAuthor,
        alias, sr_constants.SEARCH_RESULT_MESSAGES_SECTION_NAME, image, "",
        channel, "", chat.identicon, chat.color, chat.identicon.len == 0)

        self.resultItems.add(m.id, ResultItemInfo(communityId: "", 
            channelId: chat.id, messageId: m.id))
        items.add(item)
      else:
        var community: Community 
        if (self.communitiesView.joinedCommunityList.
          getChannelByIdAndBelongingCommunity(m.chatId, chat, community)):
          
          var channel = self.status.chat.chatName(chat)
          if (not channel.startsWith("#")):
            channel = "#" & channel
          if (channel.endsWith(".stateofus.eth")):
            channel = channel[0 .. ^15]

          var alias = self.status.chat.userNameOrAlias(m.fromAuthor, true)
          if (myPublicKey == m.fromAuthor):
            alias = "You"

          let item = initSearchResultItem(m.id, m.text, m.timestamp, m.fromAuthor,
          m.alias, sr_constants.SEARCH_RESULT_MESSAGES_SECTION_NAME, image, "",
          community.name, channel, community.communityImage.thumbnail,
          community.communityColor, community.communityImage.thumbnail.len == 0)

          self.resultItems.add(m.id, ResultItemInfo(communityId: community.id, 
            channelId: chat.id, messageId: m.id))
          items.add(item)

    self.messageSearchResultModel.set(items)

  proc getItemInfo*(self: MessageSearchViewController, itemId: string): 
    ResultItemInfo = 
    self.resultItems.getOrDefault(itemId)
