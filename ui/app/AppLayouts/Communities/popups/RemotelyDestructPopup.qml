import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

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

    // Fees related properties:
    property bool isFeeLoading
    property string feeText: ""
    property string feeErrorText: ""
    property string feeLabel: qsTr("Remotely destruct %1 token on %2").arg(root.collectibleName).arg(root.chainName)

    // Account expected roles: address, name, color, emoji, walletType
    property var accounts
    signal remotelyDestructClicked(int tokenCount, var remotelyDestructTokensList, string accountAddress)
    signal remotelyDestructFeesRequested(int tokenCount, var remotelyDestructTokensList, string accountAddress)

    QtObject {
        id: d

        property string accountAddress
        readonly property int maxHeight: 560 // by design
        property int tokenCount: 0
        readonly property ListModel selfDestructTokensList: ListModel {}
        readonly property bool isFeeError: root.feeErrorText !== ""

        function getVerticalPadding() {
            return root.topPadding + root.bottomPadding
        }

        function getHorizontalPadding() {
            return root.leftPadding + root.rightPadding
        }

        function updateTokensToDestruct(walletAddress, amount) {
            if(ModelUtils.contains(d.selfDestructTokensList, "walletAddress", walletAddress))
                clearTokensToDesctruct(walletAddress)

            d.selfDestructTokensList.append({"walletAddress": walletAddress,
                                            "amount": amount})
            updateTokensCount()
        }

        function clearTokensToDesctruct(walletAddress) {
            var index = ModelUtils.indexOf(d.selfDestructTokensList, "walletAddress", walletAddress)
            d.selfDestructTokensList.remove(index)
            updateTokensCount()
        }

       function updateTokensCount() {
           d.tokenCount = 0
           for(var i = 0; i < d.selfDestructTokensList.count; i ++)
               d.tokenCount += ModelUtils.get(d.selfDestructTokensList, i, "amount")
           if (d.tokenCount > 0) {
               root.remotelyDestructFeesRequested(d.tokenCount, d.selfDestructTokensList, d.accountAddress);
           }
       }
    }

    title: qsTr("Remotely destruct %1 token").arg(root.collectibleName)
    implicitWidth: 600 // by design
    padding: 0

    contentItem: ColumnLayout {
        spacing: Style.current.padding
        TokenHoldersPanel {
            id: tokenHoldersPanel
            tokenName: root.collectibleName
            Layout.fillWidth: true
            Layout.fillHeight: true
            isSelectorMode: true
            onSelfDestructAmountChanged: d.updateTokensToDestruct(walletAddress, amount)
            onSelfDestructRemoved: d.clearTokensToDesctruct(walletAddress)
        }

        FeesBox {
            id: feesBox

            Layout.fillWidth: true
            Layout.bottomMargin: 16
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            implicitWidth: 0
            accountErrorText: root.feeErrorText
            placeholderText: qsTr("Select a hodler to see remote destruction gas fees")
            showAccountsSelector: true
            model: d.tokenCount > 0 ? singleFeeModel : undefined            
            accountsSelector.model: root.accounts

            accountsSelector.onCurrentIndexChanged: {
                if (accountsSelector.currentIndex < 0)
                    return

                const item = ModelUtils.get(accountsSelector.model, accountsSelector.currentIndex)
                d.accountAddress = item.address

                // Whenever a change in the form happens, new fee calculation:
                if(d.tokenCount > 0)
                    root.remotelyDestructFeesRequested(d.tokenCount, d.selfDestructTokensList, d.accountAddress)
            }

            ModelChangeTracker {
                model: d.selfDestructTokensList

                // Whenever a change in the form happens, new fee calculation:
                onRevisionChanged: {
                    root.remotelyDestructFeesRequested(d.tokenCount, d.selfDestructTokensList, d.accountAddress)
                }
            }

            QtObject {
                id: singleFeeModel

                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: d.isFeeError
            }
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: {
                    root.close()
                }
            }
            StatusButton {
                enabled: d.tokenCount > 0
                text: qsTr("Remotely destruct %n token(s)", "", d.tokenCount)
                type: StatusBaseButton.Type.Danger
                onClicked:  root.remotelyDestructClicked(d.tokenCount,
                                                         ModelUtils.modelToArray(d.selfDestructTokensList,["walletAddress", "amount"]),
                                                         d.accountAddress)
            }
        }
    }
}
