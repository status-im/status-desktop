import QtQuick 2.13
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1

import shared.popups.send.controls 1.0

StatusDialog {
    id: root

    /* This should be the only property which should be used to input
    parameters to the modal when being launched from elsewhere */
    required property SwapInputParamsForm swapInputParamsForm
    required property SwapModalAdaptor swapAdaptor

    objectName: "swapModal"
    title: qsTr("Swap")

    bottomPadding: 16
    padding: 0

    background: StatusDialogBackground {
        implicitHeight: 846
        implicitWidth: 556
        color: Theme.palette.baseColor3
    }

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

    // This is a temporary placeholder while each of the components are  being added.
    contentItem: Column {
        spacing: 5
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("This area is a temporary placeholder")
            font.bold: true
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Selected network: %1").arg(swapInputParamsForm.selectedNetworkChainId)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Selected from token: %1").arg(swapInputParamsForm.fromTokensKey)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("from token amount: %1").arg(swapInputParamsForm.fromTokenAmount)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Selected to token: %1").arg(swapInputParamsForm.toTokenKey)
        }
    }
}

