import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SortFilterProxyModel

import AppLayouts.Wallet.stores
import AppLayouts.Wallet.adaptors

import StatusQ.Core.Utils

import Storybook
import Models

import shared.stores
import utils

Item {
    id: root

    QtObject {
        id: d

        readonly property int selectedNetworkChainId: ctrlSelectedNetworkChainId.currentValue

        readonly property var assetsModel: TokenGroupsModel {}
        readonly property var flatNetworks: NetworksModel.flatNetworks
    }

    PaymentRequestAdaptor {
        id: adaptor
        selectedNetworkChainId: d.selectedNetworkChainId
        tokenGroupsModel: d.assetsModel
        flatNetworksModel: d.flatNetworks
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.topMargin: 10

            Label {
                text: "Chain:"
            }
            ComboBox {
                Layout.fillWidth: true
                id: ctrlSelectedNetworkChainId
                model: d.flatNetworks
                textRole: "chainName"
                valueRole: "chainId"
                displayText: currentText
                currentIndex: 0
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: "lightgray"
        }

        RowLayout {
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignHCenter
                    font.bold: true
                    text: "Input"
                }
                GenericListView {
                    label: "Tokens model"

                    model: d.assetsModel

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    roles: ["key", "name", "symbol"]
                    skipEmptyRoles: true
                    insetComponent: Label {
                        text: {
                            if (!model)
                                return ""
                            let chains = "Chains: \n" + JSON.stringify(ModelUtils.modelToFlatArray(model["addressPerChain"], "chainId"))
                            chains = chains.replace(/,/g, '\n')
                            return chains
                        }
                    }
                }
                GenericListView {
                    label: "Networks model"

                    model: d.flatNetworks

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    roles: ["chainId", "chainName",]
                    skipEmptyRoles: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignHCenter
                    font.bold: true
                    text: "Output"
                }
                GenericListView {
                    label: "Recipient model: " + count

                    model: adaptor.outputModel

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    roles: ["tokensKey", "name", "symbol", "iconSource", "currencyBalanceAsString", "sectionName"]

                    skipEmptyRoles: true
                }
            }
        }
    }
}

// category: Adaptors
