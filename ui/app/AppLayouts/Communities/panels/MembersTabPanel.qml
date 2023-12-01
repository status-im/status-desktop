import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0
import shared.controls 1.0

import AppLayouts.Communities.layouts 1.0

Item {
    id: root

    property string placeholderText
    property var model
    property var rootStore
    property int memberRole: Constants.memberRole.none

    readonly property bool isOwner: memberRole === Constants.memberRole.owner
    readonly property bool isTokenMaster: memberRole === Constants.memberRole.tokenMaster

    signal kickUserClicked(string id, string name)
    signal banUserClicked(string id, string name)
    signal unbanUserClicked(string id)

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

            model: root.model
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

                // Request states
                readonly property bool isPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.Pending
                readonly property bool isAccepted: model.membershipRequestState === Constants.CommunityMembershipRequestState.Accepted
                readonly property bool isRejected: model.membershipRequestState === Constants.CommunityMembershipRequestState.Rejected
                readonly property bool isRejectedPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.RejectedPending
                readonly property bool isAcceptedPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.AcceptedPending
                readonly property bool isBanPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.BannedPending
                readonly property bool isUnbanPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.UnbannedPending
                readonly property bool isKickPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.KickedPending
                readonly property bool isBanned: model.membershipRequestState === Constants.CommunityMembershipRequestState.Banned
                readonly property bool isKicked: model.membershipRequestState === Constants.CommunityMembershipRequestState.Kicked

                // TODO: Connect to backend when available
                // The admin that initited the pending state can change the state. Actions are not visible for other admins
                readonly property bool ctaAllowed: !isRejectedPending && !isAcceptedPending && !isBanPending && !isUnbanPending && !isKickPending

                readonly property bool itsMe: model.pubKey.toLowerCase() === Global.userProfile.pubKey.toLowerCase()
                readonly property bool isHovered: memberItem.sensor.containsMouse
                readonly property bool canBeBanned: {
                    if (memberItem.itsMe) {
                        return false
                    }
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

                /// Pending states ///
                readonly property bool isPendingState: isAcceptedPending || isRejectedPending || isBanPending || isUnbanPending || isKickPending
                readonly property string pendingStateText:  isAcceptedPending ? qsTr("Accept pending...") :
                                                            isRejectedPending ? qsTr("Reject pending...") :
                                                            isBanPending ? qsTr("Ban pending...") :
                                                            isUnbanPending ? qsTr("Unban pending...") :
                                                            isKickPending ? qsTr("Kick pending...") : ""

                isAwaitingAddress: model.membershipRequestState === Constants.CommunityMembershipRequestState.AwaitingAddress

                statusListItemComponentsSlot.spacing: 16
                statusListItemTitleArea.anchors.rightMargin: 0
                statusListItemSubTitle.elide: Text.ElideRight
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
                        rightPadding: isKickPending || isBanPending || isUnbanPending ? 0 : Style.current.bigPadding
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
                        anchors.verticalCenter: parent.verticalCenter
                        visible: banButtonVisible
                        text: qsTr("Ban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.banUserClicked(model.pubKey, memberItem.title)
                    },

                    StatusButton {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: unbanButtonVisible
                        text: qsTr("Unban")
                        onClicked: root.unbanUserClicked(model.pubKey)
                    },

                    StatusButton {
                        id: acceptButton
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: acceptButtonVisible
                        text: qsTr("Accept")
                        icon.name: "checkmark-circle"
                        icon.color: enabled ? Theme.palette.successColor1 : disabledTextColor
                        normalColor: Theme.palette.successColor2
                        hoverColor: Theme.palette.successColor3
                        textColor: Theme.palette.successColor1
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
                        icon.color: enabled ? Style.current.danger : disabledTextColor
                        enabled: !rejectPendingButtonVisible
                        onClicked: root.declineRequestToJoin(model.requestToJoinId)
                    }
                ]

                width: membersList.width
                visible: memberSearch.text === "" || title.toLowerCase().includes(memberSearch.text.toLowerCase())
                height: visible ? implicitHeight : 0
                color: "transparent"

                pubKey: model.isEnsVerified ? "" : Utils.getElidedCompressedPk(model.pubKey)
                nickName: model.localNickname
                userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
                status: model.onlineStatus
                asset.color: Utils.colorForColorId(model.colorId)
                asset.name: model.icon
                asset.isImage: !!model.icon
                asset.isLetterIdenticon: !model.icon
                asset.width: 40
                asset.height: 40
                ringSettings.ringSpecModel: model.colorHash
                statusListItemIcon.badge.visible: (root.panelType === MembersTabPanel.TabType.AllMembers)

                onClicked: {
                    if(mouse.button === Qt.RightButton) {
                        Global.openMenu(memberContextMenuComponent, this, {
                                            selectedUserPublicKey: model.pubKey,
                                            selectedUserDisplayName: memberItem.title,
                                            selectedUserIcon: asset.name,
                                        })
                    } else {
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
            store: root.rootStore
            myPublicKey: Global.userProfile.pubKey

            onOpenProfileClicked: {
                Global.openProfilePopup(publicKey, null)
            }
            onCreateOneToOneChat: {
                Global.changeAppSectionBySectionType(Constants.appSection.chat)
                root.rootStore.chatCommunitySectionModule.createOneToOneChat(communityId, chatId, ensName)
            }
            onClosed: {
                destroy()
            }
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
