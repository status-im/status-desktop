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
            spacing: Style.current.padding

            StatusBaseText {
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                color: Theme.palette.baseColor1
                text: qsTr("Communities you've joined")
            }

            CommunitiesListPanel {
                width: parent.width
                model: root.profileSectionStore.communitiesList

                onLeaveCommunityClicked: {
                    root.profileSectionStore.communitiesProfileModule.leaveCommunity(communityId)
                }

                onSetCommunityMutedClicked: {
                    root.profileSectionStore.communitiesProfileModule.setCommunityMuted(communityId, muted)
                }

                onSetActiveCommunityClicked: {
                    rootStore.setActiveCommunity(communityId)
                }

                onInviteFriends: {
                    Global.openInviteFriendsToCommunityPopup(communityData,
                                                             root.profileSectionStore.communitiesProfileModule,
                                                             null)
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

} // ScrollView
