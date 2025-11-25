import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.Wallet.controls
import AppLayouts.Wallet.stores as WalletStores

import Models
import Storybook
import utils

SplitView {
    id: root

    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

        Button {
            anchors.centerIn: parent
            text: "Show Following Address Menu"
            onClicked: menu.popup()
        }

        FollowingAddressMenu {
            id: menu
            anchors.centerIn: parent

            // Pass mock rootStore (using singleton stub)
            rootStore: WalletStores.RootStore

            name: nameField.text
            address: addressField.text
            ensName: ensField.text
            tags: tagsField.text.split(",").map(t => t.trim()).filter(t => t.length > 0)
            
            activeNetworksModel: NetworksModel.flatNetworks
        }
    }

    Pane {
        SplitView.minimumWidth: 350
        SplitView.preferredWidth: 350

        ScrollView {
            anchors.fill: parent

            ColumnLayout {
                spacing: 12
                width: parent.width

                Label {
                    text: "Name:"
                    font.bold: true
                }
                TextField {
                    id: nameField
                    Layout.fillWidth: true
                    text: "vitalik.eth"
                    placeholderText: "Name or ENS"
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
                    text: "friend, developer"
                    placeholderText: "tag1, tag2"
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
                    Layout.preferredHeight: 150
                    logText: logs.logText
                }
            }
        }
    }
}

// category: Controls
// status: good

