import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.13

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import utils 1.0

BackupSeedStepBase {
    id: root

    property var seedPhrase: []
    property bool hideSeed: true

    titleText: qsTr("Write down your 12-word seed phrase to keep offline")

    Item {
        implicitHeight: 304
        Layout.fillWidth: true

        GridView {
            id: grid
            anchors.fill: parent
            visible: !hideSeed
            flow: GridView.FlowTopToBottom
            cellWidth: 208
            cellHeight: 48
            interactive: false
            model: 12
            property var wordIndex: ["1", "3", "5", "7", "9", "11", "2", "4", "6", "8", "10", "12"]
            delegate: StatusSeedPhraseInput {
                id: seedWordInput
                width: (grid.cellWidth - 4)
                height: (grid.cellHeight - 4)
                textEdit.input.edit.enabled: false
                text: {
                    var index = parseInt(leftComponentText) - 1;
                    if (!root.seedPhrase || index < 0 || index > root.seedPhrase.length - 1)
                        return "";
                    return root.seedPhrase[index];
                }
                leftComponentText: grid.wordIndex[index]
            }
        }

        GaussianBlur {
            id: blur
            anchors.fill: grid
            visible: hideSeed
            source: grid
            radius: 16
            samples: 16
        }

        StatusButton {
            anchors.centerIn: parent
            visible: hideSeed
            icon.name: "view"
            text: qsTr("Reveal seed phrase")
            onClicked: {
                hideSeed = false;
            }
        }
    }

    StyledText {
        id: text
        visible: hideSeed
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: Style.current.primaryTextFontSize
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        color: Theme.palette.dangerColor1
        text: qsTr("The next screen contains your seed phrase.\n<b>Anyone</b> who sees it can use it to access to your funds.")
        Layout.fillWidth: true
    }
}
