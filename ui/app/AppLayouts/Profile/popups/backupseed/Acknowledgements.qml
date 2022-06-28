import QtQuick 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.panels 1.0
import utils 1.0

ColumnLayout {
    id: root

    readonly property bool allAccepted: havePen.checked && writeDown.checked && storeIt.checked

    spacing: Style.current.padding
    implicitHeight: 520

    Flickable {
        id: flick
        clip: true
        contentHeight: flickLayout.height
        implicitHeight: flickLayout.implicitHeight
        interactive: contentHeight > height
        flickableDirection: Flickable.VerticalFlick
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            id: flickLayout
            width: parent.width
            spacing: Style.current.padding

            Image {
                id: keysImg
                fillMode: Image.PreserveAspectFit
                source: Style.png("onboarding/keys")
                mipmap: true
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 120
                Layout.preferredHeight: width
            }

            StyledText {
                id: txtTitle
                text: qsTr("Secure Your Assets and Funds")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.bold: true
                font.pixelSize: 22
                Layout.fillWidth: true
            }

            StyledText {
                id: txtDesc
                font.pixelSize: Style.current.primaryTextFontSize
                font.letterSpacing: -0.2
                text: qsTr("Your seed phrase is a 12-word passcode to your funds.")
                Layout.fillWidth: true
            }

            StyledText {
                id: secondTxtDesc
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                font.pixelSize: Style.current.primaryTextFontSize
                text: qsTr("Your seed phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
                Layout.fillWidth: true
            }

            StatusCheckBox {
                id: havePen
                text: qsTr("I have a pen and paper")
                Layout.fillWidth: true
            }

            StatusCheckBox {
                id: writeDown
                text: qsTr("I am ready to write down my seed phrase")
                Layout.fillWidth: true
            }

            StatusCheckBox {
                id: storeIt
                text: qsTr("I know where I’ll store it")
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        color: Theme.palette.statusModal.backgroundColor
        Layout.fillWidth: true
        Layout.preferredHeight: 60

        StyledText {
            anchors.fill: parent
            anchors.margins: Style.current.halfPadding
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Style.current.primaryTextFontSize
            wrapMode: Text.WordWrap
            color: Theme.palette.dangerColor1
            text: qsTr("You can only complete this process once. Status will not store your seed phrase and can never help you recover it.")
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Theme.palette.dangerColor1
            opacity: 0.1
        }
    }
}