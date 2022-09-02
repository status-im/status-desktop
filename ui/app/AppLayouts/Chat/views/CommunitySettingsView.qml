import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import "../panels/communities"
import "../popups/community"
import "../layouts"

StatusSectionLayout {
    id: root

    notificationCount: root.rootStore.unreadNotificationsCount
    onNotificationButtonClicked: Global.openActivityCenterPopup()
    // TODO: get this model from backend?
    property var settingsMenuModel: root.rootStore.communityPermissionsEnabled ? [{name: qsTr("Overview"), icon: "help"},
                                                                                 {name: qsTr("Members"), icon: "group-chat"},
                                                                                 {name: qsTr("Permissions"), icon: "objects"}] :
                                                                                   [{name: qsTr("Overview"), icon: "help"},
                                                                                 {name: qsTr("Members"), icon: "group-chat"}]
    // TODO: Next community settings options:
    //                        {name: qsTr("Tokens"), icon: "token"},
    //                        {name: qsTr("Airdrops"), icon: "airdrop"},
    //                        {name: qsTr("Token sales"), icon: "token-sale"},
    //                        {name: qsTr("Subscriptions"), icon: "subscription"},

    property var rootStore    
    property var community
    property var chatCommunitySectionModule
    property bool hasAddedContacts: false
    property Component membershipRequestPopup

    readonly property string filteredSelectedTags: {
        if (!community || !community.tags)
            return "";

        const json = JSON.parse(community.tags);
        const tagsArray = json.map(tag => {
            return tag.name;
        });
        return JSON.stringify(tagsArray);
    }

    signal backToCommunityClicked
    signal openLegacyPopupClicked // TODO: remove me when migration to new settings is done

    leftPanel: ColumnLayout {
        anchors {
            fill: parent
            margins: 8
            topMargin: 16
            bottomMargin: 16
        }

        spacing: 16

        StatusNavigationPanelHeadline {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Settings")
        }

        StatusListView {
            id: listView

            Layout.fillWidth: true
            implicitHeight: contentItem.childrenRect.height

            model: root.settingsMenuModel
            delegate: StatusNavigationListItem {
                width: listView.width
                title: modelData.name
                icon.name: modelData.icon
                selected: d.currentIndex === index
                onClicked: d.currentIndex = index
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // TODO: remove me when migration to new settings is done
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Open legacy popup (to be removed)")
            color: Theme.palette.baseColor1
            font.pixelSize: 10
            font.underline: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openLegacyPopupClicked()
            }
        }

        StatusBaseText {
            objectName: "communitySettingsBackToCommunityButton"
            Layout.alignment: Qt.AlignHCenter
            text: "<- " + qsTr("Back to community")
            color: Theme.palette.baseColor1
            font.pixelSize: 15
            font.underline: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backToCommunityClicked()
                hoverEnabled: true
            }
        }
    }

    centerPanel: Loader {
        anchors.fill: parent
        //anchors.margins: 32
        anchors {
            leftMargin: 28
            rightMargin: 16
            bottomMargin: 16
        }
        active: root.community
        sourceComponent: StackLayout {
            currentIndex: d.currentIndex

            CommunityOverviewSettingsPanel {
                communityId: root.community.id
                name: root.community.name
                description: root.community.description
                introMessage: root.community.introMessage
                outroMessage: root.community.outroMessage
                logoImageData: root.community.image
                bannerImageData: root.community.bannerImageData
                color: root.community.color
                tags: root.rootStore.communityTags
                selectedTags: root.filteredSelectedTags
                archiveSupportEnabled: root.community.historyArchiveSupportEnabled
                requestToJoinEnabled: root.community.access === Constants.communityChatOnRequestAccess
                pinMessagesEnabled: root.community.pinMessageAllMembersEnabled

                archiveSupportOptionVisible: root.rootStore.isCommunityHistoryArchiveSupportEnabled
                editable: root.community.amISectionAdmin

                onEdited: {
                    const error = root.chatCommunitySectionModule.editCommunity(
                        StatusQUtils.Utils.filterXSS(item.name),
                        StatusQUtils.Utils.filterXSS(item.description),
                        StatusQUtils.Utils.filterXSS(item.introMessage),
                        StatusQUtils.Utils.filterXSS(item.outroMessage),
                        item.options.requestToJoinEnabled ? Constants.communityChatOnRequestAccess : Constants.communityChatPublicAccess,
                        item.color.toString().toUpperCase(),
                        item.selectedTags,
                        Utils.getImageAndCropInfoJson(item.logoImagePath, item.logoCropRect),
                        Utils.getImageAndCropInfoJson(item.bannerPath, item.bannerCropRect),
                        item.options.archiveSupportEnabled,
                        item.options.pinMessagesEnabled
                    )
                    if (error) {
                        errorDialog.text = error.error
                        errorDialog.open()
                    }
                }

                onInviteNewPeopleClicked: {
                    Global.openPopup(inviteFriendsToCommunityPopup, {
                                         community: root.community,
                                         hasAddedContacts: root.hasAddedContacts
                                     })
                }

                onAirdropTokensClicked: { /* TODO in future */ }
                onBackUpClicked: {
                    Global.openPopup(transferOwnershipPopup, {
                        privateKey: root.chatCommunitySectionModule.exportCommunity(root.communityId),
                    })
                }
            }

            CommunityMembersSettingsPanel {
                membersModel: root.community.members
                bannedMembersModel: root.community.bannedMembers
                pendingMemberRequestsModel: root.community.pendingMemberRequests
                declinedMemberRequestsModel: root.community.declinedMemberRequests
                editable: root.community.amISectionAdmin
                communityName: root.community.name

                onUserProfileClicked: Global.openProfilePopup(id)
                onKickUserClicked: root.rootStore.removeUserFromCommunity(id)
                onBanUserClicked: root.rootStore.banUserFromCommunity(id)
                onUnbanUserClicked: root.rootStore.unbanUserFromCommunity(id)
                onAcceptRequestToJoin: root.rootStore.acceptRequestToJoinCommunity(id)
                onDeclineRequestToJoin: root.rootStore.declineRequestToJoinCommunity(id)
            }

            CommunityPermissionsSettingsPanel {}
        }
    }

    onSettingsMenuModelChanged: d.currentIndex = 0

    QtObject {
        id: d
        property int currentIndex: 0
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Error editing the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    Component {
        id: transferOwnershipPopup
        TransferOwnershipPopup {
            anchors.centerIn: parent
            store: root.rootStore
        }
    }

    Component {
        id: inviteFriendsToCommunityPopup
        InviteFriendsToCommunityPopup {
            anchors.centerIn: parent
            rootStore: root.rootStore
            contactsStore: root.rootStore.contactsStore
            onClosed: () => {
                destroy();
            }

            onSendInvites: (pubKeys, inviteMessage) => {
                const error = root.communitySectionModule.inviteUsersToCommunity(JSON.stringify(pubKeys), inviteMessage);
                processInviteResult(error);
            }
        }
    }
}
