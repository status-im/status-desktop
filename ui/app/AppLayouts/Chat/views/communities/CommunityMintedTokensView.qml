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

    signal itemClicked(int deployState,
                       string name,
                       string artworkSource,
                       string symbol,
                       string description,
                       int supply,
                       bool infiniteSupply,
                       bool transferable,
                       bool selfDestruct,
                       int chainId,
                       string chainName,
                       string chainIcon,
                       string accountName)


    enum DeployState {
          Failed,
          InProgress,
          Deployed
    }

    QtObject {
        id: d

        function getStateText(deployState) {
            if(deployState === CommunityMintedTokensView.DeployState.Failed) {
                return qsTr("Failed")
            }

            if(deployState === CommunityMintedTokensView.DeployState.InProgress) {
                return qsTr("Minting...")
            }
            return ""
        }
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
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
                subTitle: d.getStateText(model.deployState)
                imageUrl: model.image ? model.image : ""
                backgroundColor: model.backgroundColor ? model.backgroundColor : "transparent" // TODO BACKEND
                isLoading: false
                navigationIconVisible: true

                onClicked: root.itemClicked(model.deployState,
                                            model.name,
                                            model.image,
                                            model.symbol,
                                            model.description,
                                            model.supply,
                                            model.infiniteSupply,
                                            model.transferable,
                                            model.remoteSelfDestruct,
                                            model.chainId,
                                            model.chainName,
                                            model.chainIcon,
                                            model.accountName)


            }
        }
    }
}
