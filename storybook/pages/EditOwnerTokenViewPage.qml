import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel

import StatusQ.Core.Theme
import StatusQ.Components

import AppLayouts.Communities.views

import Storybook
import Models

import utils

SplitView {

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Timer {
                id: feeCalculationTimer

                interval: 2000

                onTriggered: {
                    editOwnerTokenView.feeText = "0.0015 ETH ($75.43)"
                    editOwnerTokenView.isFeeLoading = false
                }
            }

            EditOwnerTokenView {
                id: editOwnerTokenView

                anchors.fill: parent
                anchors.margins: 50

                preferredContentWidth: 560
                internalRightPadding: 50

                communityName: communityName.text
                communityLogo: doodles.checked ? ModelsData.collectibles.doodles : ModelsData.collectibles.mana
                communityColor: color1.checked ?  "#FFC4E9" : "#f44336"
                ownerToken.chainId: 42161

                flatNetworks: SortFilterProxyModel {
                    sourceModel: NetworksModel.flatNetworks
                    filters: ValueFilter { roleName: "isTest"; value: false }
                }
                accounts: WalletAccountsModel {}
                ownerToken.accountAddress: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881"

                onMintClicked: logs.logEvent("EditOwnerTokenView::onMintClicked")

                Component.onCompleted: {
                    feeText = ""
                    feeErrorText = ""
                    isFeeLoading = true

                    feeCalculationTimer.restart()
                }
            }
        }


        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText

            ColumnLayout {

                RowLayout {
                    Label {
                        text: "Community name:"
                    }

                    TextInput {
                        id: communityName
                        text: "Doodles"
                    }
                }

                RowLayout {
                    RadioButton {
                        id: color1

                        text: "Light pink"
                        checked: true
                    }

                    RadioButton {
                        text: "Orange"
                    }
                }

                RowLayout {
                    RadioButton {
                        id: doodles
                        text: "Doodles"
                        checked: true
                    }

                    RadioButton {
                        text: "Mana"
                    }
                }
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=34794-590207&mode=design&t=ZnwK9yenS5oSgwws-0
