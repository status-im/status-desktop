import QtQuick 2.13
import SortFilterProxyModel 0.2

import utils 1.0
import shared.status 1.0
import shared.panels 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import shared.popups.addaccount 1.0

import "../../stores"
import "../../controls"
import "../../popups"

Column {
    id: root

    property WalletStore walletStore
    property var emojiPopup

    signal goToNetworksView()
    signal goToAccountOrderView()
    signal goToAccountView(var account)
    signal goToDappPermissionsView()

    spacing: 8

    Connections {
        target: walletSection

        function onDisplayAddAccountPopup() {
            addAccount.active = true
        }
        function onDestroyAddAccountPopup() {
            addAccount.active = false
        }
    }


    Loader {
        id: addAccount
        active: false
        asynchronous: true

        sourceComponent: AddAccountPopup {
            store.emojiPopup: root.emojiPopup
            store.addAccountModule: walletSection.addAccountModule
        }

        onLoaded: {
            addAccount.item.open()
        }
    }

    Separator {}

    StatusListItem {
        objectName: "networksItem"
        title: qsTr("Networks")
        height: 64
        width: parent.width
        onClicked: goToNetworksView()
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
    }

    Separator {}

    StatusListItem {
        objectName: "accountOrderItem"
        title: qsTr("Account order")
        height: 64
        width: parent.width
        onClicked: goToAccountOrderView()
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
    }

    Separator {}

    Item {
        width: parent.width
        height: 8
    }

    Column {
        width: parent.width
        spacing: 24
        Repeater {
            objectName: "generatedAccounts"
            model: walletStore.originModel
            delegate: WalletKeyPairDelegate {
                width: parent.width
                chainShortNames: walletStore.getAllNetworksSupportedPrefix()
                userProfilePublicKey: walletStore.userProfilePublicKey
                includeWatchOnlyAccount: walletStore.includeWatchOnlyAccount
                onGoToAccountView: root.goToAccountView(account)
                onToggleIncludeWatchOnlyAccount: walletStore.toggleIncludeWatchOnlyAccount()
            }
        }
    }
}
