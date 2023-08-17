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

                readonly property bool itsMe: model.pubKey.toLowerCase() === Global.userProfile.pubKey.toLowerCase()
                readonly property bool isHovered: memberItem.sensor.containsMouse
                readonly property bool canBeBanned: !memberItem.itsMe && (model.memberRole !== Constants.memberRole.owner && model.memberRole !== Constants.memberRole.admin)
                readonly property bool canEnableKickBanButtons: canBeBanned && root.panelType === MembersTabPanel.TabType.AllMembers
                readonly property bool kickEnabled: canEnableKickBanButtons && model.membershipRequestState !== Constants.CommunityMembershipRequestState.KickedPending
                readonly property bool banEnabled: canEnableKickBanButtons && model.membershipRequestState !== Constants.CommunityMembershipRequestState.BannedPending
                readonly property bool kickVisible: (isHovered || !kickEnabled) && banEnabled
                readonly property bool banVisible: (isHovered || !banEnabled) && kickEnabled
                readonly property bool unBanVisible: (root.panelType === MembersTabPanel.TabType.BannedMembers) && isHovered && canBeBanned

                readonly property bool isRejectedPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.RejectedPending
                readonly property bool isAcceptedPending: model.membershipRequestState === Constants.CommunityMembershipRequestState.AcceptedPending

                statusListItemComponentsSlot.spacing: 16
                statusListItemTitleArea.anchors.rightMargin: 0
                statusListItemSubTitle.elide: Text.ElideRight
                rightPadding: 75
                leftPadding: 12

                components: [
                    DisabledTooltipButton {
                        id: kickButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: kickVisible
                        interactive: kickEnabled
                        tooltipText: qsTr("Waiting for owner node to come online")
                        buttonComponent: StatusButton {
                            objectName: "MemberListItem_KickButton"
                            text: model.membershipRequestState === Constants.CommunityMembershipRequestState.KickedPending ? qsTr("Kick pending") : qsTr("Kick")
                            type: StatusBaseButton.Type.Danger
                            size: StatusBaseButton.Size.Small
                            onClicked: root.kickUserClicked(model.pubKey, memberItem.title)
                            enabled: kickButton.interactive
                        }
                    },

                    DisabledTooltipButton {
                        id: banButton
                        anchors.verticalCenter: parent.verticalCenter
                        //using opacity instead of visible to avoid the acceptButton jumping around
                        opacity: banVisible
                        interactive: banEnabled
                        tooltipText: banVisible ? qsTr("Waiting for owner node to come online") : ""
                        buttonComponent: StatusButton {
                            text: model.membershipRequestState === Constants.CommunityMembershipRequestState.BannedPending || !banVisible ? qsTr("Ban pending") : qsTr("Ban")
                            type: StatusBaseButton.Type.Danger
                            size: StatusBaseButton.Size.Small
                            onClicked: root.banUserClicked(model.pubKey, memberItem.title)
                            enabled: banButton.interactive
                        }
                    },

                    StatusButton {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: unBanVisible
                        text: qsTr("Unban")
                        onClicked: root.unbanUserClicked(model.pubKey)
                    },

                    DisabledTooltipButton {
                        id: acceptButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: ((root.panelType === MembersTabPanel.TabType.PendingRequests ||
                                    root.panelType === MembersTabPanel.TabType.DeclinedRequests) && isHovered) || 
                                    isAcceptedPending
                                    //TODO: Only the current user can reject a pending request, so we should check that here

                        tooltipText: qsTr("Waiting for owner node to come online")
                        interactive: !isAcceptedPending
                        buttonComponent: StatusButton {
                            text: isAcceptedPending ? qsTr("Accept Pending") : qsTr("Accept")
                            icon.name: "checkmark-circle"
                            icon.color: enabled ? Theme.palette.successColor1 : disabledTextColor
                            normalColor: Theme.palette.successColor2
                            hoverColor: Theme.palette.successColor3
                            textColor: Theme.palette.successColor1
                            loading: model.requestToJoinLoading
                            enabled: acceptButton.interactive
                            onClicked: root.acceptRequestToJoin(model.requestToJoinId)
                        }
                    },

                    DisabledTooltipButton {
                        id: rejectButton
                        anchors.verticalCenter: parent.verticalCenter
                        //using opacity instead of visible to avoid the acceptButton jumping around 
                        opacity: ((root.panelType === MembersTabPanel.TabType.PendingRequests) && isHovered) || isRejectedPending
                                    //TODO: Only the current user can reject a pending request, so we should check that here

                        tooltipText: qsTr("Waiting for owner node to come online")
                        interactive: !isRejectedPending
                        buttonComponent: StatusButton {
                            text: isRejectedPending ? qsTr("Reject pending") : qsTr("Reject")
                            type: StatusBaseButton.Type.Danger
                            icon.name: "close-circle"
                            icon.color: enabled ? Style.current.danger : disabledTextColor
                            enabled: rejectButton.interactive
                            onClicked: root.declineRequestToJoin(model.requestToJoinId)
                        }
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
}
