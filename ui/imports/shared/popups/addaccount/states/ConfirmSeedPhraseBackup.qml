import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

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
            Layout.preferredHeight: Constants.addAccountPopup.stepperHeight
            Layout.topMargin: Theme.padding
            Layout.alignment: Qt.AlignCenter
            title: qsTr("Step 4 of 4")
            titleFontSize: Constants.addAccountPopup.labelFontSize1
            totalSteps: 4
            completedSteps: 4
            leftPadding: 0
            rightPadding: 0
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
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
            font.pixelSize: 18
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
