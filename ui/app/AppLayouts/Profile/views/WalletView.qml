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
    readonly property int accountOrderViewIndex: 2;
    readonly property int accountViewIndex: 3;

    Component.onCompleted: {
        root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
    }

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

            if (currentIndex == root.mainViewIndex) {
                root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
            }

            if(currentIndex == root.networksViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = qsTr("Networks")

                root.titleRowComponentLoader.sourceComponent = testnetModeSwitchComponent
            }
            else if(currentIndex == root.accountViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = ""
            }
            else if(currentIndex == root.accountOrderViewIndex) {
                root.rootStore.backButtonName = qsTr("Wallet")
                root.sectionTitle = qsTr("Edit account order")
            }
        }

        MainView {
            id: main

            Layout.fillWidth: true

            walletStore: root.walletStore
            emojiPopup: root.emojiPopup

            onGoToNetworksView: {
                stackContainer.currentIndex = networksViewIndex
            }

            onGoToAccountView: {
                accountView.account = account
                stackContainer.currentIndex = accountViewIndex
            }

            onGoToAccountOrderView: {
                stackContainer.currentIndex = accountOrderViewIndex
            }
        }

        NetworksView {
            walletStore: root.walletStore

            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }
        }

        AccountOrderView {
            walletStore: root.walletStore
            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }
        }

        AccountView {
            id: accountView
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

        Component {
            id: addNewAccountButtonComponent
            StatusButton {
                text: qsTr("Add new account")
                onClicked: root.walletStore.runAddAccountPopup()
            }
        }
    }
}
