import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

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

import shared.stores 1.0

import "../panels/communities"
import "../popups/community"
import "../layouts"

StatusSectionLayout {
    id: root

    notificationCount: activityCenterStore.unreadNotificationsCount
    hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
    onNotificationButtonClicked: Global.openActivityCenterPopup()
    // TODO: get this model from backend?
    property var settingsMenuModel: [{name: qsTr("Overview"), icon: "show", enabled: true},
        {name: qsTr("Members"), icon: "group-chat", enabled: true},
        {name: qsTr("Permissions"), icon: "objects", enabled: root.rootStore.communityPermissionsEnabled},
        {name: qsTr("Mint Tokens"), icon: "token", enabled: root.rootStore.communityTokensEnabled},
        {name: qsTr("Airdrops"), icon: "airdrop", enabled: root.rootStore.communityTokensEnabled}]
    // TODO: Next community settings options:
    //                        {name: qsTr("Token sales"), icon: "token-sale"},
    //                        {name: qsTr("Subscriptions"), icon: "subscription"},
    property var rootStore
    property var chatCommunitySectionModule
    property var community
    property bool hasAddedContacts: false
    property var transactionStore: TransactionStore {}

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
    signal openLegacyPopupClicked // TODO: remove me when migration to new settings is done

    onBackButtonClicked: {
        centerPanelContentLoader.item.children[d.currentIndex].navigateBack()
    }

    leftPanel: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors {
                top: parent.top
                bottom: footer.top
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

        // TODO: remove me when migration to new settings is done. Only keep back button and anchor to it.
        ColumnLayout {
            id: footer

            anchors {
                bottom: parent.bottom
                bottomMargin: 16
            }
            width: parent.width
            spacing: 16

            // TODO: remove me when migration to new settings is done
            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Open legacy popup (to be removed)")
                color: Theme.palette.baseColor1
                font.pixelSize: 10
                font.underline: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openLegacyPopupClicked()
                }
            }

            StatusBaseText {
                objectName: "communitySettingsBackToCommunityButton"
                Layout.alignment: Qt.AlignHCenter
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
    }

    centerPanel: Loader {
        id: centerPanelContentLoader
        anchors.fill: parent
        active: root.community
        sourceComponent: StackLayout {
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
                encrypted: root.community.encrypted
                requestToJoinEnabled: root.community.access === Constants.communityChatOnRequestAccess
                pinMessagesEnabled: root.community.pinMessageAllMembersEnabled
                editable: root.community.amISectionAdmin

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

                onAirdropTokensClicked: { /* TODO in future */ }
                onBackUpClicked: {
                    Global.openPopup(transferOwnershipPopup, {
                                         privateKey: root.chatCommunitySectionModule.exportCommunity(root.community.id),
                                     })
                }
                onPreviousPageNameChanged: root.backButtonName = previousPageName
            }

            CommunityMembersSettingsPanel {
                membersModel: root.community.members
                bannedMembersModel: root.community.bannedMembers
                pendingMemberRequestsModel: root.community.pendingMemberRequests
                declinedMemberRequestsModel: root.community.declinedMemberRequests
                editable: root.community.amISectionAdmin
                communityName: root.community.name

                onUserProfileClicked: Global.openProfilePopup(id)
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
                    readonly property var _activeSection:
                        rootStore.mainModuleInst.activeSection

                    readonly property string name: _activeSection.name
                    readonly property string image: _activeSection.image
                    readonly property string color: _activeSection.color
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

                onNavigateToMintTokenSettings: d.currentIndex = d.mintTokensSettingsIndex
            }

            CommunityMintTokensSettingsPanel {
                id: mintPanel

                readonly property CommunityTokensStore communityTokensStore:
                    rootStore.communityTokensStore

                tokensModel: root.community.communityTokens
                holdersModel: communityTokensStore.holdersModel
                layer1Networks: communityTokensStore.layer1Networks
                layer2Networks: communityTokensStore.layer2Networks
                testNetworks: communityTokensStore.testNetworks
                enabledNetworks: communityTokensStore.enabledNetworks
                allNetworks: communityTokensStore.allNetworks
                accounts: root.rootStore.accounts

                onPreviousPageNameChanged: root.backButtonName = previousPageName
                onSignMintTransactionOpened: communityTokensStore.computeDeployFee(chainId)
                onMintCollectible: {
                    communityTokensStore.deployCollectible(root.community.id,
                                                           accountAddress,
                                                           name,
                                                           symbol,
                                                           description,
                                                           supply,
                                                           infiniteSupply,
                                                           transferable,
                                                           selfDestruct,
                                                           chainId,
                                                           artworkSource,
                                                           accountName)
                }
                                
                Binding {
                   target: d
                   property: "mintTokensSettingsIndex"
                   value: communityMintTokensSettingsPanel.StackView.index
                }

                // TODO: Review once backend is done
                Connections {
                    target: rootStore.communityTokensStore
                    function onDeployFeeUpdated(value) {
                        // TODO better error handling
                        if (value === "-") {
                            mintPanel.isFeeLoading = true
                        } else {
                            mintPanel.isFeeLoading = false
                            mintPanel.feeText = value
                        }
                    }
                }
            }

            CommunityAirdropsSettingsPanel {
                readonly property CommunityTokensStore communityTokensStore:
                    rootStore.communityTokensStore

                assetsModel: rootStore.assetsModel
                collectiblesModel: rootStore.collectiblesModel

                onPreviousPageNameChanged: root.backButtonName = previousPageName
                onAirdropClicked: communityTokensStore.airdrop(root.community.id, airdropTokens, addresses)
                onNavigateToMintTokenSettings: d.currentIndex = d.mintTokensSettingsIndex
            }

            onCurrentIndexChanged: root.backButtonName = centerPanelContentLoader.item.children[d.currentIndex].previousPageName
        }
    }

    onSettingsMenuModelChanged: d.currentIndex = 0

    QtObject {
        id: d

        property int currentIndex: 0
        property int mintTokensSettingsIndex
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
