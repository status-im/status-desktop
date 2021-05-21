---
title : "Emojis Selector"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  dev:
    parent: "chat"
toc: true
---


## Choosing an emoji

key source file: [`ui/shared/status/emojiList.js`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/emojiList.js#L1)

key source file: [`ui/shared/status/StatusEmojiPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/StatusEmojiPopup.qml#L10)

key source file: [`ui/shared/status/StatusChatInput.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/StatusChatInput.qml#L656)

// TODO: emoji selection and how it gets inserted into the text input

## Searching for an Emojis

key source file: [`ui/shared/status/StatusEmojiSection.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/StatusEmojiSection.qml#L44)

key source file: [`ui/shared/status/StatusEmojiPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/StatusEmojiPopup.qml#L205)

Searching for an emoji filters the data source `modelData` and replaces the emojis array with the new filtered array.

## Categories

key source file: [`ui/shared/status/emojiList.js`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/emojiList.js#L1)

key source file: [`ui/shared/status/StatusEmojiCategoryButton.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/StatusEmojiCategoryButton.qml#L6)

key source file: [`ui/shared/status/StatusEmojiPopup.qml`](https://github.com/status-im/status-desktop/blob/65a0cfbcd30eb7bde4e24cdb1680b3e03d8b1992/ui/shared/status/StatusEmojiPopup.qml#L221)

## See also

Text Input Box
