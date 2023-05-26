import QtQuick 2.0
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2
import utils 1.0
import shared.controls 1.0

import AppLayouts.Wallet.views.collectibles 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property var model

    signal itemClicked(string contractUniqueKey,
                       int chainId,
                       string chainName,
                       string accountName,
                       string accountAddress)

    QtObject {
        id: d

        readonly property int delegateAssetsHeight: 64

        function getSubtitle(deployState, remainingTokens, supply, isCollectible) {
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
            return isCollectible ? qsTr("%1 / %2 remaining").arg(remainingTokens).arg(supply) :  ""
        }
    }

    padding: 0

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.halfPadding

        StatusBaseText {
            Layout.leftMargin: Style.current.padding

            text: qsTr("Assets")
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.baseColor1
        }

        StatusListView {
            id: assetsList

            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            visible: count > 0
            model: SortFilterProxyModel {
                sourceModel: root.model
                filters: ValueFilter {
                    roleName: "tokenType"
                    value: Constants.TokenType.ERC20
                }
            }
            delegate: StatusListItem {
                height: 64
                width: mainLayout.width
                title: model.name
                subTitle: model.symbol
                asset.name: model.image ? model.image : ""
                asset.isImage: true
                components: [
                    StatusBaseText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: d.getSubtitle(model.deployState, model.remainingTokens, model.supply, false)
                        color: (model.deployState === Constants.ContractTransactionStatus.Failed) ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
                        font.pixelSize: 13
                    },
                    StatusIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "next"
                        color: Theme.palette.baseColor1
                    }
                ]
                onClicked: root.itemClicked(model.contractUniqueKey, model.chainId, model.chainName, model.accountName, model.address)
            }
        }

        // Empty placeholder when no assets; dashed rounded rectangle
        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // The rectangular path is rendered outside
            Layout.preferredHeight: 44
            visible: assetsList.count === 0
            text: qsTr("You currently have no minted assets")
        }

        StatusBaseText {
            Layout.leftMargin: Style.current.padding
            Layout.topMargin: Style.current.halfPadding

            text: qsTr("Collectibles")
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.baseColor1
        }

        StatusGridView {
            id: collectiblesGrid

            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            visible: count > 0
            model: SortFilterProxyModel {
                sourceModel: root.model
                filters: ValueFilter {
                    roleName: "tokenType"
                    value: Constants.TokenType.ERC721
                }
            }
            cellHeight: 229
            cellWidth: 176
            leftMargin: 16
            delegate: CollectibleView {
                height: collectiblesGrid.cellHeight
                width: collectiblesGrid.cellWidth
                title: model.name ? model.name : "..."
                subTitle: d.getSubtitle(model.deployState, model.remainingTokens, model.supply, true)
                subTitleColor: (model.deployState === Constants.ContractTransactionStatus.Failed) ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
                fallbackImageUrl: model.image ? model.image : ""
                backgroundColor: "transparent"
                isLoading: false
                navigationIconVisible: true

                onClicked: root.itemClicked(model.contractUniqueKey, model.chainId, model.chainName, model.accountName, model.address)
            }
        }

        // Empty placeholder when no collectibles; dashed rounded rectangle
        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // The rectangular path is rendered outside
            Layout.preferredHeight: 44
            visible: collectiblesGrid.count == 0
            text: qsTr("You currently have no minted collectibles")
        }
    }
}
