import QtQuick 2.0
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2
import utils 1.0
import shared.controls 1.0

import AppLayouts.Wallet.views.collectibles 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.helpers 1.0

StatusScrollView {
    id: root

    // User profile props
    required property bool isOwner
    required property bool isAdmin

    // General props
    property int viewWidth: 560 // by design
    property var model
    property string communityName
    readonly property int count: assetsModel.count + collectiblesModel.count

    signal itemClicked(string tokenKey,
                       int chainId,
                       string chainName,
                       string accountName,
                       string accountAddress)

    signal mintOwnerTokenClicked

    padding: 0

    QtObject {
        id: d

        readonly property int delegateAssetsHeight: 64

        function getDeployStateInfo(deployState) {
            if(deployState === Constants.ContractTransactionStatus.Failed)
                return qsTr("Minting failed")

            if(deployState === Constants.ContractTransactionStatus.InProgress)
                return qsTr("Minting...")

            return ""
        }

        function getRemainingInfo(isOwnerToken, isPrivilegedToken,
                                  remainingSupply, supply, isInfiniteSupply) {
            // Owner token use case:
            if(isOwnerToken)
                return qsTr("1 of 1 (you hodl)")

            // TMaster token use case:
            if(isPrivilegedToken)
                return "∞"

            // Rest of collectible cases:
            if(isInfiniteSupply)
                return qsTr("∞ remaining")

            return qsTr("%L1 / %L2 remaining").arg(remainingSupply).arg(supply)
        }
    }

    SortFilterProxyModel {
        id: assetsModel

        sourceModel: root.model
        filters: ValueFilter {
            roleName: "tokenType"
            value: Constants.TokenType.ERC20
        }
    }

    SortFilterProxyModel {
        id: collectiblesModel

        sourceModel: root.model
        filters: ValueFilter {
            roleName: "tokenType"
            value: Constants.TokenType.ERC721
        }
    }

    Loader {
        sourceComponent: root.count === 0 ? introComponent : mainLayoutComponent
    }

    Component {
        id: introComponent

        ColumnLayout {
             width: root.viewWidth
             spacing: 20

            IntroPanel {
                Layout.fillWidth: true

                image: Style.png("community/mint2_1")
                title: qsTr("Community tokens")
                subtitle: qsTr("You can mint custom tokens and import tokens for your community")
                checkersModel: [
                    qsTr("Create remotely destructible soulbound tokens for admin permissions"),
                    qsTr("Reward individual members with custom tokens for their contribution"),
                    qsTr("Mint tokens for use with community and channel permissions")
                ]
            }

            StatusInfoBoxPanel {

                readonly property bool isAdminOnly: root.isAdmin && !root.isOwner

                Layout.fillWidth: true
                Layout.bottomMargin: 20

                title: qsTr("Get started")
                text: isAdminOnly ? qsTr("Token minting can only be performed by admins that hodl the Community’s TokenMaster token. If you would like this permission, contact the Community founder (they will need to mint the Community Owner token before they can airdrop this to you)."):
                                    qsTr("In order to Mint, Import and Airdrop community tokens, you first need to mint your Owner token which will give you permissions to access the token management features for your community.")
                buttonText: qsTr("Mint Owner token")
                buttonVisible: root.isOwner
                horizontalPadding: 16
                verticalPadding: 20

                onClicked: root.mintOwnerTokenClicked()
            }
        }
    }

    Component {
        id: mainLayoutComponent

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
                model: assetsModel

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
                            text: d.getDeployStateInfo(model.deployState)
                            color: model.deployState === Constants.ContractTransactionStatus.Failed
                                   ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
                            font.pixelSize: 13
                        },
                        StatusIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "next"
                            color: Theme.palette.baseColor1
                        }
                    ]
                    onClicked: root.itemClicked(model.contractUniqueKey,
                                                model.chainId, model.chainName,
                                                model.accountName, model.address)
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
                    subTitle: deployState === Constants.ContractTransactionStatus.Completed ?
                                  d.getRemainingInfo(model.isOwner,
                                                     model.isPrivilegedToken,
                                                     model.remainingSupply,
                                                     model.supply,
                                                     model.infiniteSupply) :
                                  d.getDeployStateInfo(model.deployState)
                    subTitleColor: model.deployState === Constants.ContractTransactionStatus.Failed
                                   ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
                    fallbackImageUrl: model.image ? model.image : ""
                    backgroundColor: "transparent"
                    isLoading: false
                    navigationIconVisible: false
                    isPrivilegedToken: model.isPrivilegedToken
                    isOwner: model.isOwner
                    ornamentColor: model.color

                    onClicked: root.itemClicked(model.contractUniqueKey,
                                                model.chainId, model.chainName,
                                                model.accountName, model.address)
                }
            }

            // Empty placeholder when no collectibles; dashed rounded rectangle
            ShapeRectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: parent.width - 4 // The rectangular path is rendered outside
                Layout.preferredHeight: 44
                visible: collectiblesGrid.count === 0
                text: qsTr("You currently have no minted collectibles")
            }
        }
    }
}
