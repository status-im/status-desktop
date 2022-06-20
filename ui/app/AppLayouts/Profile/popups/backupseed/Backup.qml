import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import StatusQ.Core.Theme 0.1

import shared.panels 1.0
import utils 1.0

Item {
    id: root
    property var privacyStore
    property alias bar: bar
    property alias seedHidden: confirmSeedPhrase.hideSeed
    property alias seedStored: confirmStoringSeedPhrase.seedStored
    property int firstRandomNo: Math.floor(Math.random() * 12)
    property alias validFirstSeedWord: confirmFirstWord.inputValid
    property alias validSecondSeedWord: confirmSecondWord.inputValid
    property int secondRandomNo: {
        var num = Math.floor(Math.random() * 12);
        return (num === firstRandomNo) ? Math.floor(Math.random() * 12) : num;
    }

    anchors.fill: parent

    StyledText {
        id: txtDesc
        anchors.right: parent.right
        anchors.left: parent.left
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.additionalTextSize
        color: Style.current.secondaryText
        text: qsTr("Step " + (bar.currentIndex+1) + " of " + bar.count)
    }

    TabBar {
        id: bar
        width: (Style.dp(59) * count)
        height: Style.dp(4)
        anchors.top: txtDesc.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.dp(2)
        background: null
        TabBarButton { index: 0; currentIndex: bar.currentIndex }
        TabBarButton { index: 1; currentIndex: bar.currentIndex }
        TabBarButton { index: 2; currentIndex: bar.currentIndex }
        TabBarButton { index: 3; currentIndex: bar.currentIndex }
    }

    StackLayout {
        id: stack
        anchors.top: bar.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        currentIndex: bar.currentIndex
        ConfirmSeedPhrasePanel {
            id: confirmSeedPhrase
            seedPhrase: root.privacyStore.getMnemonic().split(" ")
        }
        BackupSeedStepBase {
            id: confirmFirstWord
            titleText: qsTr("Confirm word #" + (root.firstRandomNo+1) + " of your seed phrase")
            wordRandomNumber: root.firstRandomNo
            wordAtRandomNumber: root.privacyStore.getMnemonicWordAtIndex(root.firstRandomNo)
        }
        BackupSeedStepBase {
            id: confirmSecondWord
            titleText: qsTr("Confirm word #" + (root.secondRandomNo+1) + " of your seed phrase")
            wordRandomNumber: root.secondRandomNo
            wordAtRandomNumber: root.privacyStore.getMnemonicWordAtIndex(root.secondRandomNo)
        }
        ConfirmStoringSeedPhrasePanel { id: confirmStoringSeedPhrase }
    }
}
