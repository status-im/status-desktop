import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1

import shared.stores 1.0

import AppLayouts.stores 1.0 as AppLayoutsStores
import AppLayouts.Communities.stores 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores
import AppLayouts.Wallet.stores 1.0 as WalletStores
import "../panels"

FocusScope {
    id: root

    property AppLayoutsStores.RootStore store
    property ProfileStores.ContactsStore contactsStore
    property CommunitiesStore communitiesStore
    property NetworkConnectionStore networkConnectionStore
    required property NetworksStore networksStore

    property bool swapEnabled
    property bool dAppsEnabled
    property bool dAppsVisible

    property var dAppsModel

    property alias header: header
    property alias headerButton: header.headerButton
    property alias networkFilter: header.networkFilter

    default property alias content: contentWrapper.children

    signal dappListRequested()
    signal dappConnectRequested()
    signal dappDisconnectRequested(string dappUrl)
    signal manageNetworksRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        WalletHeader {
            id: header
            Layout.fillWidth: true
            overview: WalletStores.RootStore.overview
            walletStore: WalletStores.RootStore
            networksStore: root.networksStore
            networkConnectionStore: root.networkConnectionStore
            loginType: root.store.loginType
            dAppsEnabled: root.dAppsEnabled
            dAppsVisible: root.dAppsVisible
            dAppsModel: root.dAppsModel

            onDappListRequested: root.dappListRequested()
            onDappConnectRequested: root.dappConnectRequested()
            onDappDisconnectRequested: (dappUrl) =>root.dappDisconnectRequested(dappUrl)
            onManageNetworksRequested: root.manageNetworksRequested()
        }

        Item {
            id: contentWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
