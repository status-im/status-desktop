import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.views 1.0
import StatusQ.Core.Theme 0.1
import utils 1.0

import Qt.labs.settings 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            color: Theme.palette.statusListItem.backgroundColor
            border.color: Theme.palette.primaryColor1
            border.width: 1

            anchors.fill: delegate
            anchors.margins: -30
        }

        TokenSelectorCollectibleDelegate {
            id: delegate

            implicitWidth: 330
            anchors.centerIn: parent

            name: nameTextField.text
            balance: balanceSpinBox.value ? balanceSpinBox.value : ""
            image: Constants.tokenIcon("ETH")
            networkIcon: "network/Network=Ethereum"

            goDeeperIconVisible: goDeeperSwitch.checked

            interactive: interactiveSwitch.checked
            highlighted: highlightedSwitch.checked
            isAutoHovered: ctrlIsAutoHovered.checked
        }
    }

    Pane {
        SplitView.minimumHeight: 250
        SplitView.preferredHeight: 250

        RowLayout {
            anchors.fill: parent

            ColumnLayout {
                RowLayout {
                    Label {
                        text: "name:"
                    }

                    TextField {
                        id: nameTextField

                        text: "Crypto Kitties"
                    }
                }

                RowLayout {
                    Label {
                        text: "balance:"
                    }

                    SpinBox {
                        id: balanceSpinBox

                        value: 12

                        from: 0
                        to: 20
                    }
                }

                Switch {
                    id: interactiveSwitch
                    text: "Interactive"
                    checked: true
                }

                Switch {
                    id: highlightedSwitch
                    text: "Highlighted"
                    checked: false
                }

                Switch {
                    id: goDeeperSwitch
                    text: "Go deeper icon visible"
                    checked: false
                }

                Switch {
                    id: ctrlIsAutoHovered
                    text: "isAutoHovered"
                    checked: false
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    Settings {
        property alias interactiveSwitchChecked: interactiveSwitch.checked
        property alias highlightedSwitchChecked: highlightedSwitch.checked
        property alias goDeeperSwitchChecked: goDeeperSwitch.checked
    }
}

// category: Delegates
