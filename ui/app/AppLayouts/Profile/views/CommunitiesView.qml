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

ScrollView {
    id: root

    property var profileSectionStore
    property var rootStore
    property var contactStore
    property real profileContentWidth

    contentHeight: rootItem.height

    clip: true

    Item {
        id: rootItem
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: childrenRect.height

        StatusFlatRoundButton {
            id: notificationsButton
            anchors.right: parent.right
            anchors.margins: 18
            type: StatusFlatRoundButton.Type.Secondary
            width: 44
            height: 44
            icon.name: "notification"
        }
        Column {
            id: rootLayout
            anchors.top: notificationsButton.bottom
            width: profileContentWidth
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                id: headerLayout
                width: parent.width

                StatusBaseText {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    //% "Communities"
                    text: qsTrId("communities")
                    font.bold: true
                    font.pixelSize: 28
                    color: Theme.palette.directColor1
                }

                Item {
                    Layout.fillWidth: true
                }

                StatusButton {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    size: StatusBaseButton.Size.Small
                    text: qsTrId("import-community")
                    onClicked: {
                        Global.openPopup(importCommunitiesPopupComponent)
                    }
                }
            } // RowLayout
            Item { // Spacer
                width: 1
                height: 37
            }
            StatusBaseText {
                color: Theme.palette.baseColor1
                text: qsTr("Communities you've joined")
                font.pixelSize: 15
            }

            CommunitiesListPanel {
                width: parent.width
                model: root.profileSectionStore.communitiesList
                communitySectionModule: root.profileSectionStore.communitiesModuleInst
                communityProfileModule: root.profileSectionStore.communitiesProfileModule

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
