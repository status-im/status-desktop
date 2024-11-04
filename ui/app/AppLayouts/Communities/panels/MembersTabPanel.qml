import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import shared.controls.chat 1.0
import shared.stores 1.0 as SharedStores
import shared.views.chat 1.0
import utils 1.0

import AppLayouts.Chat.stores 1.0
import AppLayouts.Communities.layouts 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

    property string placeholderText
    property var model
    property RootStore rootStore
    property SharedStores.UtilsStore utilsStore

    property int memberRole: Constants.memberRole.none

    readonly property bool isOwner: memberRole === Constants.memberRole.owner
    readonly property bool isTokenMaster: memberRole === Constants.memberRole.tokenMaster

    signal kickUserClicked(string id, string name)
    signal banUserClicked(string id, string name)
    signal unbanUserClicked(string id)
    signal viewMemberMessagesClicked(string pubKey, string displayName)

    signal acceptRequestToJoin(string id)
    signal declineRequestToJoin(string id)

    enum TabType {
        AllMembers,
        BannedMembers,
        PendingRequests,
        DeclinedRequests
    }

    property int panelType: MembersTabPanel.TabType.AllMembers

    ColumnLayout {
        anchors.fill: parent
        spacing: 30

        SearchBox {
            id: memberSearch
            Layout.preferredWidth: 400
            Layout.leftMargin: 12
            placeholderText: root.placeholderText
            enabled: !!model && model.count > 0
        }

        StatusListView {
            id: membersList
            objectName: "CommunityMembersTabPanel_MembersListViews"

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: SortFilterProxyModel {
                sourceModel: root.model

                sorters : [
                    StringSorter {
                        roleName: "preferredDisplayName"
                        caseSensitivity: Qt.CaseInsensitive
                    }
                ]

                filters: AnyOf {
                    SearchFilter {
                        roleName: "localNickname"
                        searchPhrase: memberSearch.text
                    }
                    SearchFilter {
                        roleName: "displayName"
                        searchPhrase: memberSearch.text
                    }
                    SearchFilter {
                        roleName: "ensName"
                        searchPhrase: memberSearch.text
                    }
                    SearchFilter {
                        roleName: "alias"
                        searchPhrase: memberSearch.text
                    }
                }
            }
            spacing: 0

            delegate: StatusMemberListItem {
                id: memberItem

                // Buttons visibility conditions:
                // 1. Tab based buttons - only visible when the tab is selected
                //      a. All members tab
                //          - Kick; - Kick pending
                //          - Ban; - Ban pending
                //      b. Pending requests tab
                //          - Accept; - Accept pending
                //          - Reject; - Reject pending
                //      c. Rejected members tab
                //          - Accept; - Accept pending
                //      d. Banned members tab
                //          - Unban
                // 2. Pending states - buttons in pending states are always visible in their specific tab. Other buttons are disabled if the request is in pending state
                //    - Accept button is visible when the user is hovered or when the request is in accepted pending state. This condition can be overriden by the ctaAllowed property
                //    - Reject button is visible when the user is hovered or when the request is in rejected pending state. This condition can be overriden by the ctaAllowed property
                //    - Kick and ban buttons are visible when the user is hovered or when the request is in kick or ban pending state. This condition can be overriden by the ctaAllowed property
                // 3. Other conditions - buttons are visible when the user is hovered and is not himself or other privileged user
                // 4. All members tab, member in AwaitingAddress state - buttons is not visible, sandwatch icon is shown

                /// Helpers ///

                // Tab based buttons
                readonly property bool tabIsShowingKickBanButtons: root.panelType === MembersTabPanel.TabType.AllMembers
                readonly property bool tabIsShowingUnbanButton: root.panelType === MembersTabPanel.TabType.BannedMembers
                readonly property bool tabIsShowingRejectButton: root.panelType === MembersTabPanel.TabType.PendingRequests
                readonly property bool tabIsShowingAcceptButton: root.panelType === MembersTabPanel.TabType.PendingRequests ||
                                                                    root.panelType === MembersTabPanel.TabType.DeclinedRequests
                readonly property bool tabIsShowingViewMessagesButton: model.membershipRequestState !== Constants.CommunityMembershipRequestState.BannedWithAllMessagesDelete &&
                                                                       (root.panelType === MembersTabPanel.TabType.AllMembers ||
                                                                       root.panelType === MembersTabPanel.TabType.BannedMembers)


                // Request states
                readonly property bool isPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.Pending
                readonly property bool isAccepted: model.membershipRequestState === Constants.CommunityMembershipRequestState.Accepted
                readonly property bool isRejected: model.membershipRequestState === Constants.CommunityMembershipRequestState.Rejected
                readonly property bool isRejectedPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.RejectedPending
                readonly property bool isAcceptedPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.AcceptedPending
                readonly property bool isBanPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.BannedPending
                readonly property bool isUnbanPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.UnbannedPending
                readonly property bool isKickPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.KickedPending
                readonly property bool isBanned: model.membershipRequestState === Constants.CommunityMembershipRequestState.Banned ||
                                                 model.membershipRequestState === Constants.CommunityMembershipRequestState.BannedWithAllMessagesDelete
                readonly property bool isKicked: model.membershipRequestState === Constants.CommunityMembershipRequestState.Kicked

                // TODO: Connect to backend when available
                // The admin that initited the pending state can change the state. Actions are not visible for other admins
                readonly property bool ctaAllowed: !isRejectedPending && !isAcceptedPending && !isBanPending && !isUnbanPending && !isKickPending

                readonly property bool isHovered: memberItem.hovered
                readonly property bool canBeBanned: {
                    if (model.isCurrentUser)
                        return false

                    switch (model.memberRole) {
                        // Owner can't be banned
                        case Constants.memberRole.owner: return false
                        // TokenMaster can only be banned by owner
                        case Constants.memberRole.tokenMaster: return root.isOwner
                        // Admin can only be banned by owner and tokenMaster
                        case Constants.memberRole.admin: return root.isOwner || root.isTokenMaster
                        // All normal members can be banned by all privileged users
                        default: return true
                    }
                }
                readonly property bool showOnHover: isHovered && ctaAllowed
                readonly property bool canDeleteMessages: model.isCurrentUser || model.memberRole !== Constants.memberRole.owner

                /// Button visibility ///
                readonly property bool acceptButtonVisible:  tabIsShowingAcceptButton && (isPending || isRejected || isRejectedPending || isAcceptedPending) && showOnHover
                readonly property bool rejectButtonVisible: tabIsShowingRejectButton && (isPending || isRejectedPending || isAcceptedPending) && showOnHover
                readonly property bool acceptPendingButtonVisible: tabIsShowingAcceptButton && isAcceptedPending
                readonly property bool rejectPendingButtonVisible: tabIsShowingRejectButton && isRejectedPending
                readonly property bool kickButtonVisible: tabIsShowingKickBanButtons && isAccepted && showOnHover && canBeBanned
                readonly property bool banButtonVisible: tabIsShowingKickBanButtons && isAccepted && showOnHover && canBeBanned
                readonly property bool kickPendingButtonVisible: tabIsShowingKickBanButtons && isKickPending
                readonly property bool banPendingButtonVisible: tabIsShowingKickBanButtons && isBanPending
                readonly property bool unbanButtonVisible: tabIsShowingUnbanButton && isBanned && showOnHover
                readonly property bool viewMessagesButtonVisible: tabIsShowingViewMessagesButton && showOnHover
                readonly property bool messagesDeletedTextVisible: showOnHover &&
                                                                   model.membershipRequestState === Constants.CommunityMembershipRequestState.BannedWithAllMessagesDelete

                /// Pending states ///
                readonly property bool isPendingState: isAcceptedPending || isRejectedPending || isBanPending || isUnbanPending || isKickPending
                readonly property string pendingStateText:  isAcceptedPending ? qsTr("Accept pending...") :
                                                            isRejectedPending ? qsTr("Reject pending...") :
                                                            isBanPending ? qsTr("Ban pending...") :
                                                            isUnbanPending ? qsTr("Unban pending...") :
                                                            isKickPending ? qsTr("Kick pending...") : ""

                isAwaitingAddress: model.membershipRequestState === Constants.CommunityMembershipRequestState.AwaitingAddress

                rightPadding: 75
                leftPadding: 12

                components: [
                    StatusBaseText {
                        id: pendingText
                        width: Math.max(implicitWidth, d.pendingTextMaxWidth)
                        onImplicitWidthChanged: {
                            d.pendingTextMaxWidth = Math.max(implicitWidth, d.pendingTextMaxWidth)
                        }
                        visible: !!text && isPendingState
                        rightPadding: isKickPending || isBanPending || isUnbanPending ? 0 : Theme.bigPadding
                        anchors.verticalCenter: parent.verticalCenter
                        text: pendingStateText
                        color: Theme.palette.baseColor1
                        StatusToolTip {
                            text: qsTr("Waiting for owner node to come online")
                            visible: hoverHandler.hovered
                        }
                        HoverHandler {
                            id: hoverHandler
                            enabled: pendingText.visible
                        }
                    },

                    StatusBaseText {
                        text: qsTr("Messages deleted")
                        color: Theme.palette.baseColor1
                        anchors.verticalCenter: parent.verticalCenter
                        visible: messagesDeletedTextVisible
                    },

                    StatusButton {
                        id: viewMessages
                        anchors.verticalCenter: parent.verticalCenter
                        objectName: "MemberListItem_ViewMessages"
                        text: qsTr("View Messages")
                        visible: viewMessagesButtonVisible
                        size: StatusBaseButton.Size.Small
                        onClicked: root.viewMemberMessagesClicked(model.pubKey, memberItem.title)
                    },

                    StatusButton {
                        id: kickButton
                        anchors.verticalCenter: parent.verticalCenter
                        objectName: "MemberListItem_KickButton"
                        text: qsTr("Kick")
                        visible: kickButtonVisible
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.kickUserClicked(model.pubKey, memberItem.title)
                    },

                    StatusButton {
                        id: banButton
                        objectName: "MemberListItem_BanButton"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: banButtonVisible
                        text: qsTr("Ban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.banUserClicked(model.pubKey, memberItem.title)
                    },

                    StatusButton {
                        objectName: "MemberListItem_UnbanButton"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: unbanButtonVisible
                        text: qsTr("Unban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.unbanUserClicked(model.pubKey)
                    },

                    StatusButton {
                        id: acceptButton
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: acceptButtonVisible
                        text: qsTr("Accept")
                        type: StatusBaseButton.Type.Success
                        icon.name: "checkmark-circle"
                        icon.color: enabled ? Theme.palette.successColor1 : disabledTextColor
                        loading: model.requestToJoinLoading
                        enabled: !acceptPendingButtonVisible
                        onClicked: root.acceptRequestToJoin(model.requestToJoinId)
                    },

                    StatusButton {
                        id: rejectButton
                        opacity: rejectButtonVisible
                        text: qsTr("Reject")
                        type: StatusBaseButton.Type.Danger
                        icon.name: "close-circle"
                        icon.color: enabled ? Theme.palette.dangerColor1 : disabledTextColor
                        enabled: !rejectPendingButtonVisible
                        onClicked: root.declineRequestToJoin(model.requestToJoinId)
                    }
                ]

                readonly property string title: model.preferredDisplayName

                width: membersList.width
                color: "transparent"

                pubKey: model.isEnsVerified ? "" : Utils.getElidedCompressedPk(model.pubKey)
                nickName: model.localNickname
                userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
                status: model.onlineStatus
                icon.color: Utils.colorForColorId(model.colorId)
                icon.name: model.icon
                icon.width: 40
                icon.height: 40
                ringSettings.ringSpecModel: model.colorHash
                badge.visible: (root.panelType === MembersTabPanel.TabType.AllMembers)

                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        const profileType = Utils.getProfileType(model.isCurrentUser, false, model.isBlocked)
                        const contactType = Utils.getContactType(model.contactRequest, model.isContact)

                        const params = {
                            profileType, contactType,
                            pubKey: model.pubKey,
                            compressedPubKey: model.compressedPubKey,
                            emojiHash: root.utilsStore.getEmojiHash(model.pubKey),
                            colorHash: model.colorHash,
                            colorId: model.colorId,
                            displayName: memberItem.title || model.displayName,
                            userIcon: model.icon,
                            trustStatus: model.trustStatus,
                            onlineStatus: model.onlineStatus,
                            ensVerified: model.isEnsVerified,
                            hasLocalNickname: !!model.localNickname
                        }

                        Global.openMenu(memberContextMenuComponent, this, params)
                    } else if (mouse.button === Qt.LeftButton) {
                        Global.openProfilePopup(model.pubKey)
                    }
                }
            }
        }
    }

    Component {
        id: memberContextMenuComponent

        ProfileContextMenu {
            id: memberContextMenuView

            property string pubKey

            onOpenProfileClicked: Global.openProfilePopup(memberContextMenuView.pubKey, null)
            onCreateOneToOneChat: {
                Global.changeAppSectionBySectionType(Constants.appSection.chat)
                root.rootStore.chatCommunitySectionModule.createOneToOneChat("", membersContextMenuView.pubKey, "")
            }
            onReviewContactRequest: Global.openReviewContactRequestPopup(memberContextMenuView.pubKey, null)
            onSendContactRequest: Global.openContactRequestPopup(memberContextMenuView.pubKey, null)
            onEditNickname: Global.openNicknamePopupRequested(memberContextMenuView.pubKey, null)
            onRemoveNickname: root.rootStore.contactsStore.changeContactNickname(memberContextMenuView.pubKey,
                                                                                 "", memberContextMenuView.displayName, true)
            onUnblockContact: Global.unblockContactRequested(memberContextMenuView.pubKey)
            onMarkAsUntrusted: Global.markAsUntrustedRequested(memberContextMenuView.pubKey)
            onRemoveTrustStatus: root.rootStore.contactsStore.removeTrustStatus(memberContextMenuView.pubKey)
            onRemoveContact: Global.removeContactRequested(memberContextMenuView.pubKey)
            onBlockContact: Global.blockContactRequested(memberContextMenuView.pubKey)
            onMarkAsTrusted: Global.openMarkAsIDVerifiedPopup(memberContextMenuView.pubKey, null)
            onRemoveTrustedMark: Global.openRemoveIDVerificationDialog(memberContextMenuView.pubKey, null)
            onClosed: destroy()
        }
    }

    QtObject {
        id: d
        // This is used to calculate the max width of the pending text
        // so that the text aligned on all rows (the text might be different on each row)
        property real pendingTextMaxWidth: 0
    }
    onPanelTypeChanged: { d.pendingTextMaxWidth = 0 }
}
