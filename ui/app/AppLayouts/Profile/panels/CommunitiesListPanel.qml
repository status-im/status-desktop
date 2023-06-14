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
    signal closeCommunityClicked(string communityId)
    signal leaveCommunityClicked(string community, string communityId, string outroMessage)
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
        tertiaryTitle: qsTr("%n member(s)", "", model.members.count)
        asset.name: model.image
        asset.isLetterIdenticon: !model.image
        asset.bgColor: model.color || Theme.palette.primaryColor1
        asset.width: 40
        asset.height: 40
        visible: model.joined
        height: visible ? implicitHeight: 0

        onClicked: setActiveCommunityClicked(model.id)

        components: [
            StatusFlatButton {
                anchors.verticalCenter: parent.verticalCenter
                objectName: "CommunitiesListPanel_leaveCommunityPopupButton"
                size: StatusBaseButton.Size.Small
                type: StatusBaseButton.Type.Danger
                borderColor: "transparent"
                enabled: !model.amISectionAdmin
                text: model.spectated ? qsTr("Close Community") : qsTr("Leave Community")
                onClicked: model.spectated ? root.closeCommunityClicked(model.id) : root.leaveCommunityClicked(model.name, model.id, model.outroMessage)
            },
            StatusFlatButton {
                anchors.verticalCenter: parent.verticalCenter
                size: StatusBaseButton.Size.Small
                icon.name: model.muted ? "notification-muted" : "notification"
                onClicked: root.setCommunityMutedClicked(model.id, !model.muted)
            },
            StatusFlatButton {
                anchors.verticalCenter: parent.verticalCenter
                size: StatusBaseButton.Size.Small
                icon.name: "invite-users"
                onClicked: root.inviteFriends(model)
            }
        ]
    }
}
