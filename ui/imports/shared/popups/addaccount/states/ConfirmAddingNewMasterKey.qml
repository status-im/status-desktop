import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core

import utils

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (root.store.addingNewMasterKeyConfirmed) {
            havePen.checked = true
            writeDown.checked = true
            storeIt.checked = true
        }
    }

    QtObject {
        id: d
        readonly property int width1: layout.width - 2 * Theme.padding
        readonly property int width2: d.width1 - 2 * Theme.padding
        readonly property int checkboxHeight: 24
        readonly property real lineHeight: 1.2

        readonly property bool allAccepted: havePen.checked && writeDown.checked && storeIt.checked
        onAllAcceptedChanged: {
            root.store.addingNewMasterKeyConfirmed = allAccepted
        }
    }

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Theme.padding
        spacing: Theme.padding

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.padding
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            fillMode: Image.PreserveAspectFit
            source: Theme.png("onboarding/keys")
            mipmap: true
            cache: false
        }

        StatusBaseText {
            Layout.preferredWidth: d.width1
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: Theme.fontSize(22)
            text: qsTr("Secure Your Assets and Funds")
        }

        StatusBaseText {
            Layout.preferredWidth: d.width1
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: d.lineHeight
            text: qsTr("Your recovery phrase is a 12-word passcode to your funds.<br/><br/>Your recovery phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
        }

        StatusCheckBox {
            id: havePen
            objectName: "AddAccountPopup-HavePenAndPaper"
            Layout.preferredWidth: d.width2
            Layout.preferredHeight: d.checkboxHeight
            Layout.topMargin: Theme.padding
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I have a pen and paper")
        }

        StatusCheckBox {
            id: writeDown
            objectName: "AddAccountPopup-SeedPhraseWritten"
            Layout.preferredWidth: d.width2
            Layout.preferredHeight: d.checkboxHeight
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I am ready to write down my recovery phrase")
        }

        StatusCheckBox {
            id: storeIt
            objectName: "AddAccountPopup-StoringSeedPhraseConfirmed"
            Layout.preferredWidth: d.width2
            Layout.preferredHeight: d.checkboxHeight
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I know where I’ll store it")
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            Layout.topMargin: Theme.padding
            radius: Theme.radius
            color: Theme.palette.dangerColor3

            StatusBaseText {
                anchors.fill: parent
                anchors.margins: Theme.halfPadding
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.primaryTextFontSize
                wrapMode: Text.WordWrap
                color: Theme.palette.dangerColor1
                lineHeight: d.lineHeight
                text: qsTr("You can only complete this process once. Status will not store your recovery phrase and can never help you recover it.")
            }
        }
    }
}
