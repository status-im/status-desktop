import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls.Validators

import SortFilterProxyModel

import utils
import shared.controls
import shared.stores as SharedStores
import AppLayouts.stores as AppLayoutStores

import AppLayouts.Wallet.stores
import AppLayouts.Wallet.controls

Item {
    id: root

    property AppLayoutStores.ContactsStore contactsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    property SharedStores.NetworksStore networksStore

    signal sendToAddressRequested(string address)

    readonly property bool showPagination: !d.currentSearch && walletSectionFollowingAddresses && walletSectionFollowingAddresses.totalFollowingCount > d.pageSize
    readonly property int pageSize: d.pageSize
    readonly property int totalCount: walletSectionFollowingAddresses ? walletSectionFollowingAddresses.totalFollowingCount : 0
    readonly property int currentPage: d.currentPage
    readonly property bool isPaginationLoading: d.isPaginationLoading

    function goToPage(pageNumber) {
        d.goToPage(pageNumber)
    }

    function refresh() {
        d.refresh()
    }

    QtObject {
        id: d

        property string currentSearch: ""
        property int pageSize: 10
        property int currentPage: 1
        property bool isPaginationLoading: false

        function reset() {
            currentSearch = ""
            searchBox.text = ""
            currentPage = 1
        }

        function performSearch() {
            var offset = (currentPage - 1) * pageSize
            isPaginationLoading = true
            RootStore.refreshFollowingAddresses(currentSearch, pageSize, offset)
        }

        function goToPage(pageNumber) {
            currentPage = pageNumber
            performSearch()
        }

        function refresh() {
            currentPage = 1
            currentSearch = ""
            searchBox.text = ""
            isPaginationLoading = true
            RootStore.refreshFollowingAddresses("", pageSize, 0)
        }
    }

    Connections {
        target: walletSectionFollowingAddresses
        function onFollowingAddressesUpdated() {
            d.isPaginationLoading = false
        }
    }

    Connections {
        target: RootStore.followingAddresses
        function onCountChanged() {
            d.isPaginationLoading = false
        }
    }

    Timer {
        id: searchDebounceTimer
        interval: 250
        repeat: false
        onTriggered: d.performSearch()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SearchBox {
            id: searchBox
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.padding
            visible: true
            placeholderText: qsTr("Search for name, ENS or address")

            onTextChanged: {
                d.currentSearch = text
                d.currentPage = 1
                searchDebounceTimer.restart()
            }

            validators: [
                StatusValidator {
                    property bool isEmoji: false

                    name: "check-for-no-emojis"
                    validate: (value) => {
                                  if (!value) {
                                      return true
                                  }

                                  isEmoji = Constants.regularExpressions.emoji.test(value)
                                  if (isEmoji){
                                      return false
                                  }

                                  return Constants.regularExpressions.alphanumericalExpanded1.test(value)
                              }
                    errorMessage: isEmoji?
                                      qsTr("Your search is too cool (use A-Z and 0-9, single whitespace, hyphens and underscores only)")
                                    : qsTr("Your search contains invalid characters (use A-Z and 0-9, single whitespace, hyphens and underscores only)")
                }
            ]
        }

        ShapeRectangle {
            id: noFollowingAddresses
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            visible: RootStore.followingAddresses.count === 0
            text: qsTr("Your EFP onchain friends will appear here")
        }

        ShapeRectangle {
            id: emptySearchResult
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            visible: RootStore.followingAddresses.count > 0 && listView.count === 0
            text: qsTr("No following addresses found. Check spelling or address is correct.")
        }

        StatusLoadingIndicator {
            id: loadingIndicator
            Layout.alignment: Qt.AlignHCenter
            visible: RootStore.loadingFollowingAddresses
            color: Theme.palette.directColor4
        }

        Item {
            visible: noFollowingAddresses.visible || emptySearchResult.visible
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StatusListView {
                id: listView
                objectName: "FollowingAddressesView_followingAddresses"
                anchors.fill: parent
                spacing: 8
                visible: !d.isPaginationLoading

                model: RootStore.followingAddresses

                delegate: FollowingAddressesDelegate {
                    id: followingAddressDelegate
                    objectName: "followingAddressView_Delegate_" + name
                    name: model.name
                    address: model.address
                    ensName: model.ensName
                    tags: model.tags
                    avatar: model.avatar
                    networkConnectionStore: root.networkConnectionStore
                    activeNetworks: root.networksStore.activeNetworks
                    onOpenSendModal: root.sendToAddressRequested(recipient)
                }
            }

            StatusLoadingIndicator {
                anchors.centerIn: parent
                visible: d.isPaginationLoading
                color: Theme.palette.directColor4
            }
        }
    }
}
