import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.popups 1.0

import "../panels"
import "../../Chat/popups/community"

SettingsContentBase {
    id: root

    property var profileSectionStore
    property var rootStore
    property var contactStore

    clip: true

    titleRowComponentLoader.sourceComponent: StatusButton {
        size: StatusBaseButton.Size.Small
        text: qsTr("Import community")
        onClicked: {
            Global.openPopup(importCommunitiesPopupComponent)
        }
    }

    Item {
        id: rootItem
        width: root.contentWidth
        height: childrenRect.height

        Column {
            id: rootLayout
            width: parent.width
            anchors.top: parent.top
            anchors.left: parent.left

            StatusBaseText {
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                color: Theme.palette.baseColor1
                text: qsTr("Communities you've joined")
                font.pixelSize: 15
            }

            CommunitiesListPanel {
                width: parent.width
                model: root.profileSectionStore.communitiesList
                onLeaveCommunityClicked: {
                    root.profileSectionStore.communitiesProfileModule.leaveCommunity(leavePopup.communityId)
                }
                onInviteFriends: {
                    Global.openPopup(inviteFriendsToCommunityPopup, {
                                         community: communityData,
                                         hasAddedContacts: root.contactStore.myContactsModel.count > 0,
                                         communitySectionModule: communityProfileModule
                                     })
                }
            }

        } // Column
    } // Item

    property Component importCommunitiesPopupComponent: ImportCommunityPopup {
        anchors.centerIn: parent
        store: root.profileSectionStore
        onClosed: {
            destroy()
        }
    }

    property Component inviteFriendsToCommunityPopup: InviteFriendsToCommunityPopup {
        anchors.centerIn: parent
        rootStore: root.rootStore
        contactsStore: root.contactStore
        onClosed: {
            destroy()
        }

        onSendInvites: {
            const error = communitySectionModule.inviteUsersToCommunity(communty.id, JSON.stringify(pubKeys))
            processInviteResult(error)
        }
    }

} // ScrollView
