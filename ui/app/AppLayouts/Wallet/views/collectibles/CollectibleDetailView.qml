import QtQuick 2.14
import QtQuick.Layouts 1.13
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Communities.panels 1.0

import utils 1.0
import shared.controls 1.0
import shared.views 1.0

import "../../stores"
import "../../controls"

Item {
    id: root

    signal launchTransactionDetail(string txID)

    required property var rootStore
    required property var walletRootStore
    required property var communitiesStore

    required property var collectible
    property var activityModel
    property bool isCollectibleLoading
    required property string addressFilters

    // Community related token props:
    readonly property bool isCommunityCollectible: !!collectible ? collectible.communityId !== "" : false
    readonly property bool isOwnerTokenType: !!collectible ? (collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) : false
    readonly property bool isTMasterTokenType: !!collectible ? (collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.TMaster) : false

    readonly property var communityDetails: isCommunityCollectible ? root.communitiesStore.getCommunityDetailsAsJson(collectible.communityId) : null

    QtObject {
        id: d
        readonly property string collectibleLink: !!collectible ? root.walletRootStore.getOpenSeaCollectibleUrl(collectible.networkShortName, collectible.contractAddress, collectible.tokenId): ""
        readonly property string collectionLink: !!collectible ? root.walletRootStore.getOpenSeaCollectionUrl(collectible.networkShortName, collectible.contractAddress): ""
        readonly property string blockExplorerLink: !!collectible ? root.walletRootStore.getExplorerUrl(collectible.networkShortName, collectible.contractAddress, collectible.tokenId): ""
        readonly property var addrFilters: root.addressFilters.split(":").map((addr) => addr.toLowerCase())
        readonly property int imageStackSpacing: 4

        property Component balanceTag: Component {
            CollectibleBalanceTag {
                balance: d.balanceAggregator.value
            }
        }
        property SortFilterProxyModel filteredBalances: SortFilterProxyModel {
            sourceModel: !!collectible ? collectible.ownership : null
            filters: [
                FastExpressionFilter {
                    expression: {
                        d.addrFilters
                        return d.addrFilters.includes(model.accountAddress.toLowerCase())
                    }
                    expectedRoles: ["accountAddress"]
                }
            ]
        }

        property SumAggregator balanceAggregator: SumAggregator {
            model: d.filteredBalances
            roleName: "balance"
        }
    }

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        collectibleName: !!collectible && !!collectible.name ? collectible.name : qsTr("Unknown")
        collectibleId: !!collectible ? "#" + collectible.tokenId : ""
        communityName: !!communityDetails ? communityDetails.name : ""
        communityId: !!collectible ? collectible.communityId : ""
        collectionName: !!collectible ? collectible.collectionName : ""
        communityImage: !!communityDetails ? communityDetails.image : ""
        networkShortName: !!collectible ? collectible.networkShortName : ""
        networkColor: !!collectible ?collectible.networkColor : ""
        networkIconURL: !!collectible ? collectible.networkIconUrl : ""
        networkExplorerName: !!collectible ? root.walletRootStore.getExplorerNameForNetwork(collectible.networkShortName): ""
        collectibleLinkEnabled: Utils.getUrlStatus(d.collectibleLink)
        collectionLinkEnabled: (!!communityDetails && communityDetails.name)  || Utils.getUrlStatus(d.collectionLink)
        explorerLinkEnabled: Utils.getUrlStatus(d.blockExplorerLink)
        onCollectionTagClicked: {
            if (root.isCommunityCollectible) {
                Global.switchToCommunity(collectible.communityId)
            }
            else {
                Global.openLinkWithConfirmation(d.collectionLink, root.walletRootStore.getOpenseaDomainName())
            }
        }
        onOpenCollectibleExternally: Global.openLinkWithConfirmation(d.collectibleLink, root.walletRootStore.getOpenseaDomainName())
        onOpenCollectibleOnExplorer: Global.openLinkWithConfirmation(d.blockExplorerLink, root.walletRootStore.getExplorerDomain(networkShortName))
    }

    Column {
        id: collectibleBody
        anchors.top: collectibleHeader.bottom
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        spacing: Style.current.padding

        Row {
            id: collectibleImageDetails

            readonly property real visibleImageHeight: artwork.height
            readonly property real visibleImageWidth: artwork.width

            height: collectibleImageDetails.visibleImageHeight
            width: parent.width
            spacing: 24

            ColumnLayout {
                id: artwork
                spacing: 0
                Repeater {
                    id: repeater
                    model: Math.min(3, d.balanceAggregator.value)                  
                    Item {
                        Layout.preferredWidth: childrenRect.width
                        Layout.preferredHeight: childrenRect.height
                        Layout.leftMargin: index * d.imageStackSpacing
                        Layout.topMargin: index === 0 ? 0 : -Layout.preferredHeight + d.imageStackSpacing
                        opacity: index === 0 ? 1: 0.4/index
                        // so that the first item remains on top in the stack
                        z: -index
                        Loader {
                            property int modelIndex: index
                            anchors.top: parent.top
                            anchors.left: parent.left
                            sourceComponent: root.isCommunityCollectible && (root.isOwnerTokenType || root.isTMasterTokenType) ? privilegedCollectibleImage: collectibleimage
                            active: root.visible
                        }
                        Loader {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: Style.current.padding
                            sourceComponent: d.balanceTag
                            // only show balance tag on top of the first image in stack
                            active: index === 0 && d.balanceAggregator.value > 1 && root.visible
                        }
                    }
                }
            }

            Column {
                id: collectibleNameAndDescription
                spacing: 12

                width: parent.width - collectibleImageDetails.visibleImageWidth - Style.current.bigPadding

                StatusBaseText {
                    id: collectibleName
                    width: parent.width
                    height: 24

                    text: root.isCommunityCollectible && !!communityDetails ? qsTr("Minted by %1").arg(root.communityDetails.name):
                                                                              !!collectible ? collectible.collectionName: ""
                    color: Theme.palette.directColor1
                    font.pixelSize: 17
                    lineHeight: 24
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                }

                StatusBaseText {
                    id: descriptionText
                    width: parent.width
                    height: collectibleImageDetails.height - collectibleName.height - parent.spacing

                    clip: true
                    text: !!collectible ? collectible.description : ""
                    textFormat: Text.MarkdownText
                    color: Theme.palette.directColor4
                    font.pixelSize: 15
                    lineHeight: 22
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                }
            }
        }

        StatusTabBar {
            id: collectiblesDetailsTab
            width: parent.width
            topPadding: Style.current.xlPadding
            visible: !!collectible && collectible.traits.count > 0

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Properties")
            }
            StatusTabButton {
                rightPadding: 0
                width: implicitWidth
                text: qsTr("Activity")
            }
        }

        StatusScrollView {
            id: scrollView
            width: parent.width
            height: parent.height
            contentWidth: availableWidth

            Loader {
                id: tabLoader
                width: parent.width
                height: parent.height

                sourceComponent: {
                    switch (collectiblesDetailsTab.currentIndex) {
                    case 0: return traitsView
                    case 1: return activityView
                    }
                }

                Component {
                    id: traitsView
                    Flow {
                        width: scrollView.availableWidth
                        spacing: 10
                        Repeater {
                            model: !!collectible ? collectible.traits: null
                            InformationTile {
                                maxWidth: parent.width
                                primaryText: model.traitType
                                secondaryText: model.value
                            }
                        }
                    }
                }

                Component {
                    id: activityView
                    StatusListView {
                        width: scrollView.availableWidth
                        height: scrollView.availableHeight
                        model: root.activityModel
                        delegate: TransactionDelegate {
                            required property var model
                            required property int index
                            width: parent.width
                            modelData: model.activityEntry
                            timeStampText: isModelDataValid ? LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000, true) : ""
                            rootStore: root.rootStore
                            walletRootStore: root.walletRootStore
                            showAllAccounts: root.walletRootStore.showAllAccounts
                            displayValues: true
                            community: isModelDataValid && !!communityId && !!root.communitiesStore ? root.communitiesStore.getCommunityDetailsAsJson(communityId) : null
                            loading: false
                            onClicked: {
                                if (mouse.button === Qt.RightButton) {
                                    // TODO: Implement context menu
                                } else {
                                    root.launchTransactionDetail(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: privilegedCollectibleImage
        // Special artwork representation for community `Owner and Master Token` token types:
        PrivilegedTokenArtworkPanel {
            size: PrivilegedTokenArtworkPanel.Size.Large
            artwork: collectible.imageUrl ?? ""
            color: !!root.collectible && !!root.communityDetails ? root.communityDetails.color : "transparent"
            isOwner: root.isOwnerTokenType
        }
    }

    Component {
        id: collectibleimage
         StatusRoundedMedia {
                id: collectibleImage
                readonly property bool isEmpty: !mediaUrl.toString() && !fallbackImageUrl.toString()
                width: 248
                height: width
                radius: Style.current.radius
                color: isError || isEmpty ? Theme.palette.baseColor5 : collectible.backgroundColor
                border.color: Theme.palette.directColor8
                border.width: 1
                mediaUrl: collectible.mediaUrl ?? ""
                mediaType: modelIndex === 0 && !!collectible ? collectible.mediaType : ""
                fallbackImageUrl: collectible.imageUrl

                Column {
                    anchors.centerIn: parent
                    visible: collectibleImage.isError || collectibleImage.isEmpty
                    spacing: 10

                    StatusIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: "frowny"
                        opacity: 0.1
                        color: Theme.palette.directColor1
                    }
                    StatusBaseText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Qt.AlignHCenter
                        color: Theme.palette.directColor6
                        text: {
                            if (collectibleImage.isError && collectibleImage.componentMediaType === StatusRoundedMedia.MediaType.Unkown) {
                                return qsTr("Unsupported\nfile format")
                            }
                            if (!collectible.description && !collectible.name) {
                                return qsTr("Info can't\nbe fetched")
                            }
                            return qsTr("Failed\nto load")
                        }
                    }
                }
            }
    }
}
