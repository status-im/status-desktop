import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import Status.Wallet

import "SavedAddresses"

Item {
    id: root

    required property WalletAccount account
    required property AccountAssetsController assetController

    ColumnLayout {
        anchors.fill: parent

        Label {
            text: account.name
        }
        Label {
            text: account.address
        }
        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton {
                text: qsTr("Assets")
            }
            TabButton {
                text: qsTr("Positions")
            }
            TabButton {
                text: qsTr("Saved Addresses")
            }
        }

        SwipeView {
            id: swipeView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10

            currentIndex: tabBar.currentIndex

            interactive: false
            clip: true

            Loader {
                active: SwipeView.isCurrentItem && root.assetController && root.account
                sourceComponent: AssetView {
                    Rectangle {
                        anchors.fill: parent
                        color: "#66000066"
                        border.width: 1
                    }
                    width: swipeView.width
                    height: swipeView.height

                    assetController: root.assetController
                    account: root.account
                }
            }

            Loader {
                active: SwipeView.isCurrentItem
                sourceComponent: Item {
                    Label {
                        anchors.centerIn: parent
                        text: "TODO"
                    }
                }
            }

            Loader {
                active: SwipeView.isCurrentItem
                sourceComponent: SavedAddressesView {
                    savedAddressesController: WalletController.createSavedAddressesController()
                }
            }
        }
    }
}
