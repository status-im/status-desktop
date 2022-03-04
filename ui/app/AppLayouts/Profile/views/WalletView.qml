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

    anchors.fill: parent
    contentHeight: advancedContainer.height + 100
    clip: true

    property WalletStore walletStore

    Item {
        id: advancedContainer
        anchors.top: parent.top
        anchors.left: parent.left


        StackLayout {
            id: stackContainer

            anchors.fill: parent
            currentIndex: 0

            MainView {
                walletStore: root.walletStore
                anchors.topMargin: 64
                anchors.top: parent.top
                anchors.leftMargin: 64
                anchors.left: parent.left
                width: 560

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
                anchors.fill: parent
                onGoBack: {
                    stackContainer.currentIndex = 0
                }
            }

            AccountView {
                walletStore: root.walletStore
                anchors.fill: parent
                onGoBack: {
                    stackContainer.currentIndex = 0
                }
            }

            DappPermissionsView {
                walletStore: root.walletStore
                anchors.fill: parent
                onGoBack: {
                    stackContainer.currentIndex = 0
                }
            }
        }
    }
}
