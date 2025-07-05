import QtQuick
import QtQuick.Layouts

import StatusQ.Core

import shared.stores

import AppLayouts.stores as AppLayoutsStores
import AppLayouts.Communities.stores
import AppLayouts.Profile.stores as ProfileStores
import AppLayouts.Wallet.stores as WalletStores
import "../panels"

FocusScope {
    id: root

    property AppLayoutsStores.RootStore store
    property AppLayoutsStores.ContactsStore contactsStore
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
