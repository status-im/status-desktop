import QtQuick 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import shared.panels 1.0
import utils 1.0

Item {
    anchors.fill: parent
    objectName: "acknowledgment"
    property bool allAccepted: (havePen.checked && writeDown.checked && storeIt.checked)
    Image {
        id: keysImg
        width: Style.dp(120)
        height: Style.dp(120)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        fillMode: Image.PreserveAspectFit
        source: Style.png("onboarding/keys")
        mipmap: true
    }

    StyledText {
        id: txtTitle
        text: qsTr("Secure Your Assets and Funds")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.left: parent.left
        font.bold: true
        anchors.top: keysImg.bottom
        anchors.topMargin: Style.current.padding
        font.pixelSize: Style.dp(22)
    }

    StyledText {
        id: txtDesc
        anchors.top: txtTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Style.current.primaryTextFontSize
        font.letterSpacing: -Style.dp(0.2)
        text: qsTr("Your seed phrase is a 12-word passcode to your funds.")
    }

    StyledText {
        id: secondTxtDesc
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding
        anchors.left: parent.left
        anchors.top: txtDesc.bottom
        anchors.topMargin: Style.current.bigPadding
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("Your seed phrase cannot be recovered if lost. Therefore, you <b>must</b> back it up. The simplest way is to <b>write it down offline and store it somewhere secure.</b>")
    }

    ColumnLayout {
        anchors.topMargin: Style.dp(49)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: secondTxtDesc.bottom
        spacing: Style.current.padding
        StatusCheckBox {
            id: havePen
            width: parent.width
            text: qsTrId("I have a pen and paper")
        }
        StatusCheckBox {
            id: writeDown
            width: parent.width
            text: qsTrId("I am ready to write down my seed phrase")
        }
        StatusCheckBox {
            id: storeIt
            width: parent.width
            text: qsTr("I know where I’ll store it")
        }
    }

    Item {
        width: parent.width
        height: Style.dp(60)
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
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
            radius: Style.current.radius
            color: Theme.palette.dangerColor1
            opacity: 0.1
        }
    }
}
