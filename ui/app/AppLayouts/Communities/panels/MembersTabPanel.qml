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

        StatusInput {
            id: memberSearch
            Layout.preferredWidth: 400
            Layout.leftMargin: 12
            maximumHeight: 36
            topPadding: 0
            bottomPadding: 0
            rightPadding: 0
            placeholderText: root.placeholderText
            input.asset.name: "search"
            enabled: !!model && model.count > 0
        }

        ListView {
            id: membersList
            objectName: "CommunityMembersTabPanel_MembersListViews"

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.model
            clip: true
            spacing: 15

            delegate: StatusMemberListItem {
                id: memberItem

                readonly property bool itsMe: model.pubKey.toLowerCase() === userProfile.pubKey.toLowerCase()
                readonly property bool isHovered: memberItem.sensor.containsMouse
                readonly property bool canBeBanned: !memberItem.itsMe && (model.memberRole !== Constants.memberRole.owner && model.memberRole !== Constants.memberRole.admin)

                statusListItemComponentsSlot.spacing: 16
                statusListItemTitleArea.anchors.rightMargin: 0
                statusListItemSubTitle.elide: Text.ElideRight
                rightPadding: 75
                leftPadding: 12

                components: [
                    StatusButton {
                        objectName: "MemberListIten_KickButton"
                        visible: (root.panelType === MembersTabPanel.TabType.AllMembers) && isHovered && canBeBanned
                        text: qsTr("Kick")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.kickUserClicked(model.pubKey, model.displayName)
                    },

                    StatusButton {
                        visible: (root.panelType === MembersTabPanel.TabType.AllMembers) && isHovered && canBeBanned
                        text: qsTr("Ban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.banUserClicked(model.pubKey, model.displayName)
                    },

                    StatusButton {
                        visible: (root.panelType === MembersTabPanel.TabType.BannedMembers) && isHovered && canBeBanned
                        text: qsTr("Unban")
                        onClicked: root.unbanUserClicked(model.pubKey)
                    },

                    DisabledTooltipButton {
                        id: acceptButton
                        visible: ((root.panelType === MembersTabPanel.TabType.PendingRequests ||
                                    root.panelType === MembersTabPanel.TabType.DeclinedRequests) && isHovered) || 
                                    model.membershipRequestState === Constants.CommunityMembershipRequestState.AcceptedPending
                                    //TODO: Only the current user can reject a pending request, so we should check that here

                        tooltipText: qsTr("Waiting for owner node to come online")
                        interactive: model.membershipRequestState !== Constants.CommunityMembershipRequestState.AcceptedPending
                        buttonComponent: StatusButton {
                            text: model.membershipRequestState == Constants.CommunityMembershipRequestState.AcceptedPending ? qsTr("Accept pending") : qsTr("Accept")
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
                        //using opacity instead of visible to avoid the acceptButton jumping around 
                        opacity: ((root.panelType === MembersTabPanel.TabType.PendingRequests) && isHovered) ||
                                    model.membershipRequestState === Constants.CommunityMembershipRequestState.RejectedPending
                                    //TODO: Only the current user can reject a pending request, so we should check that here

                        tooltipText: qsTr("Waiting for owner node to come online")
                        interactive: model.membershipRequestState !== Constants.CommunityMembershipRequestState.RejectedPending
                        buttonComponent: StatusButton {
                            text: model.membershipRequestState == Constants.CommunityMembershipRequestState.RejectedPending ? qsTr("Reject pending") : qsTr("Reject")
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
                                            selectedUserDisplayName: userName,
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
            myPublicKey: userProfile.pubKey

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
