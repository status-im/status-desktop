import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

import SortFilterProxyModel 0.2

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Layout 0.1

import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.views.chat 1.0
import utils 1.0

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.popups 1.0

StatusSectionLayout {
    id: root

    notificationCount: activityCenterStore.unreadNotificationsCount
    hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
    onNotificationButtonClicked: Global.openActivityCenterPopup()

    property var rootStore
    property var chatCommunitySectionModule
    property var community
    property bool hasAddedContacts: false
    property var transactionStore: TransactionStore {}

    readonly property bool isOwner: community.memberRole === Constants.memberRole.owner
    readonly property bool isAdmin: isOwner || community.memberRole === Constants.memberRole.admin

    readonly property string filteredSelectedTags: {
        let tagsArray = []
        if (community && community.tags) {
            try {
                const json = JSON.parse(community.tags)

                if (!!json)
                    tagsArray = json.map(tag => tag.name)
            } catch (e) {
                console.warn("Error parsing community tags: ", community.tags,
                             " error: ", e.message)
            }
        }
        return JSON.stringify(tagsArray)
    }

    signal backToCommunityClicked

    backButtonName: stackLayout.children[d.currentIndex].previousPageName || ""

    //navigate to a specific section and subsection
    function goTo(section: int, subSection: int) {
        d.goTo(section, subSection)
    }

    onBackButtonClicked: stackLayout.children[d.currentIndex].navigateBack()

    leftPanel: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors {
                top: parent.top
                bottom: backToCommunityButton.top
                bottomMargin: 12
                topMargin: Style.current.smallPadding
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            spacing: 32
            clip: true

            StatusChatInfoButton {
                id: communityHeader

                title: community.name
                subTitle: qsTr("%n member(s)", "", community.members.count || 0)
                asset.name: community.image
                asset.color: community.color
                asset.isImage: true
                Layout.fillWidth: true
                Layout.leftMargin: Style.current.halfPadding
                Layout.rightMargin: Style.current.halfPadding
                type: StatusChatInfoButton.Type.OneToOneChat
                hoverEnabled: false
            }

            StatusListView {
                id: listView

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Style.current.padding
                Layout.rightMargin: Style.current.padding
                model: stackLayout.children
                spacing: 8

                delegate: StatusNavigationListItem {
                    objectName: "CommunitySettingsView_NavigationListItem_" + model.sectionName
                    width: ListView.view.width
                    title: model.sectionName
                    asset.name: model.sectionIcon
                    asset.height: 24
                    asset.width: 24
                    selected: d.currentIndex === index
                    onClicked: d.currentIndex = index
                    visible: model.sectionEnabled
                    height: visible ? implicitHeight : 0
                }
            }
        }

        StatusBaseText {
            id: backToCommunityButton
            objectName: "communitySettingsBackToCommunityButton"
            anchors {
                bottom: parent.bottom
                bottomMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            text: "<- " + qsTr("Back to community")
            color: Theme.palette.baseColor1
            font.pixelSize: 15
            font.underline: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backToCommunityClicked()
                hoverEnabled: true
            }
        }
    }

    centerPanel: StackLayout {
        id: stackLayout

        anchors.fill: parent

        currentIndex: d.currentIndex

        OverviewSettingsPanel {
            readonly property int sectionKey: Constants.CommunitySettingsSections.Overview
            readonly property string sectionName: qsTr("Overview")
            readonly property string sectionIcon: "show"
            readonly property bool sectionEnabled: true

            communityId: root.community.id
            name: root.community.name
            description: root.community.description
            introMessage: root.community.introMessage
            outroMessage: root.community.outroMessage
            logoImageData: root.community.image
            bannerImageData: root.community.bannerImageData
            color: root.community.color
            tags: root.rootStore.communityTags
            selectedTags: root.filteredSelectedTags
            archiveSupportEnabled: root.community.historyArchiveSupportEnabled
            requestToJoinEnabled: root.community.access === Constants.communityChatOnRequestAccess
            pinMessagesEnabled: root.community.pinMessageAllMembersEnabled
            editable: true
            owned: root.community.memberRole === Constants.memberRole.owner
            loginType: root.rootStore.loginType

            onEdited: {
                const error = root.chatCommunitySectionModule.editCommunity(
                                StatusQUtils.Utils.filterXSS(item.name),
                                StatusQUtils.Utils.filterXSS(item.description),
                                StatusQUtils.Utils.filterXSS(item.introMessage),
                                StatusQUtils.Utils.filterXSS(item.outroMessage),
                                item.options.requestToJoinEnabled ? Constants.communityChatOnRequestAccess
                                                                  : Constants.communityChatPublicAccess,
                                item.color.toString().toUpperCase(),
                                item.selectedTags,
                                Utils.getImageAndCropInfoJson(item.logoImagePath, item.logoCropRect),
                                Utils.getImageAndCropInfoJson(item.bannerPath, item.bannerCropRect),
                                item.options.archiveSupportEnabled,
                                item.options.pinMessagesEnabled
                                )
                if (error) {
                    errorDialog.text = error.error
                    errorDialog.open()
                }
            }

            onInviteNewPeopleClicked: {
                Global.openInviteFriendsToCommunityPopup(root.community,
                                                         root.chatCommunitySectionModule,
                                                         null)
            }

            onAirdropTokensClicked: root.goTo(Constants.CommunitySettingsSections.Airdrops)
            onBackUpClicked: {
                Global.openPopup(transferOwnershipPopup, {
                                     privateKey: root.chatCommunitySectionModule.exportCommunity(root.community.id),
                                 })
            }
        }

        MembersSettingsPanel {
            readonly property int sectionKey: Constants.CommunitySettingsSections.Members
            readonly property string sectionName: qsTr("Members")
            readonly property string sectionIcon: "group-chat"
            readonly property bool sectionEnabled: true

            rootStore: root.rootStore
            membersModel: root.community.members
            bannedMembersModel: root.community.bannedMembers
            pendingMemberRequestsModel: root.community.pendingMemberRequests
            declinedMemberRequestsModel: root.community.declinedMemberRequests
            editable: root.isAdmin
            communityName: root.community.name

            onKickUserClicked: root.rootStore.removeUserFromCommunity(id)
            onBanUserClicked: root.rootStore.banUserFromCommunity(id)
            onUnbanUserClicked: root.rootStore.unbanUserFromCommunity(id)
            onAcceptRequestToJoin: root.rootStore.acceptRequestToJoinCommunity(id, root.community.id)
            onDeclineRequestToJoin: root.rootStore.declineRequestToJoinCommunity(id, root.community.id)
        }

        PermissionsSettingsPanel {
            readonly property int sectionKey: Constants.CommunitySettingsSections.Permissions
            readonly property string sectionName: qsTr("Permissions")
            readonly property string sectionIcon: "objects"
            readonly property bool sectionEnabled: true

            readonly property PermissionsStore permissionsStore:
                rootStore.permissionsStore

            permissionsModel: permissionsStore.permissionsModel

            // temporary solution to provide icons for assets, similar
            // method is used in wallet (constructing filename from asset's
            // symbol) and is intended to be replaced by more robust
            // solution soon.

            assetsModel: rootStore.assetsModel
            collectiblesModel: rootStore.collectiblesModel
            channelsModel: rootStore.chatCommunitySectionModule.model

            communityDetails: d.communityDetails

            onCreatePermissionRequested:
                permissionsStore.createPermission(holdings, permissionType,
                                                  isPrivate, channels)

            onUpdatePermissionRequested:
                permissionsStore.editPermission(
                    key, holdings, permissionType, channels, isPrivate)

            onRemovePermissionRequested:
                permissionsStore.removePermission(key)

            onNavigateToMintTokenSettings: {
                root.goTo(Constants.CommunitySettingsSections.MintTokens)
                mintPanel.openNewTokenForm(isAssetType)
            }
        }

        MintTokensSettingsPanel {
            id: mintPanel

            readonly property int sectionKey: Constants.CommunitySettingsSections.MintTokens
            readonly property string sectionName: qsTr("Tokens")
            readonly property string sectionIcon: "token"
            readonly property bool sectionEnabled: root.isOwner

            readonly property CommunityTokensStore communityTokensStore:
                rootStore.communityTokensStore

            function setFeesInfo(ethCurrency, fiatCurrency, errorCode) {
                if (errorCode === Constants.ComputeFeeErrorCode.Success
                        || errorCode === Constants.ComputeFeeErrorCode.Balance) {

                    const valueStr = LocaleUtils.currencyAmountToLocaleString(ethCurrency)
                        + "(" + LocaleUtils.currencyAmountToLocaleString(fiatCurrency) + ")"
                    mintPanel.feeText = valueStr

                    if (errorCode === Constants.ComputeFeeErrorCode.Balance)
                        mintPanel.errorText = qsTr("Not enough funds to make transaction")

                    mintPanel.isFeeLoading = false

                    return
                } else if (errorCode === Constants.ComputeFeeErrorCode.Infura) {
                    mintPanel.errorText = qsTr("Infura error")
                    mintPanel.isFeeLoading = true
                    return
                }
                mintPanel.errorText = qsTr("Unknown error")
                mintPanel.isFeeLoading = true
            }

            communityName: root.community.name
            communityLogo: root.community.image
            communityColor: root.community.color
            isOwner: root.isOwner
            isAdmin: root.isAdmin
            isTokenMasterOwner: false // TODO: Backend
            tokensModel: root.community.communityTokens
            tokensModelWallet: root.rootStore.tokensModelWallet
            layer1Networks: communityTokensStore.layer1Networks
            layer2Networks: communityTokensStore.layer2Networks
            testNetworks: communityTokensStore.testNetworks
            enabledNetworks: communityTokensStore.enabledNetworks
            allNetworks: communityTokensStore.allNetworks
            accounts: root.rootStore.accounts

            onSignMintTransactionOpened:
                communityTokensStore.computeDeployFee(
                    chainId, accountAddress, tokenType)

            onMintCollectible:
                communityTokensStore.deployCollectible(
                    root.community.id, collectibleItem)

            onMintAsset:
                communityTokensStore.deployAsset(root.community.id, assetItem)

            onSignRemoteDestructTransactionOpened:
                communityTokensStore.computeSelfDestructFee(
                    remotelyDestructTokensList, tokenKey)

            onRemotelyDestructCollectibles:
                communityTokensStore.remoteSelfDestructCollectibles(
                    root.community.id, remotelyDestructTokensList, tokenKey)

            onSignBurnTransactionOpened:
                communityTokensStore.computeBurnFee(tokenKey, amount)

            onBurnToken:
                communityTokensStore.burnToken(root.community.id, tokenKey, amount)

            onDeleteToken:
                communityTokensStore.deleteToken(root.community.id, tokenKey)

            onAirdropToken: {
                root.goTo(Constants.CommunitySettingsSections.Airdrops)

                // Force a token selection to be airdroped with default amount 1
                airdropPanel.selectToken(tokenKey, 1, type)

                // Set given addresses as recipients
                airdropPanel.addAddresses(addresses)
            }
        }

        AirdropsSettingsPanel {
            id: airdropPanel

            readonly property int sectionKey: Constants.CommunitySettingsSections.Airdrops
            readonly property string sectionName: qsTr("Airdrops")
            readonly property string sectionIcon: "airdrop"
            readonly property bool sectionEnabled: root.isOwner

            communityDetails: d.communityDetails
            isOwner: root.isOwner
            isTokenMasterOwner: false // TODO: Backend
            isAdmin: root.isAdmin
            tokensModel: root.community.communityTokens

            readonly property CommunityTokensStore communityTokensStore:
                rootStore.communityTokensStore

            readonly property var communityTokens: root.community.communityTokens

            Loader {
                id: assetsModelLoader
                active: airdropPanel.communityTokens

                sourceComponent: SortFilterProxyModel {

                    sourceModel: airdropPanel.communityTokens
                    filters: ValueFilter {
                        roleName: "tokenType"
                        value: Constants.TokenType.ERC20
                    }
                    proxyRoles: [
                        ExpressionRole {
                            name: "category"

                            // Singleton cannot be used directly in the expression
                            readonly property int category: TokenCategories.Category.Own
                            expression: category
                        },
                        ExpressionRole {
                            name: "iconSource"
                            expression: model.image
                        },
                        ExpressionRole {
                            name: "key"
                            expression: model.symbol
                        },
                        ExpressionRole {
                            name: "communityId"
                            expression: ""
                        }
                    ]
                }
            }

            Loader {
                id: collectiblesModelLoader
                active: airdropPanel.communityTokens

                sourceComponent: SortFilterProxyModel {

                    sourceModel: airdropPanel.communityTokens
                    filters: ValueFilter {
                        roleName: "tokenType"
                        value: Constants.TokenType.ERC721
                    }
                    proxyRoles: [
                        ExpressionRole {
                            name: "category"

                            // Singleton cannot be used directly in the epression
                            readonly property int category: TokenCategories.Category.Own
                            expression: category
                        },
                        ExpressionRole {
                            name: "iconSource"
                            expression: model.image
                        },
                        ExpressionRole {
                            name: "key"
                            expression: model.symbol
                        },
                        ExpressionRole {
                            name: "communityId"
                            expression: ""
                        }
                    ]
                }
            }

            assetsModel: assetsModelLoader.item
            collectiblesModel: collectiblesModelLoader.item
            membersModel: {
                const chatContentModule = root.rootStore.currentChatContentModule()
                if (!chatContentModule || !chatContentModule.usersModule) {
                    // New communities have no chats, so no chatContentModule
                    return null
                }
                return chatContentModule.usersModule.model
            }

            onAirdropClicked: communityTokensStore.airdrop(root.community.id,
                                                           airdropTokens, addresses)

            onNavigateToMintTokenSettings: {
                root.goTo(Constants.CommunitySettingsSections.MintTokens)
                mintPanel.openNewTokenForm(isAssetType)
            }

            onAirdropFeesRequested:
                communityTokensStore.computeAirdropFee(
                    root.community.id, contractKeysAndAmounts, addresses)
        }
    }

    QtObject {
        id: d

        property int currentIndex: 0

        readonly property QtObject communityDetails: QtObject {
            readonly property string id: root.community.id
            readonly property string name: root.community.name
            readonly property string image: root.community.image
            readonly property string color: root.community.color
            readonly property bool owner: root.community.memberRole === Constants.memberRole.owner
            readonly property bool admin: root.community.memberRole === Constants.memberRole.admin
        }

        function goTo(section: int, subSection: int) {
            const stackContent = stackLayout.children

            for (let i = 0; stackContent.length; i++) {
                const item = stackContent[i]

                if (item.sectionKey === section) {
                    d.currentIndex = i

                    if(item.goTo)
                        item.goTo(subSection)

                    break
                }
            }
        }
    }

    MessageDialog {
        id: errorDialog

        title: qsTr("Error editing the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    Component {
        id: transferOwnershipPopup

        TransferOwnershipPopup {
            anchors.centerIn: parent
            store: root.rootStore
            onClosed: destroy()
        }
    }

    Component {
        id: noPermissionsPopupCmp

        NoPermissionsToJoinPopup {
            onRejectButtonClicked: {
                root.rootStore.declineRequestToJoinCommunity(requestId, communityId)
                close()
            }
            onClosed: destroy()
        }
    }


    Connections {
        target: rootStore.communityTokensStore

        function onDeployFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
            mintPanel.setFeesInfo(ethCurrency, fiatCurrency, errorCode)
        }

        function onSelfDestructFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
            mintPanel.setFeesInfo(ethCurrency, fiatCurrency, errorCode)
        }

        function onBurnFeeUpdated(ethCurrency, fiatCurrency, errorCode) {
            mintPanel.setFeesInfo(ethCurrency, fiatCurrency, errorCode)
        }

        function onAirdropFeeUpdated(airdropFees) {
            airdropPanel.airdropFees = airdropFees
        }

        function onRemoteDestructStateChanged(communityId, tokenName, status, url) {
            if (root.community.id !== communityId)
                return

            let title = ""
            let loading = false
            let type = Constants.ephemeralNotificationType.normal

            switch (status) {
            case Constants.ContractTransactionStatus.InProgress:
                title = qsTr("Remotely destroying tokens...")
                loading = true
                break
            case Constants.ContractTransactionStatus.Completed:
                title = qsTr("%1 tokens destroyed").arg(tokenName)
                type = Constants.ephemeralNotificationType.success
                break
            case Constants.ContractTransactionStatus.Failed:
                title = qsTr("%1 tokens destruction failed").arg(tokenName)
                break
            default:
                console.warn("Unknown destruction state: "+status)
                return
            }

            Global.displayToastMessage(title, qsTr("View on etherscan"), "",
                                       loading, type, url)
        }

        function onAirdropStateChanged(communityId, tokenName, chainName,
                                       status, url) {
            if (root.community.id !== communityId)
                return

            let title = ""
            let loading = false
            let type = Constants.ephemeralNotificationType.normal

            switch (status) {
            case Constants.ContractTransactionStatus.InProgress:
                title = qsTr("Airdrop on %1 in progress...").arg(chainName)
                loading = true
                break
            case Constants.ContractTransactionStatus.Completed:
                title = qsTr("Airdrop on %1 in complete").arg(chainName)
                type = Constants.ephemeralNotificationType.success
                break
            case Constants.ContractTransactionStatus.Failed:
                title = qsTr("Airdrop on %1 failed").arg(chainName)
                break
            default:
                console.warn("Unknown airdrop state: "+status)
                return
            }

            Global.displayToastMessage(title, qsTr("View on etherscan"), "",
                                       loading, type, url)
        }

        function onBurnStateChanged(communityId, tokenName, status, url) {
            if (root.community.id !== communityId)
                return

            let title = ""
            let loading = false
            let type = Constants.ephemeralNotificationType.normal

            switch (status) {
            case Constants.ContractTransactionStatus.InProgress:
                title = qsTr("%1 being burned...").arg(tokenName)
                loading = true
                break
            case Constants.ContractTransactionStatus.Completed:
                title = qsTr("%1 burning is complete").arg(tokenName)
                type = Constants.ephemeralNotificationType.success
                break
            case Constants.ContractTransactionStatus.Failed:
                title = qsTr("%1 burning is failed").arg(tokenName)
                break
            default:
                console.warn("Unknown burning state: "+status)
                return
            }

            Global.displayToastMessage(title, qsTr("View on etherscan"), "",
                                       loading, type, url)
        }

        function onDeploymentStateChanged(communityId, status, url) {
            if (root.community.id !== communityId)
                return

            let title = ""
            let loading = false
            let type = Constants.ephemeralNotificationType.normal

            switch (status) {
            case Constants.ContractTransactionStatus.InProgress:
                title = qsTr("Token is being minted...")
                loading = true
                break
            case Constants.ContractTransactionStatus.Completed:
                title = qsTr("Token minting finished")
                type = Constants.ephemeralNotificationType.success
                break
            case Constants.ContractTransactionStatus.Failed:
                title = qsTr("Token minting failed")
                break
            default:
                console.warn("Unknown deploy state: "+status)
                return
            }

            Global.displayToastMessage(title, qsTr("View on etherscan"), "",
                                       loading, type, url)
        }
    }

    Connections {
        target: root.chatCommunitySectionModule

        function onOpenNoPermissionsToJoinPopup(communityName: string,
                                                userName: string, communityId:
                                                string, requestId: string) {
            const properties = {
                communityName: communityName,
                userName: userName,
                communityId: communityId,
                requestId: requestId
            }

            Global.openPopup(noPermissionsPopupCmp, properties)
        }
    }
}
