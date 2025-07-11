import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.Wallet.views

import utils

SplitView {
    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        clip: true

        Button {
            anchors.centerIn: parent
            text: "Show menu"
            onClicked: {
                menu.popup()
            }
        }

        AccountContextMenu {
            id: menu
            anchors.centerIn: parent

            name: walletAccountCheckbox.checked ? "Test name" : ""
            address: walletAccountCheckbox.checked ? "0x1234567890" : ""
            canDelete: canDeleteCheckbox.checked
            walletType: watchOnlyCheckbox.checked ? Constants.watchWalletType : ""
            canAddWatchOnlyAccount: canAddWatchOnlyAccountCheckbox.checked
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {
            anchors.fill: parent

            ColumnLayout {
                spacing: 16
                CheckBox {
                    id: walletAccountCheckbox
                    text: "Wallet account"
                    checked: true
                }
                CheckBox {
                    id: canDeleteCheckbox
                    text: "Can delete"
                    checked: true
                }
                CheckBox {
                    id: watchOnlyCheckbox
                    text: "Is watch only"
                    checked: true
                }
                CheckBox {
                    id: canAddWatchOnlyAccountCheckbox
                    text: "Can add watch only"
                    checked: false
                }
            }
        }
    }
}
