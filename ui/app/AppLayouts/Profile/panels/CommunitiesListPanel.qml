import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

ListView {
    id: root

    property bool hasAddedContacts: false

    signal inviteFriends(var communityData)
    signal leaveCommunityClicked(var communityId)

    interactive: false
    implicitHeight: contentItem.childrenRect.height
    spacing: 0

    delegate: StatusListItem {
        id: statusCommunityItem
        width: parent.width
        title: model.name
        subTitle: model.description
        tertiaryTitle: qsTr(model.members.count === 1 ?"%1 member"
                                                      :"%1 members").arg(model.members.count)
        image.source: model.image
        icon.isLetterIdenticon: !model.image
        icon.background.color: model.color || Theme.palette.primaryColor1
        visible: model.joined
        height: visible ? implicitHeight: 0

        sensor.hoverEnabled: false

        components: [
            StatusFlatButton {
                size: StatusBaseButton.Size.Small
                type: StatusBaseButton.Type.Danger
                border.color: "transparent"
                text: qsTr("Leave community")
                onClicked: {
                    Global.openPopup(leaveCommunityPopup, {
                                         community: model.name,
                                         communityId: model.id
                                     })
                }
            },
            StatusFlatRoundButton {
                type: StatusFlatRoundButton.Type.Secondary
                width: 44
                height: 44
                icon.source: model.muted ? Style.svg("communities/notifications-muted")
                                         : Style.svg("communities/notifications")
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

    property Component leaveCommunityPopup: StatusModal {
        id: leavePopup
        property string community: ""
        property var communityId
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
