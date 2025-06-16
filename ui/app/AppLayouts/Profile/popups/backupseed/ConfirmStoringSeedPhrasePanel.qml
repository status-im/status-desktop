import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
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
        Layout.topMargin: Theme.bigPadding
        spacing: Theme.padding

        StyledText {
            id: txtTitle
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: Theme.secondaryAdditionalTextSize
            lineHeight: 1.2
            text: qsTr("Store Your Phrase Offline and Complete Your Back Up")
            Layout.fillWidth: true
        }

        StyledText {
            id: txtDesc
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            text: qsTr("By completing this process, you will remove your recovery phrase from this application’s storage. This makes your funds more secure.")
            Layout.fillWidth: true
        }

        StyledText {
            id: secondTxtDesc
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            text: qsTr("You will remain logged in, and your recovery phrase will be entirely in your hands.")
            Layout.fillWidth: true
        }

        StatusCheckBox {
            id: storeCheck
            objectName: "ConfirmStoringSeedPhrasePanel_storeCheck"
            spacing: Theme.padding
            font.pixelSize: Theme.primaryTextFontSize
            text: qsTr("I acknowledge that Status will not be able to show me my recovery phrase again.")
            Layout.fillWidth: true
            Layout.topMargin: Theme.bigPadding
        }
    }
}
