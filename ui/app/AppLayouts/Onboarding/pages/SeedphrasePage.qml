import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Onboarding.enums

import shared
import shared.panels

OnboardingPage {
    id: root

    title: qsTr("Create profile using a recovery phrase")
    property string subtitle: qsTr("Enter your 12, 18 or 24 word recovery phrase")
    property alias btnContinueText: btnContinue.text

    property var isSeedPhraseValid: (mnemonic) => { console.error("isSeedPhraseValid IMPLEMENT ME"); return false }

    signal seedphraseSubmitted(string seedphrase)
    signal seedphraseUpdated(bool valid, string seedphrase)

    function setWrongSeedPhraseMessage(err: string) {
        seedPanel.setWrongSeedPhraseMessage(err)
    }

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(610, root.availableWidth)
            spacing: Theme.bigPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize22
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

                dictionary: BIP39_en {}
                isSeedPhraseValid: root.isSeedPhraseValid
                onSubmitSeedPhrase: root.seedphraseSubmitted(getSeedPhraseAsString())
                onSeedPhraseUpdated: (valid, seedphrase) => root.seedphraseUpdated(valid, seedphrase)
            }

            StatusButton {
                id: btnContinue
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
