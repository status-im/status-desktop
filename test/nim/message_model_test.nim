import unittest

import ../../../src/app_service/common/types
import ../../../src/app_service/service/contacts/dto/contacts
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
    amISender = false,
    senderIsAdded = false,
    outgoingStatus = "",
    text = "",
    image = "",
    messageContainsMentions = false,
    seen = true,
    timestamp = 0,
    clock = clock,
    ContentType.NewMessagesMarker,
    messageType = -1,
    contactRequestState = 0,
    sticker = "",
    stickerPack = -1,
    links = @[],
    transactionParameters = newTransactionParametersItem("","","","","","",-1,""),
    mentionedUsersPks = @[],
    senderTrustStatus = TrustStatus.Unknown,
    senderEnsVerified = false,
    discordMessage = DiscordMessage(),
    resendError = ""
  )

let message1 = createTestMessageItem("0xa", 1)
let message2 = createTestMessageItem("0xb", 2)
let message3 = createTestMessageItem("0xc", 3)
let message4 = createTestMessageItem("0xd", 3)
let message5 = createTestMessageItem("0xe", 4)

template checkOrder(model: Model) =
  require(model.items.len == 5)
  check(model.items[0].id == message5.id)
  check(model.items[1].id == message4.id)
  check(model.items[2].id == message3.id)
  check(model.items[3].id == message2.id)
  check(model.items[4].id == message1.id)

suite "empty model":
  let model = newModel()

  test "initial size":
    require(model.rowCount() == 0)

# newest messages should be first, break ties by message id
suite "inserting new messages":
  setup:
    let model = newModel()

  test "insert same message twice":
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 1)
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 1)

  test "insert in order":
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 1)
    model.insertItemBasedOnClock(message2)
    check(model.rowCount() == 2)
    model.insertItemBasedOnClock(message3)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message4)
    check(model.rowCount() == 4)
    model.insertItemBasedOnClock(message5)
    check(model.rowCount() == 5)
    checkOrder(model)

  test "insert out of order":
    model.insertItemBasedOnClock(message5)
    check(model.rowCount() == 1)
    model.insertItemBasedOnClock(message4)
    check(model.rowCount() == 2)
    model.insertItemBasedOnClock(message3)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message2)
    check(model.rowCount() == 4)
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 5)
    checkOrder(model)

  test "insert out of order (randomly)":
    model.insertItemBasedOnClock(message3)
    check(model.rowCount() == 1)
    model.insertItemBasedOnClock(message1)
    check(model.rowCount() == 2)
    model.insertItemBasedOnClock(message4)
    check(model.rowCount() == 3)
    model.insertItemBasedOnClock(message2)
    check(model.rowCount() == 4)
    model.insertItemBasedOnClock(message5)
    check(model.rowCount() == 5)
    checkOrder(model)

# assumption: each append sequence is already sorted
suite "appending new messages":
  setup:
    let model = newModel()

  test "append empty model":
    model.appendItems(@[message5,
                        message4,
                        message3,
                        message2,
                        message1])
    checkOrder(model)

  test "append to model with only newer messages":
    model.insertItemBasedOnClock(message5)
    model.insertItemBasedOnClock(message4)
    model.appendItems(@[message3,
                        message2,
                        message1])
    checkOrder(model)

  test "append to model with newer and older messages":
    model.insertItemBasedOnClock(message5)
    model.insertItemBasedOnClock(message1)
    model.appendItems(@[message4,
                        message3,
                        message2])
    checkOrder(model)

  test "append to model with newer and older messages and some in between":
    model.insertItemBasedOnClock(message5)
    model.insertItemBasedOnClock(message1)
    model.insertItemBasedOnClock(message3) # in between
    model.appendItems(@[message4,
                        message2])
    checkOrder(model)
