import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import utils

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (root.store.seedPhraseBackupConfirmed) {
            aknowledge.checked = true
        }
    }

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * 3 * Theme.padding
        spacing: Theme.halfPadding

        StatusStepper {
            Layout.preferredWidth: Constants.addAccountPopup.stepperWidth
            Layout.topMargin: Theme.padding
            Layout.alignment: Qt.AlignCenter
            title: qsTr("Step 4 of 4")
            totalSteps: 4
            completedSteps: 4
            leftPadding: 0
            rightPadding: 0
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
            text: qsTr("Complete back up")
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: 2 * Theme.xlPadding
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: Theme.fontSize(18)
            color: Theme.palette.directColor1
            text: qsTr("Store Your Phrase Offline and Complete Your Back Up")
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: Theme.halfPadding
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            color: Theme.palette.directColor1
            text: qsTr("By completing this process, you will remove your recovery phrase from this application’s storage. This makes your funds more secure.\n\nYou will remain logged in, and your recovery phrase will be entirely in your hands.")
        }

        StatusCheckBox {
            id: aknowledge
            objectName: "AddAccountPopup-SeedBackupAknowledge"
            Layout.preferredWidth: parent.width
            Layout.topMargin: 2 * Theme.xlPadding
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I acknowledge that Status will not be able to show me my recovery phrase again.")
            onToggled: {
                root.store.seedPhraseBackupConfirmed = checked
            }
        }
    }
}
