import unittest

import app/modules/main/chat_section/[model, Item]

import app_service/common/types

proc createTestChatItem(id: string, catId: string = "", isCategory: bool = false): ChatItem =
  discard
  return initChatItem(
      id = id,
      name = "",
      icon = "",
      color = "",
      emoji = "",
      description = "",
      `type` = if isCategory: CATEGORY_TYPE else: 0,
      memberRole = MemberRole.None,
      lastMessageTimestamp = 0,
      hasUnreadMessages = false,
      notificationsCount = 0,
      muted = false,
      blocked = false,
      active = false,
      position = 0,
      categoryId = catId,
    )

let chatA = createTestChatItem("0xa")
let chatB = createTestChatItem("0xb")
let chatC = createTestChatItem("0xc", catId = "0xcatA")
let catA = createTestChatItem("0xcatA", catId = "0xcatA", isCategory = true)

suite "empty member model":
  let model = newModel()

  test "initial size":
    require(model.rowCount() == 0)

suite "updating chat items":
  setup:
    let model = newModel()
    model.setData(@[chatA, catA, chatB])
    check(model.rowCount() == 3)

  test "update can post values":
    # Call with the same values, so nothing should change
    var updatedRoles = model.changeCanPostValues(
        id = "0xa",
        canPost = true,
        canView = true,
        canPostReactions = true,
        viewersCanPostReactions = true,
      )
    check(updatedRoles.len() == 0)

    # Call with two updated value
    updatedRoles = model.changeCanPostValues(
        id = "0xa",
        canPost = false,
        canView = false,
        canPostReactions = true,
        viewersCanPostReactions = true,
      )
    # Four roles should be updated because there are collateral updates
    check(updatedRoles.len() == 4)

    let item = model.getItemById("0xa")
    check(item.canPost == false)
    check(item.canView == false)

  test "update item details by id":
    # Don't touch hideIfPermissionsNotMet
    var updatedRoles = model.updateItemDetailsById(
        id = "0xa",
        name = "Chat A",
        description = "Desc A",
        emoji = "emojiA",
        color = "#FF0000",
        hideIfPermissionsNotMet = false,
      )
    check(updatedRoles.len() == 4)

    # Only update hideIfPermissionsNotMet
    updatedRoles = model.updateItemDetailsById(
        id = "0xa",
        name = "Chat A",
        description = "Desc A",
        emoji = "emojiA",
        color = "#FF0000",
        hideIfPermissionsNotMet = true,
      )
    # Two roles because hideIfPermissionsNotMet has a collateral role update
    check(updatedRoles.len() == 2)

  test "append a chat to category and change the opened state":
    # Append a chat to a category
    model.appendItem(chatC)
    check(model.rowCount() == 4)

    # Check if the chat is now under the category
    let index = model.getItemIdxById("0xc")
    # Index is 2 because the category is at index 1 and the chat is appended after it
    check(index == 2)

    # Check that the category is opened at the start
    var cat = model.getItemById("0xcatA")
    check(cat.categoryOpened == true)

    # Change the category's opened state to false, it will affect the chat as well
    model.changeCategoryOpened("0xcatA", false)
    cat = model.getItemById("0xcatA")
    check(cat.categoryOpened == false)
    let chat = model.getItemById("0xc")
    check(chat.categoryOpened == false)
