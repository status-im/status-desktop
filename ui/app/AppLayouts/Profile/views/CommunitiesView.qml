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

    property var communitiesList
    property var store

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
                model: root.communitiesList

                onLeaveCommunityClicked: {
                    root.store.leaveCommunity(communityId)
                }

                onSetCommunityMutedClicked: {
                    root.store.setCommunityMuted(communityId, muted)
                }

                onSetActiveCommunityClicked: {
                    root.store.setActiveCommunity(communityId)
                }

                onInviteFriends: {
                    Global.openInviteFriendsToCommunityPopup(communityData, root.store)
                }
            }
        } // Column
    } // Item

    property Component importCommunitiesPopupComponent: ImportCommunityPopup {
        anchors.centerIn: parent
        store: root.store
        onClosed: {
            destroy()
        }
    }
} // ScrollView
