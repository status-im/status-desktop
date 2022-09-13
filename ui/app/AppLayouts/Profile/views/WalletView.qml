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

import "../controls"
import "../popups"
import "../panels"
import "./wallet"

SettingsContentBase {
    id: root

    property var emojiPopup
    property var rootStore
    property var walletStore

    readonly property int mainViewIndex: 0;
    readonly property int networksViewIndex: 1;
    readonly property int accountViewIndex: 2;
    readonly property int dappPermissionViewIndex: 3;

    function resetStack() {
        stackContainer.currentIndex = mainViewIndex;
    }

    StackLayout {
        id: stackContainer

        width: root.contentWidth
        currentIndex: mainViewIndex

        onCurrentIndexChanged: {
            root.rootStore.backButtonName = ""
            root.sectionTitle = qsTr("Wallet")
            root.titleRowComponentLoader.sourceComponent = undefined

            if(currentIndex == root.networksViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = qsTr("Networks")

                root.titleRowComponentLoader.sourceComponent = testnetModeSwitchComponent
            }
            else if(currentIndex == root.accountViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = ""
            }
            else if(currentIndex == root.dappPermissionViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = qsTr("DApp Permissions")
            }
        }

        MainView {
            id: main

            Layout.fillWidth: true

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
        }

        Component {
            id: testnetModeSwitchComponent
            StatusSwitch {
                objectName: "testnetModeSwitch"
                text: qsTr("Testnet Mode")
                checked: walletStore.areTestNetworksEnabled
                onClicked: walletStore.toggleTestNetworksEnabled()
            }
        }
    }
}
