import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.15

import SortFilterProxyModel 0.2

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import AppLayouts.Chat.stores 1.0
import AppLayouts.Chat.controls.community 1.0

import shared.stores 1.0
import shared.views.chat 1.0

import "../panels/communities"
import "../popups/community"
import "../layouts"

StatusSectionLayout {
    id: root

    notificationCount: activityCenterStore.unreadNotificationsCount
    hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
    onNotificationButtonClicked: Global.openActivityCenterPopup()
    // TODO: get this model from backend?
    property var settingsMenuModel: [{id: Constants.CommunitySettingsSections.Overview, name: qsTr("Overview"), icon: "show", enabled: true},
        {id: Constants.CommunitySettingsSections.Members, name: qsTr("Members"), icon: "group-chat", enabled: true, },

        {id: Constants.CommunitySettingsSections.Permissions, name: qsTr("Permissions"), icon: "objects", enabled: true},
        {id: Constants.CommunitySettingsSections.MintTokens, name: qsTr("Mint Tokens"), icon: "token", enabled: root.community.memberRole === Constants.memberRole.owner},
        {id: Constants.CommunitySettingsSections.Airdrops, name: qsTr("Airdrops"), icon: "airdrop", enabled: root.community.memberRole === Constants.memberRole.owner}]

    // TODO: Next community settings options:
    //                        {name: qsTr("Token sales"), icon: "token-sale"},
    //                        {name: qsTr("Subscriptions"), icon: "subscription"},
    property var rootStore
    property var chatCommunitySectionModule
    property var community
    property bool hasAddedContacts: false
    property var transactionStore: TransactionStore {}

    property bool isAdmin: community.memberRole === Constants.memberRole.owner ||
                           community.memberRole === Constants.memberRole.admin

    readonly property string filteredSelectedTags: {
        var tagsArray = []
        if (community && community.tags) {
            try {
                const json = JSON.parse(community.tags)
                if (!!json) {
                    tagsArray = json.map(tag => {
                                             return tag.name
                                         })
                }
            }
            catch (e) {
                console.warn("Error parsing community tags: ", community.tags, " error: ", e.message)
            }
        }
        return JSON.stringify(tagsArray);
    }

    signal backToCommunityClicked

    //navigate to a specific section and subsection
    function goTo(section: int, subSection: int) {
        d.goTo(section, subSection)
    }

    onBackButtonClicked: {
        centerPanelContentLoader.item.children[d.currentIndex].navigateBack()
    }

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
                model: root.settingsMenuModel
                spacing: 8

                delegate: StatusNavigationListItem {
                    objectName: "CommunitySettingsView_NavigationListItem_" + modelData.name
                    width: listView.width
                    title: modelData.name
                    asset.name: modelData.icon
                    asset.height: 24
                    asset.width: 24
                    selected: d.currentIndex === index
                    onClicked: d.currentIndex = index
                    visible: modelData.enabled
                    height: modelData.enabled ? implicitHeight : 0
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

    centerPanel: Loader {
        id: centerPanelContentLoader
        anchors.fill: parent
        active: root.community
        sourceComponent: StackLayout {
            id: stackLayout
            currentIndex: d.currentIndex

            CommunityOverviewSettingsPanel {
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

                onEdited: {
                    const error = root.chatCommunitySectionModule.editCommunity(
                                    StatusQUtils.Utils.filterXSS(item.name),
                                    StatusQUtils.Utils.filterXSS(item.description),
                                    StatusQUtils.Utils.filterXSS(item.introMessage),
                                    StatusQUtils.Utils.filterXSS(item.outroMessage),
                                    item.options.requestToJoinEnabled ? Constants.communityChatOnRequestAccess : Constants.communityChatPublicAccess,
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
                onPreviousPageNameChanged: root.backButtonName = previousPageName
            }

            CommunityMembersSettingsPanel {
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

            CommunityPermissionsSettingsPanel {
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

                communityDetails: QtObject {
                    readonly property string name: root.community.name
                    readonly property string image: root.community.image
                    readonly property string color: root.community.color
                    readonly property bool owner: root.community.memberRole === Constants.memberRole.owner
                }

                onCreatePermissionRequested:
                    permissionsStore.createPermission(holdings, permissionType,
                                                      isPrivate, channels)

                onUpdatePermissionRequested:
                    permissionsStore.editPermission(
                        key, holdings, permissionType, channels, isPrivate)

                onRemovePermissionRequested:
                    permissionsStore.removePermission(key)

                onPreviousPageNameChanged: root.backButtonName = previousPageName

                onNavigateToMintTokenSettings: root.goTo(Constants.CommunitySettingsSections.MintTokens)
            }

            CommunityMintTokensSettingsPanel {
                id: mintPanel

                readonly property CommunityTokensStore communityTokensStore:
                    rootStore.communityTokensStore

                function setFeesInfo(ethCurrency, fiatCurrency, errorCode) {
                    if (errorCode === Constants.ComputeFeeErrorCode.Success || errorCode === Constants.ComputeFeeErrorCode.Balance) {
                        let valueStr = LocaleUtils.currencyAmountToLocaleString(ethCurrency) + "(" + LocaleUtils.currencyAmountToLocaleString(fiatCurrency) + ")"
                        mintPanel.feeText = valueStr
                        if (errorCode === Constants.ComputeFeeErrorCode.Balance) {
                            mintPanel.errorText = qsTr("Not enough funds to make transaction")
                        }
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
                tokensModel: root.community.communityTokens
                layer1Networks: communityTokensStore.layer1Networks
                layer2Networks: communityTokensStore.layer2Networks
                testNetworks: communityTokensStore.testNetworks
                enabledNetworks: communityTokensStore.enabledNetworks
                allNetworks: communityTokensStore.allNetworks
                accounts: root.rootStore.accounts

                onPreviousPageNameChanged: root.backButtonName = previousPageName
                onSignMintTransactionOpened: communityTokensStore.computeDeployFee(chainId, accountAddress)
                onMintCollectible: communityTokensStore.deployCollectible(root.community.id, collectibleItem)
                onMintAsset: communityTokensStore.deployAsset(root.community.id, assetItem)
                onSignRemoteDestructTransactionOpened: communityTokensStore.computeSelfDestructFee(remotelyDestructTokensList, tokenKey)
                onRemotelyDestructCollectibles: {
                    communityTokensStore.remoteSelfDestructCollectibles(root.community.id,
                                                                        remotelyDestructTokensList,
                                                                        tokenKey)
                }
                onSignBurnTransactionOpened: communityTokensStore.computeBurnFee(tokenKey, amount)
                onBurnToken: communityTokensStore.burnToken(root.community.id, tokenKey, amount)
                onAirdropToken: root.goTo(Constants.CommunitySettingsSections.Airdrops)
                onDeleteToken: communityTokensStore.deleteToken(root.community.id, tokenKey)

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

                    function onRemoteDestructStateChanged(communityId, tokenName, status, url) {
                        if (root.community.id !== communityId) {
                            return
                        }

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
                        Global.displayToastMessage(title,
                                                   qsTr("View on etherscan"),
                                                   "",
                                                   loading,
                                                   type,
                                                   url)
                    }

                    function onAirdropStateChanged(communityId, tokenName, chainName, status, url) {
                        if (root.community.id !== communityId) {
                            return
                        }

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
                        Global.displayToastMessage(title,
                                                   qsTr("View on etherscan"),
                                                   "",
                                                   loading,
                                                   type,
                                                   url)
                    }

                    function onBurnStateChanged(communityId, tokenName, status, url) {
                        if (root.community.id !== communityId) {
                            return
                        }

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
                        Global.displayToastMessage(title,
                                                   qsTr("View on etherscan"),
                                                   "",
                                                   loading,
                                                   type,
                                                   url)
                    }

                    function onDeploymentStateChanged(communityId, status, url) {
                        if (root.community.id !== communityId) {
                            return
                        }

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
                        Global.displayToastMessage(title,
                                                   qsTr("View on etherscan"),
                                                   "",
                                                   loading,
                                                   type,
                                                   url)
                    }
                }

                Connections {
                    target: airdropPanel

                    function onNavigateToMintTokenSettings(isAssetType) {
                        // Here it is forced a navigation to the new airdrop form, like if it was clicked the header button
                        mintPanel.resetNavigation(isAssetType)
                        mintPanel.primaryHeaderButtonClicked()
                    }
                }
            }

            CommunityAirdropsSettingsPanel {
                id: airdropPanel

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

                onPreviousPageNameChanged: root.backButtonName = previousPageName
                onAirdropClicked: communityTokensStore.airdrop(root.community.id, airdropTokens, addresses)
                onNavigateToMintTokenSettings: root.goTo(Constants.CommunitySettingsSections.MintTokens)

                onAirdropFeesRequested:
                    communityTokensStore.computeAirdropFee(
                        root.community.id, contractKeysAndAmounts, addresses)

                Connections {
                    target: mintPanel

                    function onAirdropToken(tokenKey, type, addresses) {
                        // Here it is forced a navigation to the new airdrop form, like if it was clicked the header button
                        airdropPanel.primaryHeaderButtonClicked()

                        // Force a token selection to be airdroped with default amount 1
                        airdropPanel.selectToken(tokenKey, 1, type)
                        
                        // Set given addresses as recipients
                        airdropPanel.addAddresses(addresses)
                    }
                }

                Connections {
                    target: rootStore.communityTokensStore

                    function onAirdropFeeUpdated(airdropFees) {
                        airdropPanel.airdropFees = airdropFees
                    }
                }
            }

            onCurrentIndexChanged: root.backButtonName = centerPanelContentLoader.item.children[d.currentIndex].previousPageName
        }
    }

    onSettingsMenuModelChanged: d.currentIndex = 0

    QtObject {
        id: d

        property int currentIndex: 0
        readonly property var currentItem: centerPanelContentLoader.item && centerPanelContentLoader.item.children[d.currentIndex]
                                    ? centerPanelContentLoader.item.children[d.currentIndex]
                                    : null

        function goTo(section: int, subSection: int) {
            //find and enable section
            const matchingIndex = listView.model.findIndex((modelItem, index) => modelItem.id === section && modelItem.enabled)

            if(matchingIndex === -1)
                return

            d.currentIndex = matchingIndex

            //find and enable subsection if subSection navigation is available
            if(d.currentItem && d.currentItem.goTo) {
                d.currentItem.goTo(subSection)
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
        target: root.chatCommunitySectionModule
        function onOpenNoPermissionsToJoinPopup(communityName: string, userName: string, communityId: string, requestId: string) {
            Global.openPopup(noPermissionsPopupCmp, {
                                 communityName: communityName,
                                 userName: userName,
                                 communityId: communityId,
                                 requestId: requestId
                             })
        }

    }
}
