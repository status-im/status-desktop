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

    title: qsTr("Create profile using a recovery phrase")
    property string subtitle: qsTr("Enter your 12, 18 or 24 word recovery phrase")

    property var isSeedPhraseValid: (mnemonic) => { console.error("isSeedPhraseValid IMPLEMENT ME"); return false }

    signal seedphraseSubmitted(string seedphrase)

    pageClassName: "SeedphrasePage"

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(610, root.availableWidth)
            spacing: Theme.bigPadding

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
                Layout.topMargin: -Theme.padding
                text: root.subtitle
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            EnterSeedPhrase {
                id: seedPanel
                Layout.preferredWidth: 580
                Layout.alignment: Qt.AlignHCenter
                isSeedPhraseValid: root.isSeedPhraseValid
                onSubmitSeedPhrase: root.seedphraseSubmitted(getSeedPhraseAsString())
            }

            StatusButton {
                objectName: "btnContinue"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -Theme.halfPadding
                enabled: seedPanel.seedPhraseIsValid
                text: qsTr("Continue")
                onClicked: root.seedphraseSubmitted(seedPanel.getSeedPhraseAsString())
            }
        }
    }
}
