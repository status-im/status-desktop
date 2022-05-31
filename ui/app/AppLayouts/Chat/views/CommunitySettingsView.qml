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
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import "../panels/communities"
import "../layouts"

StatusAppTwoPanelLayout {
    id: root

    // TODO: get this model from backend?
    property var model: [{name: qsTr("Overview"), icon: "help"},
                        {name: qsTr("Members"), icon: "group-chat"},
//                        {name: qsTr("Permissions"), icon: "objects"},
//                        {name: qsTr("Tokens"), icon: "token"},
//                        {name: qsTr("Airdrops"), icon: "airdrop"},
//                        {name: qsTr("Token sales"), icon: "token-sale"},
//                        {name: qsTr("Subscriptions"), icon: "subscription"},
                        {name: qsTr("Notifications"), icon: "notification"}]

    property var rootStore
    property var community
    property var chatCommunitySectionModule

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

        ListView  {
            id: listView

            Layout.fillWidth: true
            implicitHeight: contentItem.childrenRect.height

            model: root.model
            delegate: StatusNavigationListItem {
                width: listView.width
                title: modelData.name
                icon.name: modelData.icon
                selected: d.currentIndex == index
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

    rightPanel: Loader {
        anchors.fill: parent
        anchors.margins: 16

        active: root.community

        sourceComponent: StackLayout {
            currentIndex: d.currentIndex

            CommunityOverviewSettingsPanel {
                name: root.community.name
                description: root.community.description
                image: root.community.image
                color: root.community.color
                editable: root.community.amISectionAdmin
                isCommunityHistoryArchiveSupportEnabled: root.rootStore.isCommunityHistoryArchiveSupportEnabled
                historyArchiveSupportToggle: community.historyArchiveSupportEnabled

                onEdited: {
                    root.chatCommunitySectionModule.editCommunity(
                        Utils.filterXSS(item.name),
                        Utils.filterXSS(item.description),
                        root.community.access,
                        item.color.toString().toUpperCase(),
                        item.image === root.community.image ? "" : item.image,
                        item.imageAx,
                        item.imageAy,
                        item.imageBx,
                        item.imageBy,
                        root.rootStore.isCommunityHistoryArchiveSupportEnabled,
                        false /*TODO port the modal implementation*/
                    )
                }
            }

            CommunityMembersSettingsPanel {
                membersModel: root.community.members
                editable: root.community.amISectionAdmin
                pendingRequests: root.community.pendingRequestsToJoin ? root.community.pendingRequestsToJoin.count : 0

                onUserProfileClicked: Global.openProfilePopup(id)
                onKickUserClicked: root.rootStore.removeUserFromCommunity(id)
                onBanUserClicked: root.rootStore.banUserFromCommunity(id)
                onMembershipRequestsClicked: Global.openPopup(membershipRequestPopup, {
                    communitySectionModule: root.chatCommunitySectionModule
                })
            }

            SettingsPageLayout {
                title: qsTr("Notifications")

                content: ColumnLayout {
                    StatusListItem {
                        Layout.fillWidth: true

                        title: qsTr("Enabled")
                        icon.name: "notification"
                        sensor.cursorShape: Qt.ArrowCursor
                        components: [
                            StatusSwitch {
                                checked: !root.community.muted
                                onClicked: root.chatCommunitySectionModule.setCommunityMuted(!checked)
                            }
                        ]
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }


    QtObject {
        id: d
        property int currentIndex: 0
    }
}
