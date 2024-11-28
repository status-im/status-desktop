import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.panels 1.0

OnboardingPage {
    id: root

    property string subtitle

    property var isSeedPhraseValid: (mnemonic) => { console.error("isSeedPhraseValid IMPLEMENT ME"); return false }

    signal seedphraseValidated()

    pageClassName: "SeedphrasePage"

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(600, root.availableWidth)
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: -Theme.bigPadding
                text: root.subtitle
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            EnterSeedPhrase {
                id: seedPanel
                Layout.preferredWidth: 580
                isSeedPhraseValid: root.isSeedPhraseValid
                onSubmitSeedPhrase: root.seedphraseValidated()
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                enabled: seedPanel.seedPhraseIsValid
                text: qsTr("Continue")
                onClicked: root.seedphraseValidated()
            }
        }
    }
}
