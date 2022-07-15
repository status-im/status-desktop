import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import Status.Wallet

Item {
    id: root

    /// WalletAccount
    required property var asset

    ColumnLayout {
        anchors.fill: parent

        Label {
            text: asset.name
        }
        Label {
            text: asset.address
        }
        TabBar {
            id: tabBar
            width: parent.width

            TabButton {
                text: qsTr("Assets")
            }
            TabButton {
                text: qsTr("Positions")
            }
        }

        SwipeView {
            id: swipeView

            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: tabBar.currentIndex

            interactive: false
            clip: true

            Loader {
                active: SwipeView.isCurrentItem
                sourceComponent: AssetView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    asset: root.asset
                }
            }

            Loader {
                active: SwipeView.isCurrentItem
                sourceComponent: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        anchors.centerIn: parent
                        text: "TODO"
                    }
                }
            }
        }
    }
}
