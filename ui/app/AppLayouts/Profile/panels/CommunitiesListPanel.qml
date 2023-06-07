import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

import shared.controls.chat.menuItems 1.0

StatusListView {
    id: root

    property bool hasAddedContacts: false

    signal inviteFriends(var communityData)

    signal closeCommunityClicked(string communityId)
    signal leaveCommunityClicked(string community, string communityId, string outroMessage)

    signal setCommunityMutedClicked(string communityId, int mutedType)

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
                size: StatusBaseButton.Size.Small
                icon.name: "dots-icon"
                onClicked: menu.popup(0, height)

                property StatusMenu menu: StatusMenu {
                    id: communityContextMenu
                    width: 180

                    StatusAction {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                        enabled: model.canManageUsers
                        onTriggered: root.inviteFriends(model)
                    }

                    MuteChatMenuItem {
                        enabled: !model.muted
                        title: qsTr("Mute Community")
                        onMuteTriggered: {
                            root.setCommunityMutedClicked(model.id, interval)
                            communityContextMenu.close()
                        }
                    }

                    StatusAction {
                        enabled: model.muted
                        text: qsTr("Unmute Community")
                        icon.name: "notification-muted"
                        onTriggered: root.setCommunityMutedClicked(model.id, Constants.MutingVariations.Unmuted)
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: model.spectated ? qsTr("Close Community") : qsTr("Leave Community")
                        icon.name: "arrow-left"
                        type: StatusAction.Type.Danger
                        onTriggered: model.spectated ? root.closeCommunityClicked(model.id)
                                                     : root.leaveCommunityClicked(model.name, model.id, model.outroMessage)
                    }
                }
            }
        ]
    }
}
