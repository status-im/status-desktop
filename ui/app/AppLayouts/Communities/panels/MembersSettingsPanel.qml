import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import utils 1.0

import AppLayouts.Chat.stores 1.0
import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.popups 1.0

SettingsPage {
    id: root

    property RootStore rootStore
    property var membersModel
    property var bannedMembersModel
    property var pendingMembersModel
    property var declinedMembersModel
    property string communityName

    property int memberRole
    property bool editable: true

    signal membershipRequestsClicked()
    signal kickUserClicked(string id)
    signal banUserClicked(string id, bool deleteAllMessages)
    signal unbanUserClicked(string id)
    signal acceptRequestToJoin(string id)
    signal declineRequestToJoin(string id)
    signal viewMemberMessagesClicked(string pubKey, string displayName)

    function goTo(tab: int) {
        if(root.contentItem) {
            root.contentItem.goTo(tab)
        }
    }

    title: qsTr("Members")

    contentItem: ColumnLayout {

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
            
            if (tabButton.enabled)
                membersTabBar.currentIndex = tabButton.TabBar.index
        }
        
        spacing: 19

        StatusTabBar {
            id: membersTabBar
            Layout.fillWidth: true
            Layout.topMargin: 5

            StatusTabButton {
                id: allMembersBtn
                objectName: "allMembersButton"
                width: implicitWidth
                text: qsTr("All Members")
            }

            StatusTabButton {
                id: pendingRequestsBtn
                objectName: "pendingRequestsButton"
                width: implicitWidth
                text: qsTr("Pending Requests")
                enabled: pendingMembersModel.ModelCount.count > 0
            }

            StatusTabButton {
                id: declinedRequestsBtn
                objectName: "declinedRequestsButton"
                width: implicitWidth
                text: qsTr("Rejected")
                enabled: declinedMembersModel.ModelCount.count > 0
            }

            StatusTabButton {
                id: bannedBtn
                objectName: "bannedButton"
                width: implicitWidth
                enabled: bannedMembersModel.ModelCount.count > 0
                text: qsTr("Banned")
            }
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: membersTabBar.currentIndex

            MembersTabPanel {
                model: root.membersModel
                rootStore: root.rootStore
                memberRole: root.memberRole
                placeholderText: {
                    if (root.membersModel.ModelCount.count === 0)
                        return qsTr("No members to search")

                    return qsTr("Search %1's %n member(s)", "", root.membersModel ? root.membersModel.ModelCount.count : 0).arg(root.communityName)
                }
                panelType: MembersTabPanel.TabType.AllMembers

                Layout.fillWidth: true
                Layout.fillHeight: true

                onKickUserClicked: {
                    kickBanPopup.mode = KickBanPopup.Mode.Kick
                    kickBanPopup.username = name
                    kickBanPopup.userId = id
                    kickBanPopup.open()
                }

                onBanUserClicked: {
                    kickBanPopup.mode = KickBanPopup.Mode.Ban
                    kickBanPopup.username = name
                    kickBanPopup.userId = id
                    kickBanPopup.open()
                }

                onViewMemberMessagesClicked: root.viewMemberMessagesClicked(pubKey, displayName)
            }

            MembersTabPanel {
                model: root.pendingMembersModel
                rootStore: root.rootStore
                memberRole: root.memberRole
                placeholderText: {
                    if (root.pendingMembersModel.ModelCount.count === 0)
                        return qsTr("No pending requests to search")

                    return qsTr("Search %1's %n pending request(s)", "", root.pendingMembersModel.ModelCount.count).arg(root.communityName)
                }
                panelType: MembersTabPanel.TabType.PendingRequests

                Layout.fillWidth: true
                Layout.fillHeight: true

                onAcceptRequestToJoin: root.acceptRequestToJoin(id)
                onDeclineRequestToJoin: root.declineRequestToJoin(id)
            }

            MembersTabPanel {
                model: root.declinedMembersModel
                rootStore: root.rootStore
                memberRole: root.memberRole
                placeholderText: {
                    if (root.declinedMembersModel.ModelCount.count === 0)
                        return qsTr("No rejected members to search")

                    return qsTr("Search %1's %n rejected member(s)", "", root.declinedMembersModel.ModelCount.count).arg(root.communityName)
                }
                panelType: MembersTabPanel.TabType.DeclinedRequests

                Layout.fillWidth: true
                Layout.fillHeight: true

                onAcceptRequestToJoin: root.acceptRequestToJoin(id)
            }

            MembersTabPanel {
                model: root.bannedMembersModel
                rootStore: root.rootStore
                memberRole: root.memberRole
                placeholderText: {
                    if (root.bannedMembersModel.ModelCount.count === 0)
                        return qsTr("No banned members to search")

                    return qsTr("Search %1's %n banned member(s)", "", root.bannedMembersModel.ModelCount.count).arg(root.communityName)
                }
                panelType: MembersTabPanel.TabType.BannedMembers

                Layout.fillWidth: true
                Layout.fillHeight: true

                onUnbanUserClicked: root.unbanUserClicked(id)
                onViewMemberMessagesClicked: root.viewMemberMessagesClicked(pubKey, displayName)
            }
        }
    }

    KickBanPopup {
        id: kickBanPopup

        property string userId

        communityName: root.communityName

        onBanUserClicked: root.banUserClicked(userId, deleteAllMessages)
        onKickUserClicked: root.kickUserClicked(userId)
    }
}
