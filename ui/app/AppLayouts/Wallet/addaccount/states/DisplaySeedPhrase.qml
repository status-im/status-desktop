import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Style.current.padding
        spacing: Style.current.halfPadding

        StatusStepper {
            Layout.preferredWidth: Constants.addAccountPopup.stepperWidth
            Layout.preferredHeight: Constants.addAccountPopup.stepperHeight
            Layout.topMargin: Style.current.padding
            Layout.alignment: Qt.AlignCenter
            title: qsTr("Step 1 of 4")
            titleFontSize: Constants.addAccountPopup.labelFontSize1
            totalSteps: 4
            completedSteps: 1
            leftPadding: 0
            rightPadding: 0
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
            color: Theme.palette.directColor1
            text: qsTr("Write down your 12-word seed phrase to keep offline")
        }

        SeedPhrase {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 304
            Layout.topMargin: 3 * Style.current.padding
            seedPhraseRevealed: root.store.seedPhraseRevealed

            seedPhrase: root.store.getSeedPhrase().split(" ")

            onSeedPhraseRevealedChanged: {
                root.store.seedPhraseRevealed = seedPhraseRevealed
            }
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: 2 * Style.current.padding
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            visible: !root.store.seedPhraseRevealed
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            color: Theme.palette.dangerColor1
            text: qsTr("The next screen contains your seed phrase.<br/><b>Anyone</b> who sees it can use it to access to your funds.")
        }
    }
}
