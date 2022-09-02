import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule
    property bool hideSeed: true

    signal seedPhraseRevealed()

    QtObject {
        id: d

        readonly property var seedPhrase: root.sharedKeycardModule.getMnemonic().split(" ")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding

        StatusBaseText {
            id: title
            Layout.preferredHeight: Constants.keycard.general.titleHeight
            Layout.alignment: Qt.AlignCenter
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: message
            Layout.preferredHeight: Constants.keycard.general.messageHeight
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true

            StatusGridView {
                id: grid
                anchors.fill: parent
                visible: !root.hideSeed
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
                        if (!d.seedPhrase || idx < 0 || idx > d.seedPhrase.length - 1)
                            return "";
                        return d.seedPhrase[idx];
                    }
                    leftComponentText: grid.wordIndex[index]
                }
            }

            GaussianBlur {
                id: blur
                anchors.fill: grid
                visible: root.hideSeed
                source: grid
                radius: 16
                samples: 16
                transparentBorder: true
            }

            StatusButton {
                anchors.centerIn: parent
                visible: root.hideSeed
                type: StatusBaseButton.Type.Primary
                icon.name: "view"
                text: qsTr("Reveal seed phrase")
                onClicked: {
                    root.hideSeed = false;
                    root.seedPhraseRevealed()
                }
            }
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.seedPhraseDisplay
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay
            PropertyChanges {
                target: title
                text: qsTr("Write down your seed phrase")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("The next screen contains your seed phrase.<br/><b>Anyone</b> who sees it can use it to access to your funds.")
                font.pixelSize: Constants.keycard.general.fontSize2
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                color: Theme.palette.dangerColor1
            }
        }
    ]
}
