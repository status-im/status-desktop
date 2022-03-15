import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1

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

Item {
    id: root

    property var emojiPopup
    property WalletStore walletStore

    anchors.fill: parent

    readonly property int mainViewIndex: 0;
    readonly property int networksViewIndex: 1;
    readonly property int accountViewIndex: 2;
    readonly property int dappPermissionViewIndex: 3;

    StatusBanner {
        id: banner
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        visible: walletStore.areTestNetworksEnabled
        type: StatusBanner.Type.Danger
        statusText: qsTr("Testnet mode is enabled. All balances, transactions and dApp interactions will be on testnets.")
    }

    ScrollView {

        anchors.top: banner.visible ? banner.bottom: parent.top
        clip: true 

        StackLayout {
            id: stackContainer

            anchors.fill: parent
            currentIndex: mainViewIndex

            MainView {
                id: main
                Layout.preferredWidth: 560
                leftPadding: 64
                topPadding: 64
                walletStore: root.walletStore

                onGoToNetworksView: {
                    stackContainer.currentIndex = networksViewIndex
                }

                onGoToAccountView: {
                    root.walletStore.switchAccountByAddress(address)
                    stackContainer.currentIndex = accountViewIndex
                }

                onGoToDappPermissionsView: {
                    stackContainer.currentIndex = dappPermissionViewIndex
                }
            }

            NetworksView {
                walletStore: root.walletStore
                onGoBack: {
                    stackContainer.currentIndex = mainViewIndex
                }
            }

            AccountView {
                walletStore: root.walletStore
                emojiPopup: root.emojiPopup
                onGoBack: {
                    stackContainer.currentIndex = mainViewIndex
                }
            }

            DappPermissionsView {
                walletStore: root.walletStore
                onGoBack: {
                    stackContainer.currentIndex = mainViewIndex
                }
            }
        }
    }
}