import NimQml, chronicles, sequtils, json
import ../../../status/status
import chat_item

logScope:
  topics = "groups-view"

QtObject:
  type GroupsView* = ref object of QObject
    activeChannel: ChatItemView
    status: Status

  proc setup(self: GroupsView) =
    self.QObject.setup

  proc delete*(self: GroupsView) =
    self.QObject.delete

  proc newGroupsView*(status: Status, activeChannel: ChatItemView): GroupsView =
    new(result, delete)
    result = GroupsView()
    result.status = status
    result.activeChannel = activeChannel
    result.setup

  proc groupJoined(self: GroupsView, channel: string) {.signal.}

  proc join*(self: GroupsView) {.slot.} =
    self.status.chat.confirmJoiningGroup(self.activeChannel.id)
    self.activeChannel.membershipChanged()
    self.groupJoined(self.activeChannel.id)

  proc rename*(self: GroupsView, newName: string) {.slot.} =
    self.status.chat.renameGroup(self.activeChannel.id, newName)

  proc create*(self: GroupsView, groupName: string, pubKeys: string) {.slot.} =
    let pubKeysSeq = map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)
    self.status.chat.createGroup(groupName, pubKeysSeq)

  proc addMembers*(self: GroupsView, chatId: string, pubKeys: string) {.slot.} =
    let pubKeysSeq = map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)
    self.status.chat.addGroupMembers(chatId, pubKeysSeq)

  proc kickMember*(self: GroupsView, chatId: string, pubKey: string) {.slot.} =
    self.status.chat.kickGroupMember(chatId, pubKey)

  proc makeAdmin*(self: GroupsView, chatId: string, pubKey: string) {.slot.} =
    self.status.chat.makeAdmin(chatId, pubKey)
