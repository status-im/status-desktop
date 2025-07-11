import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel

import StatusQ.Core.Utils

import Storybook
import Models
import AppLayouts.Wallet.popups
import AppLayouts.Wallet.stores as WalletStores

SplitView {
    orientation: Qt.Horizontal

    PopupBackground {
        id: popupBg

        property var popupIntance: null

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !dialog.visible

            onClicked: dialog.open()
        }

        ReceiveModal {
            id: dialog

            visible: true
            accounts: WalletAccountsModel {
                id: accountsModel
            }
            selectedAccount: {
                "name": "Hot wallet (generated)",
                "emoji": "🚗",
                "color": "#216266",
                "address": "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
            }
            switchingAccounsEnabled: true
            hasFloatingButtons: true
            qrImageSource: "https://upload.wikimedia.org/wikipedia/commons/4/41/QR_Code_Example.svg"

            store: WalletStores.RootStore

            onUpdateSelectedAddress: function(address) {
                // Update the selected account based on the new address
               dialog.selectedAccount = ModelUtils.getByKey(dialog.accounts, "address", address)
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20734-337595&mode=design&t=2O68lxNGG9g1b1tx-4
