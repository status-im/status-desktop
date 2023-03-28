import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property var seedPhrase: []
    property bool seedPhraseRevealed: false

    StatusGridView {
        id: grid
        anchors.fill: parent
        visible: root.seedPhraseRevealed
        cellWidth: parent.width * 0.5
        cellHeight: 48
        interactive: false
        model: 12
        readonly property var wordIndex: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        readonly property int spacing: 4
        delegate: StatusSeedPhraseInput {
            width: (grid.cellWidth - grid.spacing)
            height: (grid.cellHeight - grid.spacing)
            textEdit.input.edit.enabled: false
            text: {
                const idx = parseInt(leftComponentText) - 1;
                if (!root.seedPhrase || idx < 0 || idx > root.seedPhrase.length - 1)
                    return "";
                return root.seedPhrase[idx];
            }
            leftComponentText: grid.wordIndex[index]
        }
    }

    GaussianBlur {
        id: blur
        anchors.fill: grid
        visible: !root.seedPhraseRevealed
        source: grid
        radius: 16
        samples: 16
        transparentBorder: true
    }

    StatusButton {
        anchors.centerIn: parent
        visible: !root.seedPhraseRevealed
        type: StatusBaseButton.Type.Primary
        icon.name: "view"
        text: qsTr("Reveal seed phrase")
        onClicked: {
            root.seedPhraseRevealed = true
        }
    }
}
