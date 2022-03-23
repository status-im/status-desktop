import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

ListView {
    id: root

    property var communitySectionModule
    property var communityProfileModule
    property bool hasAddedContacts: false

    signal inviteFriends(var communityData)

    interactive: false
    implicitHeight: contentItem.childrenRect.height
    spacing: 0

    delegate: StatusListItem {
        id: statusCommunityItem
        width: parent.width
        title: model.name
        subTitle: model.description
        tertiaryTitle: qsTrId("-1-members").arg(model.members.count)
        image.source: model.image
        icon.isLetterIdenticon: !model.image
        icon.background.color: model.color || Theme.palette.primaryColor1
        visible: model.joined
        height: visible ? implicitHeight: 0

        components: [
            StatusFlatButton {
                size: StatusBaseButton.Size.Small
                type: StatusBaseButton.Type.Danger
                text: qsTrId("leave-community")
                onClicked: root.communityProfileModule.leaveCommunity(model.id)
            },
            StatusFlatRoundButton {
                type: StatusFlatRoundButton.Type.Secondary
                width: 44
                height: 44
                icon.name: model.muted ? "notification-muted" : "notification"
                onClicked: root.communityProfileModule.setCommunityMuted(model.id, !model.muted)
            },

            StatusFlatRoundButton {
                type: StatusFlatRoundButton.Type.Secondary
                width: 44
                height: 44
                icon.name: "invite-users"
                onClicked: root.inviteFriends(model)
            }
        ]
    } // StatusListItem
} // ListView
