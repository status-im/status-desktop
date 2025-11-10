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

    required property AppLayoutStores.ContactsStore contactsStore
    required property SharedStores.NetworkConnectionStore networkConnectionStore
    required property SharedStores.NetworksStore networksStore
    property var followingAddressesModel
    property int totalFollowingCount

    signal sendToAddressRequested(string address)
    signal refreshRequested(string search, int limit, int offset)
    signal followingAddressesUpdated()

    readonly property bool showPagination: !d.currentSearch && root.totalFollowingCount > d.pageSize
    readonly property int pageSize: d.pageSize
    readonly property int totalCount: root.totalFollowingCount
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
            root.refreshRequested(currentSearch, pageSize, offset)
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
            root.refreshRequested("", pageSize, 0)
        }
    }

    // Called from parent when following addresses are updated
    onFollowingAddressesUpdated: {
        d.isPaginationLoading = false
    }

    Component.onCompleted: {
        d.refresh()  // Load data when user navigates to this page
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
            visible: root.followingAddressesModel && root.followingAddressesModel.count === 0 && !d.isPaginationLoading
            text: qsTr("Your EFP onchain friends will appear here")
        }

        ShapeRectangle {
            id: emptySearchResult
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            visible: root.followingAddressesModel && root.followingAddressesModel.count > 0 && listView.count === 0 && !d.isPaginationLoading
            text: qsTr("No following addresses found. Check spelling or address is correct.")
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

                model: root.followingAddressesModel

                delegate: FollowingAddressesDelegate {
                    id: followingAddressDelegate
                    objectName: "followingAddressView_Delegate_" + name
                    width: ListView.view.width
                    name: model.name
                    address: model.address
                    ensName: model.ensName
                    tags: model.tags
                    avatar: model.avatar
                    networkConnectionStore: root.networkConnectionStore
                    activeNetworks: root.networksStore.activeNetworks
                    onOpenSendModal: root.sendToAddressRequested(recipient)
                    onMenuRequested: (menuModel) => {
                        followingAddressMenu.openMenu(followingAddressDelegate, 
                            followingAddressDelegate.width - followingAddressMenu.width,
                            followingAddressDelegate.height + Theme.halfPadding,
                            menuModel)
                    }
                }
            }

            StatusLoadingIndicator {
                anchors.centerIn: parent
                visible: d.isPaginationLoading
                color: Theme.palette.directColor4
            }
        }

        FollowingAddressMenu {
            id: followingAddressMenu
            activeNetworks: root.networksStore.activeNetworks
        }
    }
}
