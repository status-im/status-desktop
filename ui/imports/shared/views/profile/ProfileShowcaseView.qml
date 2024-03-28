import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import SortFilterProxyModel 0.2

import utils 1.0
import shared.controls 1.0 // Timer // ExpandableTag
import shared.controls.delegates 1.0
import AppLayouts.Communities.controls 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

Control {
    id: root

    property alias currentTabIndex: stackLayout.currentIndex

    property string publicKey
    property string mainDisplayName
    property bool readOnly
    property var profileStore
    property var walletStore
    property var networkConnectionStore
    property var enabledNetworks
    property var socialLinks
    property var assetsModel
    property var collectiblesModel

    property bool livePreview: false
    property var livePreviewValues: ({})

    signal closeRequested()

    onVisibleChanged: if (visible && !livePreview) profileStore.requestProfileShowcase(publicKey)

    horizontalPadding: readOnly ? 20 : 40 // smaller in settings/preview
    topPadding: Style.current.bigPadding

    StatusQUtils.QObject {
        id: d

        property int delegateWidthS: 152
        property int delegateHeightS: 152
        property int delegateWidthM: 202
        property int delegateHeightM: 160

        property bool menuOpened: false

        readonly property string copyLiteral: qsTr("Copy")

        readonly property var timer: Timer {
            id: timer
        }

        readonly property var communitiesModel: root.livePreview ? liveCommunitiesModel
                                                                 : communitiesStoreModel
        readonly property var accountsModel: root.livePreview ? root.livePreviewValues.accountsModel
                                                              : accountsStoreModel
        readonly property var collectiblesModel: root.livePreview ? root.livePreviewValues.collectiblesModel
                                                                  : collectiblesStoreModel
        // TODO: add dirty values to the livePreviewValues once assets are supported
        // readonly property assetsModel: root.livePreview ? root.livePreviewValues.assetsModel
        //                                                     : root.profileStore.profileShowcaseAssetsModel
        readonly property var assetsModel: root.profileStore.profileShowcaseAssetsModel
        readonly property var socialLinksModel: root.livePreview ? root.livePreviewValues.socialLinksModel
                                                            : root.profileStore.socialLinksModel
        SortFilterProxyModel {
            id: liveCommunitiesModel
            sourceModel: root.livePreviewValues.communitiesModel
            proxyRoles: [
                FastExpressionRole {
                    name: "membersCount"
                    expression: model.members.count
                    expectedRoles: ["members"]
                }
            ]
        }

        SortFilterProxyModel {
            id: communitiesStoreModel
            sourceModel: root.profileStore.profileShowcaseCommunitiesModel
            filters: [
                ValueFilter {
                    roleName: "showcaseVisibility"
                    value: Constants.ShowcaseVisibility.NoOne
                    inverted: true
                },
                ValueFilter {
                    roleName: "loading"
                    value: false
                }
            ]
        }

        SortFilterProxyModel {
            id: accountsStoreModel
            sourceModel: root.profileStore.profileShowcaseAccountsModel
            filters: ValueFilter {
                roleName: "showcaseVisibility"
                value: Constants.ShowcaseVisibility.NoOne
                inverted: true
            }
        }

        SortFilterProxyModel {
            id: collectiblesStoreModel
            sourceModel: root.profileStore.profileShowcaseCollectiblesModel
            filters: ValueFilter {
                roleName: "showcaseVisibility"
                value: Constants.ShowcaseVisibility.NoOne
                inverted: true
            }
        }
    }

    background: StatusDialogBackground {
        color: Theme.palette.baseColor4
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.radius
            color: parent.color
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Theme.palette.baseColor2
        }
    }

    contentItem: StackLayout {
        id: stackLayout
        // communities
        anchors.fill:parent

        Item {
            width: parent.width
            height: parent.height
            clip: true
            StatusBaseText {
                anchors.centerIn: parent
                visible: (communitiesView.count === 0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any communities").arg(root.mainDisplayName)
            }
            StatusGridView {
                id: communitiesView
                width: 606
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: (webView.contentY > Style.current.halfPadding) ? 1 : Style.current.bigPadding
                Behavior on anchors.topMargin { NumberAnimation { duration: 50 } }
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.halfPadding
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: Style.current.halfPadding
                clip: false
                cellWidth: d.delegateWidthM
                cellHeight: d.delegateHeightM
                visible: count
                model: d.communitiesModel
                ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: -3.5 }
                delegate: StatusCommunityCard {
                    id: profileDialogCommunityCard
                    readonly property var permissionsList: model.permissionsModel
                    readonly property bool requirementsMet: !!model.allTokenRequirementsMet ? model.allTokenRequirementsMet : false
                    cardSize: StatusCommunityCard.Size.Small
                    implicitWidth: GridView.view.cellWidth - Style.current.padding
                    implicitHeight: GridView.view.cellHeight - Style.current.padding
                    titleFontSize: 15
                    communityId: model.id
                    asset.source: model.image
                    asset.isImage: !!model.image
                    asset.width: 32
                    asset.height: 32
                    name: model.name
                    memberCountVisible: false
                    layer.enabled: hovered
                    border.width: hovered ? 0 : 1
                    border.color: Theme.palette.baseColor2
                    banner: model.bannerImageData ?? ""
                    descriptionFontSize: 12
                    descriptionFontColor: Theme.palette.baseColor1
                    description: {
                        switch (model.memberRole)  {
                        case (Constants.memberRole.owner):
                            return qsTr("Owner");
                        case (Constants.memberRole.admin) :
                            return qsTr("Admin");
                        case (Constants.memberRole.tokenMaster):
                            return qsTr("Token Master");
                        default:
                            return qsTr("Member");
                        }
                    }
                    communityColor: model.color
                    // Community restrictions
                    bottomRowComponent: model.memberRole ===  Constants.memberRole.tokenMaster ?
                                            communityMembershipComponent :
                                            !!profileDialogCommunityCard.permissionsList && profileDialogCommunityCard.permissionsList.count > 0 ?
                                                permissionsRowComponent : null

                    Component {
                        id: communityMembershipComponent
                        Item {
                            width: 125
                            height: 24
                            Rectangle {
                                anchors.fill: parent
                                radius: 20
                                color: Theme.palette.successColor1
                                opacity: .1
                                border.color: Theme.palette.successColor1
                            }
                            Row {
                                anchors.centerIn: parent
                                spacing: 2
                                StatusIcon {
                                    width: 16
                                    height: 16
                                    color: Theme.palette.successColor1
                                    icon: "tiny/checkmark"
                                }
                                StatusBaseText {
                                    font.pixelSize: Theme.tertiaryTextFontSize
                                    color: Theme.palette.successColor1
                                    text: qsTr("You’re there too")
                                }
                            }
                        }
                    }

                    Component {
                        id: permissionsRowComponent
                        PermissionsRow {
                            hoverEnabled: false
                            assetsModel: root.assetsModel
                            collectiblesModel: root.collectiblesModel
                            model: profileDialogCommunityCard.permissionsList
                            requirementsMet: profileDialogCommunityCard.requirementsMet
                            backgroundBorderColor: Theme.palette.baseColor2
                            backgroundRadius: 20
                        }
                    }

                    onClicked: {
                        if (root.readOnly)
                            return
                        if (mouse.button === Qt.LeftButton) {
                            Global.switchToCommunity(model.id);
                        } else {
                            Global.openMenu(delegatesActionsMenu, this, { communityId: model.id, context: "communities"});
                        }
                        root.closeRequested();
                    }
                }
            }
        }

        // wallets/accounts
        Item {
            width: parent.width
            height: parent.height
            clip: true
            StatusBaseText {
                anchors.centerIn: parent
                visible: (accountsView.count === 0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any accounts").arg(root.mainDisplayName)
            }
            StatusGridView {
                id: accountsView
                width: 606
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: (webView.contentY > Style.current.halfPadding) ? 1 : Style.current.bigPadding
                Behavior on anchors.topMargin { NumberAnimation { duration: 50 } }
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.halfPadding
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: Style.current.halfPadding
                cellWidth: d.delegateWidthM
                cellHeight: d.delegateHeightM
                visible: count
                clip: false
                ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: -3.5 }
                model: d.accountsModel
                delegate: InfoCard {
                    id: accountInfoDelegate
                    implicitWidth: GridView.view.cellWidth - Style.current.padding
                    implicitHeight: GridView.view.cellHeight - Style.current.padding
                    title: model.name
                    subTitle: StatusQUtils.Utils.elideText(model.address, 6, 4).replace("0x", "0×")
                    asset.color: Utils.getColorForId(model.colorId)
                    asset.emoji: model.emoji ?? ""
                    asset.name: asset.emoji || "filled-account"
                    asset.isLetterIdenticon: asset.emoji
                    asset.letterSize: 14
                    asset.bgColor: Theme.palette.primaryColor3
                    asset.isImage: asset.emoji
                    enabledNetworks: root.enabledNetworks
                    rightSideButtons: RowLayout {
                        StatusFlatRoundButton {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            visible: accountInfoDelegate.hovered
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "send"
                            icon.color: !hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1
                            enabled: root.networkConnectionStore.sendBuyBridgeEnabled
                            onClicked: {
                                Global.openSendModal(model.address)
                            }
                        }
                        StatusFlatRoundButton {
                            id: moreButton
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            visible: accountInfoDelegate.hovered
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "more"
                            icon.color: (hovered || d.menuOpened) ? Theme.palette.directColor1 : Theme.palette.baseColor1
                            highlighted: d.menuOpened
                            onClicked: {
                                Global.openMenu(delegatesActionsMenu, this, { x: moreButton.x, y : moreButton.y, accountAddress: model.address, context: "accounts"});
                            }
                        }
                    }
                    onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            Global.openMenu(delegatesActionsMenu, this, { accountAddress: model.address, context: "accounts"});
                        }
                    }
                }
            }
        }

        // collectibles/NFTs
        Item {
            width: parent.width
            height: parent.height
            clip: true
            StatusBaseText {
                anchors.centerIn: parent
                visible: (collectiblesView.count === 0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any collectibles").arg(root.mainDisplayName)
            }
            StatusGridView {
                id: collectiblesView
                width: 608
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: (webView.contentY > Style.current.halfPadding) ? 1 : Style.current.bigPadding
                Behavior on anchors.topMargin { NumberAnimation { duration: 50 } }
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.halfPadding
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: Style.current.halfPadding
                cellWidth: d.delegateWidthS
                cellHeight: d.delegateHeightS
                visible: count
                clip: false
                // TODO Issue #11637: Dedicated controller for user's list of collectibles (no watch-only entries)
                model: d.collectiblesModel
                ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: -3.5 }
                delegate: Item {
                    width: GridView.view.cellWidth - Style.current.padding
                    height: GridView.view.cellHeight - Style.current.padding
                    StatusRoundedImage {
                        id: collectibleImage
                        anchors.fill: parent
                        color: !!model.backgroundColor ? model.backgroundColor : "transparent"
                        radius: Style.current.radius
                        showLoadingIndicator: model.isLoading
                        image.fillMode: Image.PreserveAspectCrop
                        image.source: model.imageUrl ?? ""
                        TapHandler {
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onSingleTapped: {
                                if ((eventPoint.event.button === Qt.LeftButton) && (model.communityId !== "")) {
                                    Global.openPopup(visitComunityPopupComponent, {communityId: model.communityId, communityName: model.communityName,
                                                                                   communityLogo: model.communityImage, tokenName: model.name,
                                                                                   tokenImage: model.imageUrl, isAssetType: false });
                                } else {
                                    if (eventPoint.event.button === Qt.LeftButton) {
                                        Global.openLinkWithConfirmation(model.permalink, model.domain)
                                    } else {
                                        if (model.communityId !== "") {
                                            Global.openMenu(delegatesActionsMenu, collectibleImage, { communityId: model.communityId, context: "collectibles"});
                                        } else {
                                            Global.openMenu(delegatesActionsMenu, collectibleImage, { url: model.permalink, domain: model.domain, context: "collectibles"});
                                        }
                                    }
                                }
                            }
                        }
                        HoverHandler {
                            id: hoverHandler
                            cursorShape: hovered ? Qt.PointingHandCursor : undefined
                        }
                    }

                    Image {
                        id: gradient
                        anchors.fill: collectibleImage
                        visible: hoverHandler.hovered
                        source: Style.png("profile/gradient")
                    }

                    //TODO Add drop shadow

                    Control {
                        width: (amountText.contentWidth + Style.current.padding)
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.top: parent.top
                        anchors.topMargin: 12
                        //TODO TBD, https://github.com/status-im/status-desktop/issues/13782
                        visible: (model.userHas > 1)

                        background: Rectangle {
                            radius: 30
                            color: Theme.palette.indirectColor2
                        }

                        contentItem: StatusBaseText {
                            id: amountText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Style.current.asideTextFontSize
                            text: "x"+model.userHas
                        }
                    }

                    StatusFlatRoundButton {
                        implicitWidth: 24
                        implicitHeight: 24
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.top: parent.top
                        anchors.topMargin: 12
                        visible: (hoverHandler.hovered && model.communityId === "")
                        type: StatusFlatRoundButton.Type.Secondary
                        icon.name: "external"
                        icon.width: 16
                        icon.height: 16
                        radius: width/2
                        icon.color: Theme.palette.directColor1
                        onClicked: {
                            Global.openLinkWithConfirmation(model.permalink, model.domain)
                        }
                    }

                    ExpandableTag {
                        id: communityTag
                        visible: !!model.communityImage
                        tagHeaderText: model.name
                        tagName: model.communityName
                        tagImage: model.communityImage ?? ""
                        backgroundColor: hovered ? Style.current.background : Theme.palette.indirectColor2
                        onTagClicked: {
                            if (model.communityId !== "") {
                                Global.switchToCommunity(model.communityId);
                                root.closeRequested();
                            } else {
                                let networkShortName = WalletStore.RootStore.getNetworkShortNames(model.chainId);
                                let link = WalletStore.RootStore.getOpenSeaCollectibleUrl(networkShortName, model.contractAddress, model.tokenId)
                                Global.openLinkWithConfirmation(link, StatusQUtils.extractDomainFromLink(link));
                            }
                        }
                    }
                }
            }
        }

        // assets/tokens
        Item {
            width: parent.width
            height: parent.height
            clip: true
            StatusBaseText {
                anchors.centerIn: parent
                visible: (assetsView.count === 0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any assets").arg(root.mainDisplayName)
            }
            StatusGridView {
                id: assetsView
                width: 608
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: (webView.contentY > Style.current.halfPadding) ? 1 : Style.current.bigPadding
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.halfPadding
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: Style.current.halfPadding
                cellWidth: d.delegateWidthS
                cellHeight: d.delegateHeightS
                visible: count
                clip: false
                model: SortFilterProxyModel {
                    sourceModel: d.assetsModel
                    filters: ValueFilter {
                        roleName: "showcaseVisibility"
                        value: Constants.ShowcaseVisibility.NoOne
                        inverted: true
                    }
                }
                ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: -3.5 }
                delegate: InfoCard {
                    id: assetsInfoDelegate
                    width: GridView.view.cellWidth - Style.current.padding
                    height: GridView.view.cellHeight - Style.current.padding
                    title: model.name
                    //TODO show balance & symbol
                    subTitle: model.decimals + " " + model.symbol
                    asset.name: Constants.tokenIcon(model.symbol)
                    asset.isImage: true

                    ExpandableTag {
                        id: communityTag
                        visible: !!model.communityImage
                        tagName: model.communityName
                        tagImage: model.communityImage
                        onTagClicked: {
                            Global.switchToCommunity(model.communityId);
                            root.closeRequested();
                        }
                    }

                    rightSideButtons: RowLayout {
                        StatusFlatRoundButton {
                            implicitWidth: 24
                            implicitHeight: 24
                            visible: (assetsInfoDelegate.hovered && !communityTag.hovered && model.communityId === "")
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "external"
                            icon.width: 16
                            icon.height: 16
                            radius: width/2
                            icon.color: assetsInfoDelegate.hovered && !hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1
                            enabled: root.networkConnectionStore.sendBuyBridgeEnabled
                            onClicked: {
                                //TODO check this open on CoinGecko
                                Global.openLink(model.url);
                            }
                        }
                    }
                    onCommunityTagClicked: {
                        Global.switchToCommunity(model.communityId);
                        root.closeRequested();
                    }
                    onClicked: {
                        if ((mouse.button === Qt.LeftButton) && (model.communityId !== "")) {
                            Global.openPopup(visitComunityPopupComponent, {communityId: model.communityId, communityName: model.communityName,
                                                                           communityLogo: model.communityImage, tokenName: model.name,
                                                                           tokenImage: Constants.tokenIcon(model.symbol), isAssetType: false });
                        } else if (mouse.button === Qt.RightButton) {
                            Global.openMenu(delegatesActionsMenu, this, { accountAddress: model.address, communityId: model.communityId, context: "assets" });
                        }
                    }
                }
            }
        }

        // social links
        Item {
            width: parent.width
            height: parent.height
            clip: true
            StatusBaseText {
                anchors.centerIn: parent
                visible: (webView.count === 0)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 has not shared any links").arg(root.mainDisplayName)
            }
            StatusGridView {
                id: webView
                width: 608
                height: parent.height
                anchors.top: parent.top
                anchors.topMargin: (webView.contentY > Style.current.halfPadding) ? 1 : Style.current.bigPadding
                Behavior on anchors.topMargin { NumberAnimation { duration: 50 } }
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.halfPadding
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: Style.current.halfPadding
                cellWidth: d.delegateWidthS
                cellHeight: d.delegateHeightS
                visible: count
                clip: false
                model: root.socialLinks
                ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: -3.5 }
                delegate: InfoCard {
                    id: socialLinksInfoDelegate
                    readonly property int linkType: ProfileUtils.linkTextToType(model.text)
                    width: GridView.view.cellWidth - Style.current.padding
                    height: GridView.view.cellHeight - Style.current.padding
                    title: !!ProfileUtils.linkTypeToText(linkType) ? ProfileUtils.linkTypeToText(linkType) : model.text
                    asset.bgColor: ProfileUtils.linkTypeBgColor(linkType)
                    asset.name: ProfileUtils.linkTypeToIcon(linkType)
                    asset.color: ProfileUtils.linkTypeColor(linkType)
                    asset.width: 20
                    asset.height: 20
                    asset.bgWidth: 32
                    asset.bgHeight: 32
                    asset.isImage: false
                    subTitle: model.url
                    onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            Global.openMenu(delegatesActionsMenu, this, { url: model.url, context: "socialLinks"});
                        }
                    }
                    rightSideButtons: RowLayout {
                        StatusFlatRoundButton {
                            implicitWidth: 24
                            implicitHeight: 24
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "external"
                            icon.width: 16
                            icon.height: 16
                            radius: width/2
                            highlighted: true
                            visible: socialLinksInfoDelegate.hovered
                            icon.color: socialLinksInfoDelegate.hovered && !hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1
                            enabled: root.networkConnectionStore.sendBuyBridgeEnabled
                            onClicked: {
                                Global.openLinkWithConfirmation(model.url, model.domain);
                            }
                        }
                    }
                }
            }

            Item {
                width: 279
                height: 32
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (webView.count > 0)
                Rectangle {
                    anchors.fill: parent
                    color: Style.current.background
                    radius: 30
                    border.color: Theme.palette.baseColor2
                }
                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    StatusIcon {
                        width: 16
                        height: 16
                        icon: "info"
                        color: Theme.palette.directColor1
                    }
                    StatusBaseText {
                        font.pixelSize: 13
                        text: qsTr("Social handles and links are unverified")
                    }
                }
            }
        }
    }

    Component {
        id: delegatesActionsMenu
        StatusMenu {
            id: contextMenu
            property string url
            property string domain
            property string communityId
            property string context: ""
            property string accountAddress: ""

            onOpened: { d.menuOpened = true; }
            onClosed: { d.menuOpened = false; }

            StatusAction {
                text: qsTr("Visit community")
                enabled: ((((contextMenu.context === "collectibles") || (contextMenu.context === "assets")) &&
                          !!contextMenu.communityId) || (contextMenu.context === "communities"))
                icon.name: (contextMenu.context === "communities") ? "arrow-right" : "communities"
                onTriggered: {
                    Global.switchToCommunity(contextMenu.communityId);
                    root.closeRequested();
                }
            }

            StatusAction {
                text: qsTr("Invite People")
                icon.name: "share-ios"
                enabled: (contextMenu.context === "communities")
                onTriggered: {
                    Global.switchToCommunity(contextMenu.communityId);
                    Global.openInviteFriendsToCommunityPopup(root.communityData,
                                                             root.communitySectionModule,
                                                             null);
                    root.closeRequested();
                }
            }

            StatusSuccessAction {
                id: copyAddressAction
                successText: qsTr("Copied")
                text: (contextMenu.context === "socialLinks") ? qsTr("Copy link") : (contextMenu.context === "accounts") ?
                                                                qsTr("Copy adress") : qsTr("Copy link to community")
                icon.name: "copy"
                visible: ((contextMenu.context !== "collectibles") && (contextMenu.context !== "assets"))
                enabled: visible
                onTriggered: {
                    root.profileStore.copyToClipboard(!!contextMenu.communityId ? contextMenu.communityId : contextMenu.url);
                }
            }

            StatusAction {
                text: qsTr("Show address QR")
                icon.name: "qr"
                enabled: (contextMenu.context === "accounts")
                onTriggered: {
                    Global.openShowQRPopup({
                        showSingleAccount: true,
                        switchingAccounsEnabled: false,
                        changingPreferredChainsEnabled: false,
                        hasFloatingButtons: false,
                        name: "", //TODO
                        address: contextMenu.accountAddress,
                        colorId: "" //TODO
                    })
                }
            }

            StatusAction {
                text: qsTr("Save address")
                icon.name: "favourite"
                enabled: (contextMenu.context === "accounts")
                onTriggered: {
                    Global.openAddEditSavedAddressesPopup({ addAddress: true,  address: contextMenu.accountAddress })
                }
            }

            StatusAction {
                text: (contextMenu.context === "accounts") ? qsTr("View on Etherscan") :
                      (contextMenu.context === "collectibles") ? qsTr("View on Opensea") : qsTr("View on CoinGecko")
                enabled: ((contextMenu.context === "accounts") || (((contextMenu.context === "collectibles")
                        || (contextMenu.context === "assets")) && contextMenu.communityId === ""))
                icon.name: "link"
                onTriggered: {
                    if (contextMenu.context === "accounts") {
                        let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.mainnet,
                                                                   WalletStore.RootStore.areTestNetworksEnabled,
                                                                   WalletStore.RootStore.isGoerliEnabled,
                                                                   contextMenu.accountAddress);
                        Global.openLink(link);
                    } else if (contextMenu.context === "collectibles") {
                        Global.openLinkWithConfirmation(contextMenu.url, contextMenu.domain);
                    } else {
                        let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.coingecko,
                                                                   WalletStore.RootStore.areTestNetworksEnabled,
                                                                   WalletStore.RootStore.isGoerliEnabled,
                                                                   contextMenu.accountAddress);
                        Global.openLinkWithConfirmation(link, StatusQUtils.extractDomainFromLink(link));
                    }
                }
            }

            StatusAction {
                text: qsTr("View on Optimism Explorer")
                enabled: (contextMenu.context === "accounts")
                icon.name: "link"
                onTriggered: {
                    let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.optimism,
                                                               WalletStore.RootStore.areTestNetworksEnabled,
                                                               WalletStore.RootStore.isGoerliEnabled,
                                                               contextMenu.accountAddress);
                    Global.openLinkWithConfirmation(link, StatusQUtils.extractDomainFromLink(link));
                }
            }

            StatusAction {
                text: qsTr("View on Arbiscan")
                icon.name: "link"
                enabled: (contextMenu.context === "accounts")
                onTriggered: {
                    let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.arbiscan,
                                                               WalletStore.RootStore.areTestNetworksEnabled,
                                                               WalletStore.RootStore.isGoerliEnabled,
                                                               contextMenu.accountAddress);
                    Global.openLinkWithConfirmation(link, StatusQUtils.extractDomainFromLink(link));
                }
            }
        }
    }


    Component {
        id: visitComunityPopupComponent
        StatusDialog {
            id: visitComunityPopup
            // Community related props:
             property string communityId
             property string communityName
             property string communityLogo

            // Token related props:
             property string tokenName
             property string tokenImage
             property bool isAssetType: false

            width: 521 // by design
            padding: 0

            contentItem: StatusScrollView {
                id: scrollView
                padding: Style.current.padding
                contentWidth: availableWidth

                ColumnLayout {
                    width: scrollView.availableWidth
                    spacing: Style.current.padding

                    StatusBaseText {
                        Layout.fillWidth: true

                        text: visitComunityPopup.isAssetType ?  qsTr("%1 is a community minted asset. Would you like to visit the community that minted it?").arg(visitComunityPopup.tokenName) :
                                                               qsTr("%1 is a community minted collectible. Would you like to visit the community that minted it?").arg(visitComunityPopup.tokenName)
                        textFormat: Text.RichText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        lineHeight: 1.2
                    }

                    // Navigate to community button
                    StatusListItem {
                        Layout.fillWidth: true
                        Layout.bottomMargin: Style.current.halfPadding

                        title: visitComunityPopup.communityName
                        border.color: Theme.palette.baseColor2
                        asset.name: visitComunityPopup.communityLogo
                        asset.isImage: true
                        asset.isLetterIdenticon: !asset.name
                        components: [
                            RowLayout {
                                StatusIcon {
                                    Layout.alignment: Qt.AlignVCenter
                                    icon: "arrow-right"
                                    color: Theme.palette.primaryColor1
                                }

                                StatusBaseText {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: Style.current.padding

                                    text: visitComunityPopup.tokenName
                                    font.pixelSize: Style.current.additionalTextSize
                                    color: Theme.palette.primaryColor1
                                }
                            }
                        ]

                        onClicked: {
                            Global.switchToCommunity(visitComunityPopup.communityId);
                            visitComunityPopup.close();
                            root.closeRequested();
                        }
                    }
                }
            }

            header: StatusDialogHeader {
                leftComponent: StatusRoundedImage {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: Style.current.padding
                    Layout.preferredWidth: 68
                    Layout.preferredHeight: Layout.preferredWidth
                    radius: visitComunityPopup.isAssetType ? width / 2 : 8
                    image.source: visitComunityPopup.tokenImage
                    showLoadingIndicator: false
                    image.fillMode: Image.PreserveAspectCrop
                }
                headline.title: visitComunityPopup.tokenName
                headline.subtitle: qsTr("Minted by %1").arg(visitComunityPopup.communityName)
                actions.closeButton.onClicked: { visitComunityPopup.close(); }
            }

            footer: StatusDialogFooter {
                spacing: Style.current.padding
                rightButtons: ObjectModel {
                    StatusFlatButton {
                        text: qsTr("Cancel")
                        onClicked: {
                            visitComunityPopup.close();
                        }
                    }
                }
            }
        }
    }
}
