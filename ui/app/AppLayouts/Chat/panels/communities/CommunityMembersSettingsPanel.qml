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

SettingsPageLayout {
    id: root

    property var membersModel
    property var bannedMembersModel
    property var pendingMemberRequestsModel
    property var declinedMemberRequestsModel
    property string communityName

    property bool editable: true

    signal membershipRequestsClicked()
    signal kickUserClicked(string id)
    signal banUserClicked(string id)
    signal unbanUserClicked(string id)
    signal acceptRequestToJoin(string id)
    signal declineRequestToJoin(string id)

    function goTo(tab: int) {
        if(root.contentItem) {
            root.contentItem.goTo(tab)
        }
    }

    title: qsTr("Members")

    content: ColumnLayout {

        function goTo(tab: int) {
            let tabButton = membersTabBar.currentItem
            switch (tab) {
            case Constants.CommunityMembershipSubSections.Members:
                tabButton = allMembersBtn
                break
            case Constants.CommunityMembershipSubSections.MembershipRequests:
                tabButton = pendingRequestsBtn
                break
            case Constants.CommunityMembershipSubSections.RejectedMembers:
                tabButton = declinedRequestsBtn
                break
            case Constants.CommunityMembershipSubSections.BannedMembers:
                tabButton = bannedBtn
                break
            }
            
            if(tabButton.enabled)
                membersTabBar.currentIndex = tabButton.TabBar.index
        }
        
        spacing: 19

        StatusTabBar {
            id: membersTabBar
            Layout.fillWidth: true
            Layout.topMargin: 5

            StatusTabButton {
                id: allMembersBtn
                width: implicitWidth
                text: qsTr("All Members")
            }

            StatusTabButton {
                id: pendingRequestsBtn
                width: implicitWidth
                text: qsTr("Pending Requests")
                enabled: pendingMemberRequestsModel.count > 0
            }

            StatusTabButton {
                id: declinedRequestsBtn
                width: implicitWidth
                text: qsTr("Rejected")
                enabled: declinedMemberRequestsModel.count > 0
            }

            StatusTabButton {
                id: bannedBtn
                width: implicitWidth
                enabled: bannedMembersModel.count > 0
                text: qsTr("Banned")
            }
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: membersTabBar.currentIndex

            CommunityMembersTabPanel {
                model: root.membersModel
                communityMemberContextMenu: root.communityMemberContextMenu
                placeholderText: {
                    if (root.membersModel.count === 0) {
                        return qsTr("No members to search")
                    } else {
                        return qsTr("Search %1's %n member(s)", "", root.membersModel ? root.membersModel.count : 0).arg(root.communityName)
                    }
                }
                panelType: CommunityMembersTabPanel.TabType.AllMembers

                Layout.fillWidth: true
                Layout.fillHeight: true

                onKickUserClicked: {
                    kickModal.userNameToKick = name
                    kickModal.userIdToKick = id
                    kickModal.open()
                }

                onBanUserClicked: {
                    banModal.userNameToBan = name
                    banModal.userIdToBan = id
                    banModal.open()
                }
            }

            CommunityMembersTabPanel {
                model: root.pendingMemberRequestsModel
                communityMemberContextMenu: root.communityMemberContextMenu
                placeholderText: {
                    if (root.pendingMemberRequestsModel.count === 0) {
                        return qsTr("No pending requests to search")
                    } else {
                        return qsTr("Search %1's %2 pending request%3").arg(root.communityName)
                                                              .arg(root.pendingMemberRequestsModel.count)
                                                              .arg(root.pendingMemberRequestsModel.count > 1 ? "s" : "")
                    }
                }
                panelType: CommunityMembersTabPanel.TabType.PendingRequests

                Layout.fillWidth: true
                Layout.fillHeight: true

                onAcceptRequestToJoin: root.acceptRequestToJoin(id)
                onDeclineRequestToJoin: root.declineRequestToJoin(id)
            }

            CommunityMembersTabPanel {
                model: root.declinedMemberRequestsModel
                communityMemberContextMenu: root.communityMemberContextMenu
                placeholderText: {
                    if (root.declinedMemberRequestsModel.count === 0) {
                        return qsTr("No rejected members to search")
                    } else {
                        return qsTr("Search %1's %2 rejected member%3").arg(root.communityName)
                                                              .arg(root.declinedMemberRequestsModel.count)
                                                              .arg(root.declinedMemberRequestsModel.count > 1 ? "s" : "")
                    }
                }
                panelType: CommunityMembersTabPanel.TabType.DeclinedRequests

                Layout.fillWidth: true
                Layout.fillHeight: true

                onAcceptRequestToJoin: root.acceptRequestToJoin(id)
            }

            CommunityMembersTabPanel {
                model: root.bannedMembersModel
                communityMemberContextMenu: root.communityMemberContextMenu
                placeholderText: {
                    if (root.bannedMembersModel.count === 0) {
                        return qsTr("No banned members to search")
                    } else {
                        return qsTr("Search %1's %2 banned member%3").arg(root.communityName)
                                                              .arg(root.bannedMembersModel.count)
                                                              .arg(root.bannedMembersModel.count > 1 ? "s" : "")
                    }
                }
                panelType: CommunityMembersTabPanel.TabType.BannedMembers

                Layout.fillWidth: true
                Layout.fillHeight: true

                onUnbanUserClicked: root.unbanUserClicked(id)
            }
        }
    }

    StatusModal {
        id: banModal

        property string userNameToBan: ""
        property string userIdToBan: ""

        readonly property string text: qsTr("Are you sure you ban <b>%1</b> from %2?").arg(userNameToBan).arg(root.communityName)

        anchors.centerIn: parent
        width: 400
        headerSettings.title: qsTr("Ban %1").arg(userNameToBan)

        contentItem: StatusBaseText {
            id: banContentText
            anchors.centerIn: parent
            font.pixelSize: 15
            color: Theme.palette.directColor1
            padding: 15
            wrapMode: Text.WordWrap
            text: banModal.text
        }

        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: banModal.close()
                normalColor: "transparent"
                hoverColor: "transparent"
            },
            StatusButton {
                id: banButton
                text: qsTr("Ban")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.banUserClicked(banModal.userIdToBan)
                    banModal.close()
                }
            }
        ]
    }

    StatusModal {
        id: kickModal

        property string userNameToKick: ""
        property string userIdToKick: ""

        readonly property string text : qsTr("Are you sure you kick <b>%1</b> from %2?").arg(userNameToKick).arg(communityName)

        anchors.centerIn: parent
        width: 400
        headerSettings.title: qsTr("Kick %1").arg(userNameToKick)

        contentItem: StatusBaseText {
            id: kickContentText
            anchors.centerIn: parent
            font.pixelSize: 15
            color: Theme.palette.directColor1
            padding: 15
            wrapMode: Text.WordWrap
            text: kickModal.text
        }

        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: kickModal.close()
                normalColor: "transparent"
                hoverColor: "transparent"
            },
            StatusButton {
                objectName: "CommunityMembers_KickModal_KickButton"
                text: qsTr("Kick")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.kickUserClicked(kickModal.userIdToKick)
                    kickModal.close()
                }
            }
        ]
    }
}
