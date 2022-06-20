import QtQuick 2.12
import StatusQ.Controls 0.1
import QtGraphicalEffects 1.13
import StatusQ.Core.Theme 0.1

import shared.panels 1.0
import utils 1.0

BackupSeedStepBase {
    id: root
    property var seedPhrase
    property bool hideSeed: true

    titleText: qsTr("Write down your 12-word seed phrase to keep offline")

    GridView {
        id: grid
        width: parent.width
        height: Style.dp(304)
        anchors.left: parent.left
        anchors.leftMargin: Style.dp(2)
        anchors.top: parent.top
        anchors.topMargin: Style.dp(88)
        flow: GridView.FlowTopToBottom
        cellWidth: Style.dp(208)
        cellHeight: Style.dp(48)
        interactive: false
        model: 12
        property var wordIndex: ["1", "3", "5", "7", "9", "11", "2", "4", "6", "8", "10", "12"]
        delegate: StatusSeedPhraseInput {
            id: seedWordInput
            width: (grid.cellWidth - Style.dp(4))
            height: (grid.cellHeight - Style.dp(4))
            textEdit.input.edit.enabled: false
            text: root.seedPhrase[parseInt(leftComponentText)-1]
            leftComponentText: grid.wordIndex[index]
        }
    }

    GaussianBlur {
        id: blur
        anchors.fill: grid
        visible: hideSeed
        source: grid
        radius: Style.dp(16)
        samples: 16
    }

    StatusButton {
        anchors.centerIn: grid
        visible: hideSeed
        icon.name: "view"
        text: qsTr("Reveal seed phrase")
        onClicked: {
            hideSeed = false;
        }
    }

    StyledText {
        id: text
        anchors.left: parent.left
        //anchors.leftMargin: Style.current.bigPadding
        anchors.right: parent.right
        //anchors.rightMargin: Style.current.bigPadding
        anchors.top: grid.bottom
        anchors.topMargin: Style.dp(36)
        visible: hideSeed
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: Style.current.primaryTextFontSize
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        color: Theme.palette.dangerColor1
        text: qsTr("The next screen contains your seed phrase.\n<b>Anyone</b> who sees it can use it to access to your funds.")
    }
}
