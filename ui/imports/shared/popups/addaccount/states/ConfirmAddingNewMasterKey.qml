import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import utils 1.0

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
        readonly property int width1: layout.width - 2 * Style.current.padding
        readonly property int width2: d.width1 - 2 * Style.current.padding
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
        width: parent.width - 2 * Style.current.padding
        spacing: Style.current.padding

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.current.padding
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            fillMode: Image.PreserveAspectFit
            source: Style.png("onboarding/keys")
            mipmap: true
            cache: false
        }

        StatusBaseText {
            Layout.preferredWidth: d.width1
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: 22
            text: qsTr("Secure Your Assets and Funds")
        }

        StatusBaseText {
            Layout.preferredWidth: d.width1
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: d.lineHeight
            text: qsTr("Your seed phrase is a 12-word passcode to your funds.<br/><br/>Your seed phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
        }

        StatusCheckBox {
            id: havePen
            objectName: "AddAccountPopup-HavePenAndPaper"
            Layout.preferredWidth: d.width2
            Layout.preferredHeight: d.checkboxHeight
            Layout.topMargin: Style.current.padding
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I have a pen and paper")
        }

        StatusCheckBox {
            id: writeDown
            objectName: "AddAccountPopup-SeedPhraseWritten"
            Layout.preferredWidth: d.width2
            Layout.preferredHeight: d.checkboxHeight
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I am ready to write down my seed phrase")
        }

        StatusCheckBox {
            id: storeIt
            objectName: "AddAccountPopup-StoringSeedPhraseConfirmed"
            Layout.preferredWidth: d.width2
            Layout.preferredHeight: d.checkboxHeight
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I know where I’ll store it")
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            Layout.topMargin: Style.current.padding
            radius: Style.current.radius
            color: Theme.palette.dangerColor3

            StatusBaseText {
                anchors.fill: parent
                anchors.margins: Style.current.halfPadding
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Style.current.primaryTextFontSize
                wrapMode: Text.WordWrap
                color: Theme.palette.dangerColor1
                lineHeight: d.lineHeight
                text: qsTr("You can only complete this process once. Status will not store your seed phrase and can never help you recover it.")
            }
        }
    }
}
