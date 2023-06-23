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

    TokenHoldersPanel {
        id: tokenHoldersPanel

        anchors.fill: parent
        padding: 16
        tokenName: root.collectibleName
        isSelectorMode: true

        onSelfDestructAmountChanged: d.updateTokensToDestruct(walletAddress, amount)
        onSelfDestructRemoved: d.clearTokensToDesctruct(walletAddress)
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
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
