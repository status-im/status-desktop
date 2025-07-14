import QtQuick

import shared.panels

Loader {
    id: root

    required property bool isOnline
    required property bool testnetEnabled
    required property bool seedphraseBackedUp

    signal openTestnetPopupRequested()
    signal openBackUpSeedPopupRequested()
    signal userDeclinedBackupBannerRequested()

    sourceComponent: {
        if (d.showConnectedBanner)
            return connectedBannerComponent
        if (testnetEnabled)
            return testnetBannerComponent
        if (!seedphraseBackedUp)
            return secureYourSeedPhraseComponent
    }

    visible: !!item

    onLoaded: item.show()

    QtObject {
        id: d

        property bool showConnectedBanner: !root.isOnline // initially, we don't want to show the "You are online" banner
    }

    Connections {
        target: root
        function onIsOnlineChanged() {
            if (!root.isOnline) {
                d.showConnectedBanner = !root.isOnline // show the banner again if we are offline
            }
        }
    }

    Component {
        id: connectedBannerComponent
        ModuleWarning {
            id: connectedBanner

            objectName: "connectionInfoBanner"
            text: root.isOnline ? qsTr("You are back online") : qsTr("Internet connection lost. Reconnect to ensure everything is up to date.")
            type: root.isOnline ? ModuleWarning.Success : ModuleWarning.Danger

            Connections {
                target: root
                function onIsOnlineChanged() {
                    if (root.isOnline) { // keep showing the connectedBanner for 3 more seconds
                        d.showConnectedBanner = true
                        connectedBanner.showFor(3000)
                    }
                }
            }

            delay: false
            onCloseClicked: {
                d.showConnectedBanner = true // keep showing the connectedBanner until the hide animation is done
                hide()
            }

            onHideFinished: d.showConnectedBanner = false // close the banner until the next offline event
        }
    }

    Component {
        id: testnetBannerComponent
        ModuleWarning {
            objectName: "testnetBanner"
            text: qsTr("Testnet mode enabled. All balances, transactions and dApp interactions will be on testnets.")
            buttonText: qsTr("Turn off")
            type: ModuleWarning.Warning
            iconName: "warning"
            delay: false
            onClicked: root.openTestnetPopupRequested()
            closeBtnVisible: false
        }
    }

    Component {
        id: secureYourSeedPhraseComponent
        ModuleWarning {
            objectName: "secureYourSeedPhraseBanner"
            type: ModuleWarning.Type.Danger
            text: qsTr("Secure your recovery phrase")
            buttonText: qsTr("Back up now")
            delay: false
            onClicked: root.openBackUpSeedPopupRequested()
            onCloseClicked: root.userDeclinedBackupBannerRequested()
        }
    }
}
