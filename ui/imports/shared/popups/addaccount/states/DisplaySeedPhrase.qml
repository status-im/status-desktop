import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils
import shared.panels

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Theme.padding
        spacing: Theme.halfPadding

        StatusStepper {
            Layout.preferredWidth: Constants.addAccountPopup.stepperWidth
            Layout.topMargin: Theme.padding
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
            text: qsTr("Write down your 12-word recovery phrase to keep offline")
        }

        SeedPhrase {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 304
            Layout.topMargin: 3 * Theme.padding
            seedPhraseRevealed: root.store.seedPhraseRevealed

            seedPhrase: root.store.getSeedPhrase().split(" ")

            onSeedPhraseRevealedChanged: {
                root.store.seedPhraseRevealed = seedPhraseRevealed
            }
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: 2 * Theme.padding
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            visible: !root.store.seedPhraseRevealed
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            color: Theme.palette.dangerColor1
            text: qsTr("The next screen contains your recovery phrase.<br/><b>Anyone</b> who sees it can use it to access to your funds.")
        }
    }
}
