import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusListView {
    id: root

    property bool hasAddedContacts: false

    signal inviteFriends(var communityData)
    signal leaveCommunityClicked(string communityId)
    signal setCommunityMutedClicked(string communityId, bool muted)
    signal setActiveCommunityClicked(string communityId)

    interactive: false
    implicitHeight: contentItem.childrenRect.height
    spacing: 0

    delegate: StatusListItem {
        id: statusCommunityItem
        width: parent.width
        title: model.name
        statusListItemTitle.font.pixelSize: 17
        statusListItemTitle.font.bold: true
        subTitle: model.description
        tertiaryTitle: qsTr("%n member(s)", "", (model.members_count || model.members.count))
        asset.name: model.image
        asset.isImage: asset.name.includes("data")
        asset.isLetterIdenticon: !model.image
        asset.bgColor: model.color || Theme.palette.primaryColor1
        asset.width: 40
        asset.height: 40
        // TODO: this model is including ALL communities and using the joined flag to set visibility
        // this shouldn't be done this way, instead the list should come already filtered from the backend
        visible: model.joined
        height: visible ? implicitHeight: 0

        onClicked: setActiveCommunityClicked(model.model_id || model.id)

        components: [
            StatusFlatButton {
                objectName: "CommunitiesListPanel_leaveCommunityPopupButton"
                size: StatusBaseButton.Size.Small
                type: StatusBaseButton.Type.Danger
                borderColor: "transparent"
                text: qsTr("Leave Community")
                onClicked: {
                    Global.openPopup(leaveCommunityPopup, {
                                         community: model.name,
                                         communityId: (model.model_id || model.id)
                                     })
                }
            },
            StatusFlatButton {
                size: StatusBaseButton.Size.Tiny
                leftPadding: 4
                rightPadding: 0
                icon.name: model.muted ? "notification-muted" : "notification"
                onClicked: root.setCommunityMutedClicked(model.model_id || model.id, !model.muted)
            },
            StatusFlatButton {
                size: StatusBaseButton.Size.Tiny
                leftPadding: 4
                rightPadding: 0
                icon.name: "invite-users"
                onClicked: root.inviteFriends(model)
            }
        ]
    } // StatusListItem

    property Component leaveCommunityPopup: StatusModal {
        id: leavePopup

        property string community: ""
        property string communityId: ""

        anchors.centerIn: parent
        header.title: qsTr("Leave %1").arg(community)
        contentItem: Item {
            implicitWidth: 368
            implicitHeight: msg.implicitHeight + 32
            StatusBaseText {
                id: msg
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 16
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("Are you sure you want to leave? Once you leave, you will have to request to rejoin if you change your mind.")
                color: Theme.palette.directColor1
                font.pixelSize: 15
            }
        }

        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: leavePopup.close()
            },
            StatusButton {
                objectName: "CommunitiesListPanel_leaveCommunityButtonInPopup"
                type: StatusBaseButton.Type.Danger
                text: qsTr("Leave community")
                onClicked: {
                    root.leaveCommunityClicked(leavePopup.communityId)
                    leavePopup.close()
                }
            }
        ]
    }
} // ListView
