import QtQuick 2.12
import utils 1.0
import shared.panels 1.0
import StatusQ.Controls 0.1

BackupSeedStepBase {
    titleText: qsTr("Complete back up")
    property bool seedStored: storeCheck.checked

    StyledText {
        id: txtTitle
        anchors.top: parent.top
        anchors.topMargin: Style.dp(40)
        anchors.right: parent.right
        anchors.left: parent.left
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: Style.dp(17)
        text: qsTr("Store Your Phrase Offline and Complete Your Back Up")
    }

    StyledText {
        id: txtDesc
        anchors.top: txtTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.left: parent.left
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("By completing this process, you will remove your seed phrase from this application’s storage. This makes your funds more secure.")
    }

    StyledText {
        id: secondTxtDesc
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: txtDesc.bottom
        anchors.topMargin: Style.current.bigPadding
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("You will remain logged in, and your seed phrase will be entirely in your hands.")
    }

    StatusCheckBox {
        id: storeCheck
        width: parent.width
        anchors.top: secondTxtDesc.bottom
        anchors.topMargin: Style.dp(48)
        text: qsTr("I aknowledge that Status will not be able to show me my seed phrase again.")
    }
}
