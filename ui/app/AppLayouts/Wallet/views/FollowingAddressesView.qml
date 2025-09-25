import QtQuick
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Core

import AppLayouts.Wallet.stores as WalletStores
import AppLayouts.Wallet.panels
import AppLayouts.Market.controls

import shared.stores as SharedStores
import utils

RightTabBaseView {
    id: root

    signal sendToAddressRequested(string address)

    property WalletStores.RootStore rootStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    required property SharedStores.NetworksStore networksStore

    // Note: Following addresses are pre-fetched when wallet loads,
    // so data should already be available when user navigates here

    header: WalletFollowingAddressesHeader {
        lastReloadedTime: !!root.rootStore.lastReloadTimestamp ?
                              LocaleUtils.formatRelativeTimestamp(
                                  root.rootStore.lastReloadTimestamp * 1000) : ""
        loading: root.rootStore.isAccountTokensReloading

        onReloadRequested: followingAddresses.refresh()
        onAddViaEFPClicked: Global.openLinkWithConfirmation("https://efp.app", "efp.app")
    }

    Item {
        anchors.fill: parent

        FollowingAddresses {
            id: followingAddresses
            objectName: "followingAddressesArea"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: paginationFooter.visible ? paginationFooter.top : parent.bottom

            contactsStore: root.rootStore.contactStore
            networkConnectionStore: root.networkConnectionStore
            networksStore: root.networksStore

            onSendToAddressRequested: root.sendToAddressRequested(address)
        }

        // Full-width divider above pagination (extends beyond content padding)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: -(Theme.xlPadding * 2)
            anchors.rightMargin: -(Theme.xlPadding * 2)
            anchors.bottom: paginationFooter.top
            height: 1
            color: Theme.palette.baseColor2
            visible: paginationFooter.visible
        }

        // Sticky pagination footer at bottom (extends beyond content padding)
        Item {
            id: paginationFooter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: -(Theme.xlPadding * 2)
            anchors.rightMargin: -(Theme.xlPadding * 2)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -(Theme.halfPadding + 2)
            height: paginatorItem.height + Theme.padding * 2
            visible: followingAddresses.showPagination

            Paginator {
                id: paginatorItem
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Theme.padding
                pageSize: followingAddresses.pageSize
                totalCount: followingAddresses.totalCount
                currentPage: followingAddresses.currentPage
                enabled: !followingAddresses.isPaginationLoading
                onRequestPage: followingAddresses.goToPage(pageNumber)
            }
        }
    }
}
