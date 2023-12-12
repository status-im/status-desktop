import NimQml, Tables
import emoji_reactions_item

type
    ModelRole {.pure.} = enum
        EmojiId = UserRole + 1
        Filename
        DidIReactWithThisEmoji

QtObject:
    type Model* = ref object of QAbstractListModel
        items: seq[EmojiReactionItem]

    proc delete(self: Model) =
        self.items = @[]
        self.QAbstractListModel.delete

    # TODO : To make this code scale, we can consider a loop similar to
    # below code, and rename emoji to just be emojiReactions/emoji_[1 ... n]
    #
    # ```nim 
    #   for i in 1..itemCount:
    #       items.add(initItem(i, "emojiReactions/emoji_$(i)", false))
    # ```
    proc setup(self: Model) =
        self.items = @[
            initItem(1, "emojiReactions/heart",      false),
            initItem(2, "emojiReactions/thumbsUp",   false),
            initItem(3, "emojiReactions/thumbsDown", false),
            initItem(4, "emojiReactions/laughing",   false),
            initItem(5, "emojiReactions/sad",        false),
            initItem(6, "emojiReactions/angry",      false),
        ]
        self.QAbstractListModel.setup

    proc newEmojiReactionsModel*(): Model =
        new(result, delete)
        result.setup

    proc newModel*(): Model =
        new(result, delete)
        result.setup

    proc countChanged(self: Model) {.signal.}

    proc getCount*(self: Model): int {.slot.} =
        self.items.len

    QtProperty[int] count:
        read = getCount
        notify = countChanged

    method rowCount(self: Model, index: QModelIndex = nil): int =
        return self.items.len

    method roleNames(self: Model): Table[int, string] =
        {
            ModelRole.EmojiId.int: "emojiId",
            ModelRole.Filename.int: "filename",
            ModelRole.DidIReactWithThisEmoji.int: "didIReactWithThisEmoji"
        }.toTable

    method data(self: Model, index: QModelIndex, role: int): QVariant =
        if not index.isValid:
            return
        if index.row < 0 or index.row >= self.items.len:
            return

        let item = self.items[index.row]
        let enumRole = role.ModelRole

        case enumRole:
            of ModelRole.EmojiId: result = newQVariant(item.emojiId)
            of ModelRole.Filename: result = newQVariant(item.filename)
            of ModelRole.DidIReactWithThisEmoji: result = newQVariant(item.didIReactWithThisEmoji)

    proc setItems*(self: Model, items: seq[EmojiReactionItem]) =
        self.beginResetModel()
        self.items = items
        self.endResetModel()

    proc setItemDidIReactWithThisEmoji*(self: Model, emojiId: int, didIReactWithThisEmoji: bool) =
        if self.items.len > 0:
            self.items[emojiId - 1].didIReactWithThisEmoji = didIReactWithThisEmoji