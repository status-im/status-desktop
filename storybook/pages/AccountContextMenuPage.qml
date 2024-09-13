import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.views 1.0

import utils 1.0

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
