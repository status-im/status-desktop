import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../panels"
import "../stores"

StatusModal {
    id: popup
    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)
    height: 480
    property WalletStore walletStore
    header.title: qsTr("Manage Assets")
    
    rightButtons: [
        StatusButton {
            text: qsTr("Add custom token")
            onClicked: {
                addShowTokenModal.openEditable();
            }
        }
    ]


    contentItem: TokenSettingsModalContent {
        id: settingsModalContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        defaultTokenList: walletStore.defaultTokenList
        customTokenList: walletStore.customTokenList

        onToggleVisibleClicked: {
            walletStore.toggleVisible(chainId, address)
        }
        onRemoveCustomTokenTriggered: {
            walletStore.removeCustomToken(chainId, address)
        }
        onShowTokenDetailsTriggered: {
            addShowTokenModal.openWithData(chainId, address, name, symbol, decimals);
        }

        AddShowTokenModal{
           id: addShowTokenModal
           walletStore: root.walletStore
        }
    }
}
