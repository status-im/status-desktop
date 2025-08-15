import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQml.Models

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Backpressure
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog
import StatusQ.Core.Utils as StatusQUtils

import shared
import shared.popups
import shared.views.chat

import utils

import AppLayouts.Chat.stores as ChatStores
import AppLayouts.Profile.stores
import AppLayouts.stores.Messaging as MessagingStores
import AppLayouts.stores.Messaging.Community as CommunityStores

import "../views"
import "../panels"
import "../stores"

Popup {
    id: root

    property ActivityCenterStore activityCenterStore
    property ChatStores.RootStore store
    property PrivacyStore privacyStore
    property NotificationsStore notificationsStore
    property MessagingStores.MessagingRootStore messagingRootStore

    onOpened: {
        Global.activityPopupOpened = true
    }
    onClosed: {
        Global.activityPopupOpened = false
        Qt.callLater(activityCenterStore.markAsSeenActivityCenterNotifications)
    }

    implicitWidth: 560
    padding: 0
    modal: true
    parent: Overlay.overlay

    QtObject {
        id: d

        readonly property var loadMoreNotificationsIfScrollBelowThreshold: Backpressure.oneInTimeQueued(root, 100, function() {
            if (listView.contentY >= listView.contentHeight - listView.height - 1) {
                root.activityCenterStore.fetchActivityCenterNotifications()
            }
        })

        readonly property bool isStatusNewsViaRSSEnabled: root.privacyStore.isStatusNewsViaRSSEnabled
        readonly property var notificationsSettings: root.notificationsStore.notificationsSettings
    }

    Overlay.modal: StatusMouseArea { // eat every event behind the popup
        hoverEnabled: true
        onPressed: (event) => {
                       event.accept()
                       root.close()
                   }
        onWheel: (event) => event.accepted = true
    }

    background: Rectangle {
        color: Theme.palette.background
        radius: Theme.radius
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: Theme.radius
            samples: 15
            fast: true
            cached: true
            color: Theme.palette.dropShadow
        }
    }

    ActivityCenterPopupTopBarPanel {
        id: activityCenterTopBar
        width: parent.width
        unreadNotificationsCount: activityCenterStore.unreadNotificationsCount
        hasAdmin: activityCenterStore.adminCount > 0
        hasReplies: activityCenterStore.repliesCount > 0
        hasMentions: activityCenterStore.mentionsCount > 0
        hasContactRequests: activityCenterStore.contactRequestsCount > 0
        hasMembership: activityCenterStore.membershipCount > 0
        hideReadNotifications: activityCenterStore.activityCenterReadType === ActivityCenterStore.ActivityCenterReadType.Unread
        activeGroup: activityCenterStore.activeNotificationGroup
        onGroupTriggered: activityCenterStore.setActiveNotificationGroup(group)
        onMarkAllReadClicked: activityCenterStore.markAllActivityCenterNotificationsRead()
        onShowHideReadNotifications: activityCenterStore.setActivityCenterReadType(hideReadNotifications ?
                                                                                       ActivityCenterStore.ActivityCenterReadType.Unread :
                                                                                       ActivityCenterStore.ActivityCenterReadType.All)
    }

    StatusListView {
        id: listView

        visible: !statusNewsNotificationDisabledLoader.active
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: activityCenterTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: Theme.smallPadding
        spacing: 1

        model: root.activityCenterStore.activityCenterNotifications

        onContentYChanged: d.loadMoreNotificationsIfScrollBelowThreshold()

        delegate: Loader {
            width: listView.availableWidth

            property int filteredIndex: index
            property var notification: model

            sourceComponent: {
                switch (model.notificationType) {
                case ActivityCenterStore.ActivityCenterNotificationType.Mention:
                    return mentionNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.Reply:
                    return replyNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ContactRequest:
                    return contactRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityInvitation:
                    return communityInvitationNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityMembershipRequest:
                    return membershipRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityRequest:
                    return communityRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityKicked:
                    return communityKickedNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ContactRemoved:
                    return contactRemovedComponent
                case ActivityCenterStore.ActivityCenterNotificationType.NewKeypairAddedToPairedDevice:
                    return newKeypairFromPairedDeviceComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityTokenReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.FirstCommunityTokenReceived:
                    return communityTokenReceivedComponent
                case ActivityCenterStore.ActivityCenterNotificationType.OwnerTokenReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipLost:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipFailed:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipDeclined:
                    return ownerTokenReceivedNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ShareAccounts:
                    return shareAccountsNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityBanned:
                    return communityBannedNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityUnbanned:
                    return communityUnbannedNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.NewPrivateGroupChat:
                    return groupChatInvitationNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.NewInstallationReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.NewInstallationCreated:
                    return newDeviceDetectedComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ActivityCenterNotificationTypeNews:
                    return newsMessageComponent
                default:
                    return null
                }
            }
        }
    }

    // Placeholder for the status news when their settings are disbled
    Loader {
        id: statusNewsNotificationDisabledLoader
        active: activityCenterTopBar.activeGroup === ActivityCenterStore.ActivityCenterGroup.NewsMessage &&
                 (!d.isStatusNewsViaRSSEnabled || d.notificationsSettings.notifSettingStatusNews === Constants.settingsSection.notifications.turnOffValue)
        anchors.centerIn: parent
        sourceComponent: newsDisabledPanel
    }

    // Placeholder for the status news when they are all seen or there are no notifications
    Loader {
        id: statusNewsNotificationEmptyState
        active: activityCenterTopBar.activeGroup === ActivityCenterStore.ActivityCenterGroup.NewsMessage &&
                 !statusNewsNotificationDisabledLoader.active &&
                 listView.count === 0
        anchors.centerIn: parent
        sourceComponent: newsEmptyPanel
    }

    Component {
        id: mentionNotificationComponent

        ActivityNotificationMention {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: replyNotificationComponent

        ActivityNotificationReply {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: contactRequestNotificationComponent

        ActivityNotificationContactRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityInvitationNotificationComponent

        ActivityNotificationCommunityInvitation {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: membershipRequestNotificationComponent

        ActivityNotificationCommunityMembershipRequest {

            property CommunityStores.CommunityRootStore communityRootStore:  root.messagingRootStore.createCommunityRootStore(this, notification.communityId)
            readonly property CommunityStores.CommunityAccessStore communityAccessStore: communityRootStore ?
                                                                                             communityRootStore.communityAccessStore : null
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
            onAcceptRequestToJoinCommunityRequested: (requestId, communityId) => {
                if(communityAccessStore) {
                    communityAccessStore.acceptRequestToJoinCommunityRequested(requestId, communityId)
                }
            }
            onDeclineRequestToJoinCommunityRequested: (requestId, communityId) => {
                if(communityAccessStore) {
                    communityAccessStore.declineRequestToJoinCommunityRequested(requestId, communityId)
                }
            }
        }
    }
    Component {
        id: communityRequestNotificationComponent

        ActivityNotificationCommunityRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityKickedNotificationComponent

        ActivityNotificationCommunityKicked {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: communityBannedNotificationComponent

        ActivityNotificationCommunityBanUnban {
            banned: true
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: communityUnbannedNotificationComponent

        ActivityNotificationCommunityBanUnban {
            banned: false
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: contactRemovedComponent

        ActivityNotificationContactRemoved {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: newKeypairFromPairedDeviceComponent

        ActivityNotificationNewKeypairFromPairedDevice {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: ownerTokenReceivedNotificationComponent

        ActivityNotificationTransferOwnership {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            type: setType(notification)

            communityName: community ? community.name : ""
            communityColor: community ? community.color : Theme.palette.directColor1

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()

            onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(notification.communityId)
            onNavigateToCommunityClicked: root.store.setActiveCommunity(notification.communityId)
        }
    }

    Component {
        id: newDeviceDetectedComponent

        ActivityNotificationNewDevice {
            type: setType(notification)

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            accountName: store.name
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
            onMoreDetailsClicked: {
                switch (type) {
                    case ActivityNotificationNewDevice.InstallationType.Received:
                        Global.openPopup(pairDeviceDialog, {
                            name: store.name,
                            deviceId: notification.installationId
                        });
                        break;
                    case ActivityNotificationNewDevice.InstallationType.Created:
                        Global.openPopup(checkOtherDeviceDialog, {
                            deviceId: notification.installationId
                        });
                        break;
                }
            }
        }
    }

    Component {
        id: newsMessageComponent
        ActivityNotificationNewsMessage {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onReadMoreClicked: {
                root.close()
                root.activityCenterStore.markActivityCenterNotificationRead(parent.notification)
                Global.openNewsMessagePopupRequested(parent.notification, parent.notification.id)
                // TODO figure out if we want the link
                Global.addCentralizedMetricIfEnabled("news-info-opened", {"news-link": parent.notification.link})

            }
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: communityTokenReceivedComponent

        ActivityNotificationCommunityTokenReceived {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            communityId: notification.communityId
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""

            store: root.store

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: shareAccountsNotificationComponent

        ActivityNotificationCommunityShareAddresses {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            communityName: community ? community.name : ""
            communityColor: community ? community.color : "transparent"
            communityImage: community ? community.image : ""

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()

            onOpenShareAccountsClicked: {
                Global.communityShareAddressesPopupRequested(notification.communityId, communityName, communityImage)
            }
        }
    }

    Component {
        id: groupChatInvitationNotificationComponent

        ActivityNotificationUnknownGroupChatInvitation {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    function truncateDeviceId(deviceId) {
        return deviceId.substring(0, 7).toUpperCase()
    }

    Component {
        id: pairDeviceDialog

        StatusDialog {
            property string name
            property string deviceId

            width: 480
            closePolicy: Popup.CloseOnPressOutside
            destroyOnClose: true

            title: qsTr("Pair new device and sync profile")

            contentItem: ColumnLayout {
                spacing: 16
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("New device with %1 profile has been detected. You can see the device ID below and on your other device. Only confirm the request if the device ID matches.")
                        .arg(name)
                    wrapMode: Text.WordWrap
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Theme.fontSize27
                    font.weight: Font.Medium
                    font.letterSpacing: 5
                    text: truncateDeviceId(deviceId)
                }
            }

            footer: StatusDialogFooter {
                leftButtons: ObjectModel {
                   StatusFlatButton {
                        text: qsTr("Cancel")
                        onClicked: {
                            close()
                        }
                    }
                }
                rightButtons: ObjectModel {
                    StatusButton {
                        text: qsTr("Pair and Sync")
                        onClicked: {
                            activityCenterStore.enableInstallationAndSync(deviceId)
                            close()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: checkOtherDeviceDialog

        StatusDialog {
            property string deviceId

            width: 480
            closePolicy: Popup.CloseOnPressOutside
            destroyOnClose: true

            title: qsTr("Pair this device and sync profile")

            contentItem: ColumnLayout {
                spacing: 16
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("Check your other device for a pairing request. Ensure that the this device ID displayed on your other device. Only proceed with pairing and syncing if the IDs are identical.")
                    wrapMode: Text.WordWrap
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Theme.fontSize27
                    font.weight: Font.Medium
                    font.letterSpacing: 5
                    text: truncateDeviceId(deviceId)
                }
                Item {
                    Layout.fillWidth: true
                }
            }
            footer: null
        }
    }

    Component {
        id: newsMessagePopup

        NewsMessagePopup {
            onLinkClicked: Global.openLinkWithConfirmation(link, StatusQUtils.StringUtils.extractDomainFromLink(link));
        }
    }

    Component {
        id: newsDisabledPanel
        
        ColumnLayout {
            id: newsPanelLayout

            // Property used to setup the panel layout:
            // If true it means the panel is for enabling RSS notification
            // If false, it means it is for enabling status news notifications
            readonly property bool isEnableRSSNotificationPanelType: !d.isStatusNewsViaRSSEnabled

            anchors.centerIn: parent
            width: 320
            spacing: 12

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width

                text: newsPanelLayout.isEnableRSSNotificationPanelType ? qsTr("Enable RSS to receive Status News notifications") :
                                                                         qsTr("Enable Status News notifications")
                font.weight: Font.Bold
                lineHeight: 1.2
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width

                font.pixelSize: Theme.additionalTextSize
                color: Theme.palette.baseColor1
                text: newsPanelLayout.isEnableRSSNotificationPanelType ? qsTr("RSS is currently disabled via your Privacy & Security settings. Enable RSS to receive Status News notifications about upcoming features and important announcements.") :
                                                                         qsTr("This feature is currently turned off. Enable Status News notifications to receive notifications about upcoming features and important announcements")
                lineHeight: 1.2
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter

                text: newsPanelLayout.isEnableRSSNotificationPanelType ? qsTr("Enable RSS"):
                                                                         qsTr("Enable Status News notifications")
                font.pixelSize: Theme.additionalTextSize

                onClicked: {
                    if (isEnableRSSNotificationPanelType) {
                        root.privacyStore.setNewsRSSEnabled(true)
                    } else {
                        d.notificationsSettings.notifSettingStatusNews = Constants.settingsSection.notifications.sendAlertsValue
                    }
                }
            }
        }
    }

    Component {
        id: newsEmptyPanel

        Item {
            anchors.fill: parent

            StatusBaseText {
                anchors.centerIn: parent

                // If the mode is unread only, it means the user has seen all notifications
                // If the mode is all, it means the user doesn't have any notifications
                text: activityCenterStore.activityCenterReadType === ActivityCenterStore.ActivityCenterReadType.Unread ?
                    qsTr("You're all caught up") :
                    qsTr("Your notifications will appear here")
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.baseColor1
            }
        }
    }
}
