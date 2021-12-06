import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.popups 1.0
import "../panels"
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    //% "Manage Assets"
    title: qsTrId("manage-assets")
    signal addCustomTokenTriggered()
    signal tokenDetailsTriggered(string address, string address, string address, string address)

    TokenSettingsModalContent {
        id: settingsModalContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        defaultTokenList: RootStore.defaultTokenList
        customTokenList: RootStore.customTokenList

        onToggleVisibleClicked: {
            RootStore.toggleVisible(symbol)
        }
        onRemoveCustomTokenTriggered: {
            RootStore.removeCustomToken(address)
        }
        onTokenDetailsTriggered: {
            popup.tokenDetailsTriggered(address, name, symbol, decimals);
        }
    }

    footer: StatusButton {
        anchors.right: parent.right
        //% "Add custom token"
        text: qsTrId("add-custom-token")
        anchors.top: parent.top
        onClicked: {
            popup.addCustomTokenTriggered();
        }
    }
}
