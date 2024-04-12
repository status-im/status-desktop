import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusAmountInput {
    id: cursorInput

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    placeholderText: ""
    input.edit.cursorVisible: true
    input.edit.font.pixelSize: Utils.getFontSizeBasedOnLetterCount(text)
    input.placeholderFont.pixelSize: 34
    input.edit.padding: 0
    input.background.color: "transparent"
    input.background.border.width: 0
}
