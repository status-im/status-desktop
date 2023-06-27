import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

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
        width: parent.width - 2 * 3 * Style.current.padding
        spacing: Style.current.halfPadding

        StatusStepper {
            Layout.preferredWidth: Constants.addAccountPopup.stepperWidth
            Layout.preferredHeight: Constants.addAccountPopup.stepperHeight
            Layout.topMargin: Style.current.padding
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
            Layout.topMargin: 2 * Style.current.xlPadding
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
            Layout.topMargin: Style.current.halfPadding
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: 1.2
            color: Theme.palette.directColor1
            text: qsTr("By completing this process, you will remove your seed phrase from this application’s storage. This makes your funds more secure.\n\nYou will remain logged in, and your seed phrase will be entirely in your hands.")
        }

        StatusCheckBox {
            id: aknowledge
            objectName: "AddAccountPopup-SeedBackupAknowledge"
            Layout.preferredWidth: parent.width
            Layout.topMargin: 2 * Style.current.xlPadding
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I aknowledge that Status will not be able to show me my seed phrase again.")
            onToggled: {
                root.store.seedPhraseBackupConfirmed = checked
            }
        }
    }
}
