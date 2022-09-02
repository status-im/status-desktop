import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls.chat 1.0

import "../../layouts"

Item {
    id: root

    property string placeholderText
    property var model

    signal userProfileClicked(string id)
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

    property int panelType: CommunityMembersTabPanel.TabType.AllMembers

    ColumnLayout {
        anchors.fill: parent
        spacing: 30

        StatusInput {
            id: memberSearch
            Layout.preferredWidth: 350
            Layout.leftMargin: 12
            maximumHeight: 36
            topPadding: 0
            bottomPadding: 0
            rightPadding: 0
            placeholderText: root.placeholderText
            input.asset.name: "search"
            enabled: model.count > 0
        }

        ListView {
            id: membersList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.model
            clip: true
            spacing: 15

            delegate: StatusMemberListItem {
                id: memberItem

                readonly property bool itsMe: model.pubKey.toLowerCase() === userProfile.pubKey.toLowerCase()
                readonly property bool isHovered: memberItem.sensor.containsMouse
                readonly property bool canBeBanned: !memberItem.itsMe && !model.isAdmin

                statusListItemComponentsSlot.spacing: 16
                statusListItemTitleArea.anchors.rightMargin: 0
                statusListItemSubTitle.elide: Text.ElideRight
                rightPadding: 75
                leftPadding: 12

                components: [
                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.AllMembers) && isHovered && canBeBanned
                        text: qsTr("Kick")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.kickUserClicked(model.pubKey, model.displayName)
                    },

                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.AllMembers) && isHovered && canBeBanned
                        text: qsTr("Ban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Small
                        onClicked: root.banUserClicked(model.pubKey, model.displayName)
                    },

                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.BannedMembers) && isHovered && canBeBanned
                        text: qsTr("Unban")
                        type: StatusBaseButton.Type.Normal
                        size: StatusBaseButton.Size.Large
                        onClicked: root.unbanUserClicked(model.pubKey)
                        width: 95
                        height: 44
                    },

                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.PendingRequests ||
                                  root.panelType === CommunityMembersTabPanel.TabType.DeclinedRequests) && isHovered
                        text: qsTr("Accept")
                        type: StatusBaseButton.Type.Normal
                        size: StatusBaseButton.Size.Large
                        icon.name: "checkmark-circle"
                        icon.color: Theme.palette.successColor1
                        normalColor: Theme.palette.successColor2
                        hoverColor: Theme.palette.successColor3
                        textColor: Theme.palette.successColor1
                        onClicked: root.acceptRequestToJoin(model.requestToJoinId)
                        width: 124
                        height: 44
                    },

                    StatusButton {
                        visible: (root.panelType === CommunityMembersTabPanel.TabType.PendingRequests) && isHovered
                        text: qsTr("Reject")
                        type: StatusBaseButton.Type.Danger
                        icon.name: "close-circle"
                        icon.color: Style.current.danger
                        onClicked: root.declineRequestToJoin(model.requestToJoinId)
                        width: 118
                        height: 44
                    }
                ]

                width: membersList.width
                visible: memberSearch.text === "" || title.toLowerCase().includes(memberSearch.text.toLowerCase())
                height: visible ? implicitHeight : 0
                color: "transparent"

                pubKey: Utils.getElidedCompressedPk(model.pubKey)
                nickName: model.localNickname
                userName: model.displayName
                status: model.onlineStatus
                asset.color: Utils.colorForPubkey(model.pubKey) // FIXME: use model.colorId
                asset.name: model.icon
                asset.isImage: true
                asset.imgIsIdenticon: false
                asset.width: 40
                asset.height: 40
                ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.pubKey)
                statusListItemIcon.badge.visible: (root.panelType === CommunityMembersTabPanel.TabType.AllMembers)

                onClicked: root.userProfileClicked(model.pubKey)
            }
        }
    }
}
