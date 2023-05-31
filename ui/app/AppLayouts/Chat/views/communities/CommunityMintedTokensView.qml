import QtQuick 2.0
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import AppLayouts.Wallet.views.collectibles 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property var model

    signal itemClicked(int index,
                       int chainId,
                       string contractUniqueKey,
                       string chainName,
                       string accountName,
                       string accountAddress)

    QtObject {
        id: d

        function getSubtitle(deployState, remainingTokens, supply) {
            if(deployState === Constants.ContractTransactionStatus.Failed) {
                return qsTr("Minting failed")
            }

            if(deployState === Constants.ContractTransactionStatus.InProgress) {
                return qsTr("Minting...")
            }

            // TO REMOVE: Just added bc backend still doesn't have `availableTokens` property in model. Once it is added, the following 2 lines can be removed.
            if(!remainingTokens)
                remainingTokens = 0
            if(supply === 0)
                supply = "∞"
            return  qsTr("%1 / %2 remaining").arg(remainingTokens).arg(supply)
        }
    }

    padding: 0

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        StatusBaseText {
            text: qsTr("Collectibles")
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.baseColor1
        }

        StatusGridView {
            id: gridView

            Layout.fillWidth: true
            Layout.preferredHeight: 500 // TODO
            model: root.model
            cellHeight: 229
            cellWidth: 176
            delegate: CollectibleView {
                height: gridView.cellHeight
                width: gridView.cellWidth
                title: model.name ? model.name : "..."
                subTitle: d.getSubtitle(model.deployState, model.remainingTokens, model.supply)
                subTitleColor: (model.deployState === Constants.ContractTransactionStatus.Failed) ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
                fallbackImageUrl: model.image ? model.image : ""
                backgroundColor: model.backgroundColor ? model.backgroundColor : "transparent" // TODO BACKEND
                isLoading: false
                navigationIconVisible: true

                onClicked: root.itemClicked(model.index, model.chainId, model.contractUniqueKey, model.chainName, model.accountName, model.address)
            }
        }
    }
}
