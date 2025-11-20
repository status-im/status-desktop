import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.Wallet.views
import AppLayouts.Wallet.stores as WalletStores
import shared.stores as SharedStores

import Models
import Storybook
import utils

SplitView {
    id: root

    Logs { id: logs }

    // All available addresses (simulates server database)
    ListModel {
        id: allAddressesModel

        Component.onCompleted: resetToDefaults()

        function resetToDefaults() {
            allAddressesModel.clear()
            const addresses = [
                { name: "vitalik.eth", address: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", ensName: "vitalik.eth", tags: ["ethereum", "founder"], avatar: "" },
                { name: "0x929d...8975c", address: "0x929d0D5Cbc5228543Fa9b7df766CFf42C8c8975c", ensName: "", tags: ["saved", "friend"], avatar: "" },
                { name: "alice.eth", address: "0x1234567890123456789012345678901234567890", ensName: "alice.eth", tags: ["defi", "developer"], avatar: "" },
                { name: "bob.eth", address: "0x0987654321098765432109876543210987654321", ensName: "bob.eth", tags: ["nft", "artist"], avatar: "" },
                { name: "charlie.eth", address: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd", ensName: "charlie.eth", tags: ["dao", "governance"], avatar: "" },
                { name: "0xfedc...4321", address: "0xfedcba9876543210fedcba9876543210fedcba42", ensName: "", tags: [], avatar: "" },
                { name: "david.eth", address: "0x1111111111111111111111111111111111111111", ensName: "david.eth", tags: ["security"], avatar: "" },
                { name: "eve.eth", address: "0x2222222222222222222222222222222222222222", ensName: "eve.eth", tags: ["researcher"], avatar: "" }
            ]
            addresses.forEach(addr => allAddressesModel.append(addr))
        }
    }

    // Current page model (what's actually displayed - simulates API response)
    ListModel {
        id: currentPageModel
    }

    // Mock context property for walletSectionFollowingAddresses
    // MUST be defined BEFORE the view so Connections can bind to it
    QtObject {
        id: mockWalletSection
        
        property int totalFollowingCount: allAddressesModel.count  // Total from "server"
        property bool isLoading: loadingCheckbox.checked
        
        signal followingAddressesUpdated(string userAddress)
    }

    // Global context property (set early so view can access it)
    property var walletSectionFollowingAddresses: mockWalletSection

    // Function to load a specific page of data (simulates API call)
    function loadPage(search, limit, offset) {
        currentPageModel.clear()
        
        const startIdx = offset
        const endIdx = Math.min(offset + limit, allAddressesModel.count)
        
        logs.logEvent("Loading page: offset=%1, limit=%2, total=%3, showing=%4-%5"
            .arg(offset).arg(limit).arg(allAddressesModel.count).arg(startIdx).arg(endIdx-1))
        
        // Slice the data for current page
        for (let i = startIdx; i < endIdx; i++) {
            const item = allAddressesModel.get(i)
            currentPageModel.append({
                name: item.name,
                address: item.address,
                ensName: item.ensName,
                tags: item.tags,
                avatar: item.avatar
            })
        }
    }

    // Use the RootStore singleton stub and inject our model into it
    Component.onCompleted: {
        // Inject our current page model (what's displayed)
        WalletStores.RootStore.followingAddresses = currentPageModel
        WalletStores.RootStore.lastReloadTimestamp = Date.now() / 1000
        // Load initial page
        loadPage("", 10, 0)
    }

    // Timer to simulate async loading completion
    Timer {
        id: loadingCompleteTimer
        interval: 50
        onTriggered: {
            mockWalletSection.followingAddressesUpdated("")
            logs.logEvent("Loading complete - data refreshed")
        }
    }

    // Listen to RootStore refresh requests and complete them
    Connections {
        target: WalletStores.RootStore
        
        function onRefreshRequested(search, limit, offset) {
            logs.logEvent("refreshRequested - search: '%1', limit: %2, offset: %3"
                .arg(search).arg(limit).arg(offset))
            // Load the requested page
            root.loadPage(search, limit, offset)
            // Signal loading complete
            loadingCompleteTimer.restart()
        }
    }

    // Main view area
    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.baseColor3

        FollowingAddressesView {
            id: followingAddressesView
            anchors.fill: parent

            rootStore: WalletStores.RootStore  // Use the singleton stub
            contactsStore: SharedStores.ContactsStore
            networkConnectionStore: SharedStores.NetworkConnectionStore {}
            networksStore: SharedStores.NetworksStore {}

            onSendToAddressRequested: (address) => {
                logs.logEvent("sendToAddressRequested: " + address)
            }

            // Trigger initial load after view is created
            Component.onCompleted: {
                // Delay to let view initialize
                loadingCompleteTimer.start()
            }
        }
    }


    // Control panel
    Pane {
        SplitView.minimumWidth: 350
        SplitView.preferredWidth: 350

        ScrollView {
            anchors.fill: parent
            clip: true

            ColumnLayout {
                spacing: 16
                width: parent.width - 20

                Label {
                    text: "Following Addresses View"
                    font.pixelSize: 18
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "View State:"
                    font.bold: true
                }

                CheckBox {
                    id: loadingCheckbox
                    text: "Loading state (header spinner)"
                    checked: false
                }

                Label {
                    text: "Total: %1 | Showing: %2 | Page: ~%3"
                        .arg(allAddressesModel.count)
                        .arg(currentPageModel.count)
                        .arg(Math.floor(currentPageModel.count > 0 ? 1 : 0))
                    font.bold: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "Data Management:"
                    font.bold: true
                }

                Button {
                    Layout.fillWidth: true
                    text: "Add Random Address"
                    onClicked: {
                        const randomAddr = "0x" + Math.random().toString(16).substring(2, 42).padEnd(40, '0')
                        allAddressesModel.append({
                            name: "Random " + (allAddressesModel.count + 1),
                            address: randomAddr,
                            ensName: "",
                            tags: ["random"],
                            avatar: ""
                        })
                        root.loadPage("", 10, 0)  // Reload first page
                        mockWalletSection.followingAddressesUpdated("")
                        logs.logEvent("Added address. Total: " + allAddressesModel.count)
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Add 25 Addresses (Test Pagination)"
                    onClicked: {
                        for (let i = 0; i < 25; i++) {
                            const randomAddr = "0x" + Math.random().toString(16).substring(2, 42).padEnd(40, '0')
                            allAddressesModel.append({
                                name: "Test User " + (allAddressesModel.count + 1),
                                address: randomAddr,
                                ensName: "",
                                tags: ["test"],
                                avatar: ""
                            })
                        }
                        root.loadPage("", 10, 0)  // Reload first page
                        mockWalletSection.followingAddressesUpdated("")
                        logs.logEvent("Added 25 addresses. Total: " + allAddressesModel.count + " (pagination should appear!)")
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Remove Last Address"
                    enabled: allAddressesModel.count > 0
                    onClicked: {
                        if (allAddressesModel.count > 0) {
                            allAddressesModel.remove(allAddressesModel.count - 1)
                            root.loadPage("", 10, 0)  // Reload first page
                            mockWalletSection.followingAddressesUpdated("")
                            logs.logEvent("Removed address. Total: " + allAddressesModel.count)
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Clear All"
                    onClicked: {
                        allAddressesModel.clear()
                        currentPageModel.clear()
                        mockWalletSection.followingAddressesUpdated("")
                        logs.logEvent("Cleared all addresses")
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Reset to 8 Defaults"
                    onClicked: {
                        allAddressesModel.resetToDefaults()
                        root.loadPage("", 10, 0)  // Reload first page
                        mockWalletSection.followingAddressesUpdated("")
                        logs.logEvent("Reset to 8 default addresses")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "Features to Test:"
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    text: "Pagination:\n" +
                          "• Page Size: 10 per page\n" +
                          "• Click 'Add 25' to test pagination\n" +
                          "• Navigate pages at bottom\n" +
                          "• Each page shows ONLY 10 items\n\n" +
                          "Features:\n" +
                          "• Search bar - filter by name/address\n" +
                          "• Click address - opens activity popup\n" +
                          "• Click menu (...) - more actions\n" +
                          "• Click star - save/unsave\n" +
                          "• Click send - opens send modal\n" +
                          "• Reload button - refreshes current page\n" +
                          "• Add via EFP - opens EFP website"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: Theme.palette.baseColor1
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "Event Log:"
                    font.bold: true
                }

                LogsView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    logText: logs.logText
                }
            }
        }
    }

    Settings {
        property alias loading: loadingCheckbox.checked
    }
}

// category: Views
// status: good
