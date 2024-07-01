import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.controls 1.0

import shared.controls 1.0

Rectangle {
    id: contextCard

    implicitWidth: contextLayout.implicitWidth
    implicitHeight: contextLayout.implicitHeight

    radius: 8
    // TODO: the color matched the design color (grey4); It is also matching the intention or we should add some another color to the theme? (e.g. sectionBorder)?
    border.color: Theme.palette.baseColor2
    border.width: 1
    color: "transparent"

    ColumnLayout {
        id: contextLayout

        anchors.fill: parent

        RowLayout {
            Layout.margins: 16

            StatusBaseText {
                text: qsTr("Connect with")

                Layout.fillWidth: true
            }

            AccountSelector {
                id: accountsDropdown

                Layout.preferredWidth: 204

                control.enabled: d.connectionStatus === root.notConnectedStatus && count > 1
                model: d.accountsProxy
                onCurrentAccountChanged: d.selectedAccount = currentAccount
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: contextCard.border.color
        }

        RowLayout {
            Layout.margins: 16

            StatusBaseText {
                text: qsTr("On")

                Layout.fillWidth: true
            }

            NetworkFilter {
                id: networkFilter
                Layout.preferredWidth: accountsDropdown.Layout.preferredWidth

                flatNetworks: d.filteredChains
                showTitle: true
                multiSelection: true
                selectionAllowed: d.connectionStatus === root.notConnectedStatus && d.allChainIdsAggregator.value.length > 1
                selection: d.selectedChains

                onSelectionChanged: {
                    if (d.selectedChains !== networkFilter.selection) {
                        d.selectedChains = networkFilter.selection
                    }
                }
            }
        }
    }
}
