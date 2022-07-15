import QtQuick 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

BackupSeedStepBase {
    id: root

    readonly property alias seedStored: storeCheck.checked

    titleText: qsTr("Complete back up")

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 44
        Layout.rightMargin: 44
        Layout.topMargin: Style.current.bigPadding
        spacing: Style.current.padding

        StyledText {
            id: txtTitle
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: 17
            lineHeight: 1.2
            text: qsTr("Store Your Phrase Offline and Complete Your Back Up")
            Layout.fillWidth: true
        }

        StyledText {
            id: txtDesc
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: 1.2
            text: qsTr("By completing this process, you will remove your seed phrase from this application’s storage. This makes your funds more secure.")
            Layout.fillWidth: true
        }

        StyledText {
            id: secondTxtDesc
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: 1.2
            text: qsTr("You will remain logged in, and your seed phrase will be entirely in your hands.")
            Layout.fillWidth: true
        }

        StatusCheckBox {
            id: storeCheck
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I acknowledge that Status will not be able to show me my seed phrase again.")
            Layout.fillWidth: true
            Layout.topMargin: Style.current.bigPadding
        }
    }
}
