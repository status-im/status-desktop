import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "../stores"
import "../controls"
import "../popups"
import "../panels"
import "./wallet"

ScrollView {
    id: root

    property var emojiPopup
    property WalletStore walletStore

    clip: true

    StackLayout {
        id: stackContainer

        anchors.fill: parent
        currentIndex: 0

        MainView {
            id: main
            Layout.preferredWidth: 560
            leftPadding: 64
            topPadding: 64
            walletStore: root.walletStore

            onGoToNetworksView: {
                stackContainer.currentIndex = 1
            }

            onGoToAccountView: {
                root.walletStore.switchAccountByAddress(address)
                stackContainer.currentIndex = 2
            }

            onGoToDappPermissionsView: {
                stackContainer.currentIndex = 3
            }
        }

        NetworksView {
            walletStore: root.walletStore
            onGoBack: {
                stackContainer.currentIndex = 0
            }
        }

        AccountView {
            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
            onGoBack: {
                stackContainer.currentIndex = 0
            }
        }

        DappPermissionsView {
            walletStore: root.walletStore
            onGoBack: {
                stackContainer.currentIndex = 0
            }
        }
    }
}
