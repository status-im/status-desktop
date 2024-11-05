import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0 as SharedPanels

Item {
    id: root

    property var sharedKeycardModule
    property alias seedPhraseRevealed: displaySeed.seedPhraseRevealed

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.xlPadding
        anchors.bottomMargin: Theme.halfPadding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding
        spacing: Theme.padding

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

        SharedPanels.SeedPhrase {
            id: displaySeed
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true

            seedPhrase: root.sharedKeycardModule.getMnemonic().split(" ")
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.seedPhraseDisplay
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay
            PropertyChanges {
                target: title
                text: qsTr("Write down your recovery phrase")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("The next screen contains your recovery phrase.<br/><b>Anyone</b> who sees it can use it to access to your funds.")
                font.pixelSize: Constants.keycard.general.fontSize2
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                color: Theme.palette.dangerColor1
            }
        }
    ]
}
