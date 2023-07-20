import unittest

import ../../../src/app_service/common/types
import ../../../src/app_service/service/contacts/dto/contact_details
import ../../../src/app_service/service/message/dto/message

import ../../../src/app/modules/shared_models/message_model
import ../../../src/app/modules/shared_models/message_item
import ../../../src/app/modules/shared_models/message_transaction_parameters_item

proc createTestMessageItem(id: string, clock: int64): Item =
  return initItem(
    id = id,
    communityId = "",
    responseToMessageWithId = "",
    senderId = "",
    senderDisplayName = "",
    senderOptionalName = "",
    senderIcon = "",
    senderColorHash = "",
    amISender = false,
    senderIsAdded = false,
    outgoingStatus = "",
    text = "",
    unparsedText = "",
    parsedText = @[],
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = 0,
    clock = clock,
    contentType = ContentType.Unknown,
    messageType = -1,
    contactRequestState = 0,
    sticker = "",
    stickerPack = -1,
    links = @[],
    linkPreviews = @[],
    transactionParameters = newTransactionParametersItem("","","","","","",-1,""),
    mentionedUsersPks = @[],
    senderTrustStatus = TrustStatus.Unknown,
    senderEnsVerified = false,
    discordMessage = DiscordMessage(),
    resendError = "",
    mentioned = false,
    quotedMessageFrom = "",
    quotedMessageText = "",
    quotedMessageParsedText = "",
    quotedMessageContentType = ContentType.Unknown,
    quotedMessageDeleted = false,
    quotedMessageDiscordMessage = DiscordMessage(),
    quotedMessageAuthorDetails = ContactDetails(),
    albumId = "",
    albumMessageImages = @[],
    albumMessageIds = @[],
    albumImagesCount = 0,
  )

let message0_chatIdentifier = createTestMessageItem("chat-identifier", -2)
let message0_fetchMoreMessages = createTestMessageItem("fetch-more-messages", -1)
let message1 = createTestMessageItem("0xa", 1)
let message2 = createTestMessageItem("0xb", 2)
let message3 = createTestMessageItem("0xc", 3)
let message4 = createTestMessageItem("0xd", 3)
let message5 = createTestMessageItem("0xe", 4)

template checkOrder(model: Model) =
  require(model.items.len == 7)
  check(model.items[0].id == message5.id)
  check(model.items[1].id == message4.id)
  check(model.items[2].id == message3.id)
  check(model.items[3].id == message2.id)
  check(model.items[4].id == message1.id)
  check(model.items[5].id == message0_fetchMoreMessages.id)
  check(model.items[6].id == message0_chatIdentifier.id)

suite "empty model":
  let model = newModel()

  test "initial size":
    require(model.rowCount() == 0)

# newest messages should be first, break ties by message id
suite "inserting new messages":
  setup:
    let model = newModel()
    model.insertItemsBasedOnClock(@[message0_fetchMoreMessages, message0_chatIdentifier])

  test "insert same message twice":
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 3)

  test "insert in order":
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message2)
    check(model.rowCount() == 4)
    model.insertItemBasedOnClock(message3)
    check(model.rowCount() == 5)
    model.insertItemBasedOnClock(message4)
    check(model.rowCount() == 6)
    model.insertItemBasedOnClock(message5)
    check(model.rowCount() == 7)
    checkOrder(model)

  test "insert out of order":
    model.insertItemBasedOnClock(message5)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message4)
    check(model.rowCount() == 4)
    model.insertItemBasedOnClock(message3)
    check(model.rowCount() == 5)
    model.insertItemBasedOnClock(message2)
    check(model.rowCount() == 6)
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 7)
    checkOrder(model)

  test "insert out of order (randomly)":
    model.insertItemBasedOnClock(message3)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 4)
    model.insertItemBasedOnClock(message4)
    check(model.rowCount() == 5)
    model.insertItemBasedOnClock(message2)
    check(model.rowCount() == 6)
    model.insertItemBasedOnClock(message5)
    check(model.rowCount() == 7)
    checkOrder(model)

suite "inserting multiple new messages":
  setup:
    let model = newModel()
    model.insertItemsBasedOnClock(@[message0_fetchMoreMessages, message0_chatIdentifier])

  test "insert to empty model":
    model.insertItemsBasedOnClock(@[message5,
                                    message4,
                                    message3,
                                    message2,
                                    message1])
    checkOrder(model)

  test "insert to model with only newer messages":
    model.insertItemBasedOnClock(message5)
    model.insertItemBasedOnClock(message4)
    model.insertItemsBasedOnClock(@[message3,
                                    message2,
                                    message1])
    checkOrder(model)

  test "insert to model with only older messages":
    model.insertItemBasedOnClock(message2)
    model.insertItemBasedOnClock(message1)
    model.insertItemsBasedOnClock(@[message5,
                                    message4,
                                    message3])
    checkOrder(model)

  test "insert to model with newer and older messages":
    model.insertItemBasedOnClock(message5)
    model.insertItemBasedOnClock(message1)
    model.insertItemsBasedOnClock(@[message4,
                                    message3,
                                    message2])
    checkOrder(model)

  test "insert to model with newer and older messages and some in between":
    model.insertItemBasedOnClock(message5)
    model.insertItemBasedOnClock(message1)
    model.insertItemBasedOnClock(message3) # in between
    model.insertItemsBasedOnClock(@[message4,
                                    message2])
    checkOrder(model)

suite "new messages marker":
  setup:
    let model = newModel()
    model.insertItemsBasedOnClock(@[message0_fetchMoreMessages, message0_chatIdentifier])

  test "set new messages marker":
    model.insertItemsBasedOnClock(@[message1,
                                    message2])
    require(model.items.len == 4)

    # add new messages marker
    model.setFirstUnseenMessageId(message2.id)
    model.resetNewMessagesMarker()

    require(model.items.len == 5)
    check(model.items[0].id == message2.id)
    check(model.items[1].contentType == ContentType.NewMessagesMarker)
    check(model.items[2].id == message1.id)
    check(model.items[3].id == message0_fetchMoreMessages.id)
    check(model.items[4].id == message0_chatIdentifier.id)

  test "remove new messages marker":
    model.insertItemsBasedOnClock(@[message1,
                                    message2])
    require(model.items.len == 4)

    # add new messages marker
    model.setFirstUnseenMessageId(message2.id)
    model.resetNewMessagesMarker()
    require(model.items.len == 5)

    # remove new messages marker
    model.setFirstUnseenMessageId("")
    model.resetNewMessagesMarker()
    require(model.items.len == 4)
    check(model.items[0].id == message2.id)
    check(model.items[1].id == message1.id)
    check(model.items[2].id == message0_fetchMoreMessages.id)
    check(model.items[3].id == message0_chatIdentifier.id)

suite "simulations":
  setup:
    let model = newModel()
    model.insertItemsBasedOnClock(@[message0_fetchMoreMessages, message0_chatIdentifier])

  test "simulate messages loading":
    # load first two messages
    var loadedMessages: seq[Item]
    loadedMessages.add(message5)
    loadedMessages.add(message4)
    model.removeItem(message0_fetchMoreMessages.id)
    model.removeItem(message0_chatIdentifier.id)
    loadedMessages.add(message0_fetchMoreMessages)
    loadedMessages.add(message0_chatIdentifier)
    model.insertItemsBasedOnClock(loadedMessages)

    require(model.items.len == 4)
    check(model.items[0].id == message5.id)
    check(model.items[1].id == message4.id)
    check(model.items[2].id == message0_fetchMoreMessages.id)
    check(model.items[3].id == message0_chatIdentifier.id)

    # set new messages marker
    model.setFirstUnseenMessageId(message5.id)
    model.resetNewMessagesMarker()

    require(model.items.len == 5)
    check(model.items[0].id == message5.id)
    check(model.items[1].contentType == ContentType.NewMessagesMarker)
    check(model.items[2].id == message4.id)
    check(model.items[3].id == message0_fetchMoreMessages.id)
    check(model.items[4].id == message0_chatIdentifier.id)

    # load next two messages
    loadedMessages = @[]
    loadedMessages.add(message3)
    loadedMessages.add(message2)
    model.removeItem(message0_fetchMoreMessages.id)
    model.removeItem(message0_chatIdentifier.id)
    loadedMessages.add(message0_fetchMoreMessages)
    loadedMessages.add(message0_chatIdentifier)
    model.insertItemsBasedOnClock(loadedMessages)

    require(model.items.len == 7)
    check(model.items[0].id == message5.id)
    check(model.items[1].contentType == ContentType.NewMessagesMarker)
    check(model.items[2].id == message4.id)
    check(model.items[3].id == message3.id)
    check(model.items[4].id == message2.id)
    check(model.items[5].id == message0_fetchMoreMessages.id)
    check(model.items[6].id == message0_chatIdentifier.id)

    # load last message
    loadedMessages = @[]
    loadedMessages.add(message1)
    model.removeItem(message0_fetchMoreMessages.id)
    model.removeItem(message0_chatIdentifier.id)
    loadedMessages.add(message0_fetchMoreMessages)
    loadedMessages.add(message0_chatIdentifier)
    model.insertItemsBasedOnClock(loadedMessages)

    require(model.items.len == 8)
    check(model.items[0].id == message5.id)
    check(model.items[1].contentType == ContentType.NewMessagesMarker)
    check(model.items[2].id == message4.id)
    check(model.items[3].id == message3.id)
    check(model.items[4].id == message2.id)
    check(model.items[5].id == message1.id)
    check(model.items[6].id == message0_fetchMoreMessages.id)
    check(model.items[7].id == message0_chatIdentifier.id)

  test "simulate chat identifier update":
    model.insertItemsBasedOnClock(@[message5,
                                    message4,
                                    message3,
                                    message2,
                                    message1])
    checkOrder(model)

    # set new messages marker
    model.setFirstUnseenMessageId(message4.id)
    model.resetNewMessagesMarker()

    # update chat identifier
    model.removeItem(message0_chatIdentifier.id)
    model.insertItemBasedOnClock(message0_chatIdentifier)

    require(model.items.len == 8)
    check(model.items[0].id == message5.id)
    check(model.items[1].id == message4.id)
    check(model.items[2].contentType == ContentType.NewMessagesMarker)
    check(model.items[3].id == message3.id)
    check(model.items[4].id == message2.id)
    check(model.items[5].id == message1.id)
    check(model.items[6].id == message0_fetchMoreMessages.id)
    check(model.items[7].id == message0_chatIdentifier.id)


suite "mark as seen":
  setup:
    let model = newModel()

    var msg1 = createTestMessageItem("0xa", 1)
    msg1.seen=false
    let msg2 = createTestMessageItem("0xb", 2)
    msg2.seen=false
    let msg3 = createTestMessageItem("0xc", 3)
    msg3.seen=true

    model.insertItemsBasedOnClock(@[msg1, msg2, msg3])
    require(model.items.len == 3)
    check(model.items[0].seen == true)
    check(model.items[1].seen == false)
    check(model.items[2].seen == false)

  test "mark all as seen":
    model.markAllAsSeen()
    check(model.items[0].seen == true)
    check(model.items[1].seen == true)
    check(model.items[2].seen == true)

  test "mark some as seen":
    model.markAsSeen(@["0xa"])
    check(model.items[0].seen == true)
    check(model.items[1].seen == false)
    check(model.items[2].seen == true)

    model.markAsSeen(@["0xb"])
    check(model.items[0].seen == true)
    check(model.items[1].seen == true)
    check(model.items[2].seen == true)
