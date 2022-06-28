import QtQuick 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

BackupSeedStepBase {
    id: root

    property bool seedStored: storeCheck.checked

    titleText: qsTr("Complete back up")

    StyledText {
        id: txtTitle
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 17
        text: qsTr("Store Your Phrase Offline and Complete Your Back Up")
        Layout.fillWidth: true
    }

    StyledText {
        id: txtDesc
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("By completing this process, you will remove your seed phrase from this application’s storage. This makes your funds more secure.")
        Layout.fillWidth: true
    }

    StyledText {
        id: secondTxtDesc
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.primaryTextFontSize
        text: qsTr("You will remain logged in, and your seed phrase will be entirely in your hands.")
        Layout.fillWidth: true
    }

    StatusCheckBox {
        id: storeCheck
        text: qsTr("I aknowledge that Status will not be able to show me my seed phrase again.")
        Layout.fillWidth: true
    }
}
