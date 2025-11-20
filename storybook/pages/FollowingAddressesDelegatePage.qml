import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.Wallet.controls
import AppLayouts.Wallet.stores as WalletStores
import shared.stores as SharedStores

import Models
import Storybook
import utils

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            color: Theme.palette.baseColor3

            FollowingAddressesDelegate {
                id: delegate

                anchors.centerIn: parent
                width: 600

                // Properties
                title: titleField.text
                address: addressField.text
                ensName: ensField.text
                tags: tagsField.text.split(",").map(t => t.trim()).filter(t => t.length > 0)
                avatar: avatarField.text

                // Stores (mock)
                rootStore: WalletStores.RootStore
                networkConnectionStore: SharedStores.NetworkConnectionStore {}
                activeNetworksModel: NetworksModel.flatNetworks

                // Signals
                onClicked: logs.logEvent("delegate clicked")
                onMenuRequested: (name, address, ensName, tags) => {
                    logs.logEvent("menuRequested: name=%1, address=%2, ens=%3, tags=%4"
                        .arg(name).arg(address).arg(ensName).arg(tags.join(",")))
                }
            }
        }

        LogsView {
            SplitView.preferredHeight: 150
            SplitView.fillWidth: true
            logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 350
        SplitView.preferredWidth: 350

        ScrollView {
            anchors.fill: parent
            clip: true

            ColumnLayout {
                spacing: 12
                width: parent.width - 20

                Label {
                    text: "Delegate Properties"
                    font.pixelSize: 18
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "Title:"
                    font.bold: true
                }
                TextField {
                    id: titleField
                    Layout.fillWidth: true
                    text: "vitalik.eth"
                    placeholderText: "Display name"
                }

                Label {
                    text: "Address:"
                    font.bold: true
                }
                TextField {
                    id: addressField
                    Layout.fillWidth: true
                    text: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
                    placeholderText: "0x..."
                }

                Label {
                    text: "ENS Name:"
                    font.bold: true
                }
                TextField {
                    id: ensField
                    Layout.fillWidth: true
                    text: "vitalik.eth"
                    placeholderText: "name.eth"
                }

                Label {
                    text: "Tags (comma separated):"
                    font.bold: true
                }
                TextField {
                    id: tagsField
                    Layout.fillWidth: true
                    text: "friend, developer, ethereum"
                    placeholderText: "tag1, tag2, tag3"
                }

                Label {
                    text: "Avatar (icon name):"
                    font.bold: true
                }
                TextField {
                    id: avatarField
                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "Leave empty for default"
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "Test Scenarios:"
                    font.pixelSize: 16
                    font.bold: true
                }

                Button {
                    Layout.fillWidth: true
                    text: "Load: Saved Address (ends with 5c)"
                    onClicked: {
                        addressField.text = "0x929d0D5Cbc5228543Fa9b7df766CFf42C8c8975c"
                        titleField.text = "Mock Saved Name"
                        ensField.text = ""
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Load: ENS with No Save"
                    onClicked: {
                        addressField.text = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
                        titleField.text = "vitalik.eth"
                        ensField.text = "vitalik.eth"
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Load: Address Only"
                    onClicked: {
                        addressField.text = "0x1234567890123456789012345678901234567890"
                        titleField.text = "0x1234567890123456789012345678901234567890"
                        ensField.text = ""
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.palette.baseColor2
                }

                Label {
                    text: "Tips:"
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    text: "• Addresses ending in '5c' or '42' are mocked as 'saved'\n" +
                          "• Click delegate to open activity popup\n" +
                          "• Click menu button to test menu signal\n" +
                          "• Click star to test save/unsave\n" +
                          "• Avatar defaults to letter identicon if empty"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: Theme.palette.baseColor1
                }
            }
        }
    }
}

// category: Controls  
// status: good

