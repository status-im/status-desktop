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
import SortFilterProxyModel 0.2

import utils 1.0

StatusDialog {
    id: root

    property alias model: tokenHoldersPanel.model
    property string collectibleName
    property string chainName
    property string totalFeeText
    property bool isFeeLoading
    property string feeErrorText: ""
    property string generalAccountErrorText: ""
    property string feeLabel: qsTr("Remotely destruct %1 token on %2").arg(root.collectibleName).arg(root.chainName)
    property string feePlaceholderText: qsTr("Select a hodler to see remote destruction gas fees")
    // Account expected roles: address, name, color, emoji, walletType
    property var accounts
    signal remotelyDestructClicked(int tokenCount, var remotelyDestructTokensList)


    QtObject {
        id: d

        readonly property int maxHeight: 560 // by design
        property int tokenCount: 0
        readonly property ListModel selfDestructTokensList: ListModel {}

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
       }
    }

    title: qsTr("Remotely destruct %1 token").arg(root.collectibleName)
    implicitWidth: 600 // by design
    padding: 0

    contentItem: ColumnLayout {
        spacing: 16
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
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitWidth: 0
            totalFeeText: root.totalFeeText
            generalErrorText: root.generalAccountErrorText
            accountErrorText: root.feeErrorText
            placeholderText: root.feePlaceholderText
            showAccountsSelector: true
            model: d.tokenCount > 0 ? singleFeeModel : undefined
            accountsSelector.model: SortFilterProxyModel {
                sourceModel: root.accounts
                proxyRoles: [
                    ExpressionRole {
                        name: "color"
                        function getColor(colorId) {
                            return Utils.getColorForId(colorId)
                        }
                        // Direct call for singleton function is not handled properly by
                        // SortFilterProxyModel that's why helper function is used instead.
                        expression: { return getColor(model.colorId) }
                    }
                ]
                filters: ValueFilter {
                    roleName: "walletType"
                    value: Constants.watchWalletType
                    inverted: true
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
                                                    ModelUtils.modelToArray(d.selfDestructTokensList,
                                                                            ["walletAddress", "amount"]))
            }
        }
    }
}
