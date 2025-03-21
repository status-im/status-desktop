import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

StatusDialog {
    id: root

    property alias model: tokenHoldersPanel.model
    property string collectibleName
    property string chainName
    property string networkThatIsNotActive

    // Fees related properties:
    property bool isFeeLoading
    property string feeText: ""
    property string feeErrorText: ""
    property string feeLabel: qsTr("Remotely destruct %1 token on %2").arg(root.collectibleName).arg(root.chainName)

    readonly property alias tokenCount: d.tokenCount
    readonly property string selectedAccount: d.accountAddress
    readonly property var selectedWalletsAndAmounts: {
        //depedency
        d.tokenCount
        return ModelUtils.modelToArray(d.walletsAndAmountsList)
    }

    // Account expected roles: address, name, color, emoji, walletType
    property var accounts

    signal remotelyDestructClicked(var walletsAndAmounts, string accountAddress)
    signal enableNetwork
    signal calculateFees()
    signal stopUpdatingFees()

    QtObject {
        id: d

        property string accountAddress
        readonly property int maxHeight: 560 // by design
        property int tokenCount: 0
        readonly property ListModel walletsAndAmountsList: ListModel {}
        readonly property bool isFeeError: root.feeErrorText !== ""

        function getVerticalPadding() {
            return root.topPadding + root.bottomPadding
        }

        function getHorizontalPadding() {
            return root.leftPadding + root.rightPadding
        }

        function updateTokensToDestruct(walletAddress, amount) {
            const index = ModelUtils.indexOf(d.walletsAndAmountsList,
                                             "walletAddress", walletAddress)

            if (index !== -1)
                d.walletsAndAmountsList.setProperty(index, "amount", amount)
            else
                d.walletsAndAmountsList.append({ walletAddress, amount })

            updateTokensCount()
        }

        function clearTokensToDestruct(walletAddress) {
            const index = ModelUtils.indexOf(d.walletsAndAmountsList,
                                             "walletAddress", walletAddress)
            d.walletsAndAmountsList.remove(index)
            updateTokensCount()
        }

        function updateTokensCount() {
            const amounts = ModelUtils.modelToFlatArray(
                              d.walletsAndAmountsList, "amount")
            const sum = amounts.reduce((a, b) => a + b, 0)
            d.tokenCount = sum
        }
    }

    title: qsTr("Remotely destruct %1 token").arg(root.collectibleName)
    implicitWidth: 600 // by design
    padding: 0

    contentItem: ColumnLayout {
        spacing: Theme.padding
        TokenHoldersPanel {
            id: tokenHoldersPanel
            tokenName: root.collectibleName
            Layout.fillWidth: true
            Layout.fillHeight: true
            isSelectorMode: true
            onSelfDestructAmountChanged: d.updateTokensToDestruct(walletAddress, amount)
            onSelfDestructRemoved: d.clearTokensToDestruct(walletAddress)
        }

        StatusSwitch {
            id: showFees
            enabled: d.tokenCount > 0
            text: qsTr("Show fees (will be enabled once the form is filled)")

            onCheckedChanged: {
                if(checked) {
                    root.calculateFees()
                    return
                }
                root.stopUpdatingFees()
            }
        }

        FeesBox {
            id: feesBox

            visible: showFees.checked

            Layout.fillWidth: true
            Layout.bottomMargin: networkWarningPanel.visible ? 0 : 16
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            implicitWidth: 0
            accountErrorText: root.feeErrorText
            placeholderText: qsTr("Select a hodler to see remote destruction gas fees")
            showAccountsSelector: true
            model: d.tokenCount > 0 ? singleFeeModel : undefined
            accountsSelector.model: root.accounts

            Binding {
                target: d
                property: "accountAddress"
                value: feesBox.accountsSelector.currentAccountAddress
            }

            QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: d.isFeeError
            }
        }

        NetworkWarningPanel {
            id: networkWarningPanel

            visible: !!root.networkThatIsNotActive
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            Layout.leftMargin: 18
            Layout.rightMargin: 18

            networkThatIsNotActive: root.chainName
            onEnableNetwork: root.enableNetwork()
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: {
                    root.stopUpdatingFees()
                    root.close()
                }
            }
            StatusButton {
                text: qsTr("Remotely destruct %n token(s)", "", d.tokenCount)
                enabled: showFees.checked
                type: StatusBaseButton.Type.Danger

                onClicked: {
                    const walletsAndAmounts = ModelUtils.modelToArray(
                                                d.walletsAndAmountsList)

                    root.remotelyDestructClicked(walletsAndAmounts,
                                                 d.accountAddress)
                }
            }
        }
    }
}
