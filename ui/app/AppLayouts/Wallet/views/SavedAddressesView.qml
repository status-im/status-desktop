import QtQuick

import AppLayouts.Wallet.panels

import shared.stores as SharedStores
import AppLayouts.Wallet.stores as WalletStores

import utils

RightTabBaseView {
    id: root

    signal sendToAddressRequested(string address)

    property SharedStores.NetworkConnectionStore networkConnectionStore
    required property SharedStores.NetworksStore networksStore

    header: WalletHeader {
        id: header

        networkConnectionStore: root.networkConnectionStore
        networksStore: root.networksStore
        overview: WalletStores.RootStore.overview
        walletStore: WalletStores.RootStore

        dAppsEnabled: false
        dAppsVisible: false

        networkFilter.visible: false
        headerButton.text: qsTr("Add new address")

        headerButton.onClicked: {
            Global.openAddEditSavedAddressesPopup({})
        }
    }

    SavedAddresses {
        objectName: "savedAddressesArea"

        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
        networksStore: root.networksStore

        onSendToAddressRequested: root.sendToAddressRequested(address)
    }
}
