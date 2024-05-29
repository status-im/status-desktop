import QtQuick 2.13
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1

import shared.popups.send.controls 1.0

import AppLayouts.Wallet.controls 1.0

StatusDialog {
    id: root

    /* This should be the only property which should be used to input
    parameters to the modal when being launched from elsewhere */
    required property SwapInputParamsForm swapInputParamsForm
    required property SwapModalAdaptor swapAdaptor

    objectName: "swapModal"

    implicitWidth: 556
    topPadding: 0
    bottomPadding: Style.current.padding
    leftPadding: Style.current.xlPadding
    rightPadding: Style.current.xlPadding
    backgroundColor: Theme.palette.baseColor3

    header: AccountsModalHeader {
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        control.popup.width: 512
        model: root.swapAdaptor.nonWatchAccounts
        getNetworkShortNames: root.swapAdaptor.getNetworkShortNames
        formatCurrencyAmount: root.swapAdaptor.formatCurrencyAmount
        /* TODO: once the Account Header is reworked we simply should be
        able to use an index and not this logic of selectedAccount being set */
        selectedAccount: root.swapAdaptor.getSelectedAccount(root.swapInputParamsForm.selectedAccountIndex)
        onSelectedIndexChanged: {
            root.swapInputParamsForm.selectedAccountIndex = selectedIndex
        }
    }

    contentItem: ColumnLayout {
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            HeaderTitleText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                id: modalHeader
                text: qsTr("Swap")
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                text: qsTr("On:")
                color: Theme.palette.baseColor1
                font.pixelSize: 13
                lineHeight: 38
                lineHeightMode: Text.FixedHeight
                verticalAlignment: Text.AlignVCenter
            }
            // TODO: update this once https://github.com/status-im/status-desktop/issues/14780 is ready
            NetworkFilter {
                id: networkFilter
                objectName: "networkFilter"
                Layout.alignment: Qt.AlignVCenter
                multiSelection: false
                flatNetworks: root.swapAdaptor.filteredFlatNetworksModel
                onToggleNetwork: (network) => {
                                     root.swapInputParamsForm.selectedNetworkChainId = network.chainId
                                 }
                Component.onCompleted: {
                    if(root.swapInputParamsForm.selectedNetworkChainId !== -1)
                        networkFilter.setChain(root.swapInputParamsForm.selectedNetworkChainId)
                }
            }
        }

        // This is a temporary placeholder while each of the components are  being added.
        StatusBaseText {
            topPadding: Style.current.padding
            text: qsTr("This area is a temporary placeholder")
            font.bold: true
        }
        StatusBaseText {
            text: qsTr("Selected from token: %1").arg(swapInputParamsForm.fromTokensKey)
        }
        StatusBaseText {
            text: qsTr("from token amount: %1").arg(swapInputParamsForm.fromTokenAmount)
        }
        StatusBaseText {
            text: qsTr("Selected to token: %1").arg(swapInputParamsForm.toTokenKey)
        }
    }
}

