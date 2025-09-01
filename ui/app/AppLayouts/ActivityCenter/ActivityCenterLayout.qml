import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQml.Models

import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Backpressure
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Layout

import shared
import shared.popups
import shared.views.chat

import utils

import AppLayouts.Chat.stores as ChatStores
import AppLayouts.Profile.stores
import AppLayouts.stores.Messaging as MessagingStores
import AppLayouts.stores.Messaging.Community as CommunityStores
import AppLayouts.stores as AppStores

import "views"
import "panels"
import "stores"

StatusSectionLayout {
    id: root

    property AppStores.ContactsStore contactsStore
    property ActivityCenterStore activityCenterStore
    property ChatStores.RootStore store
    property PrivacyStore privacyStore
    property NotificationsStore notificationsStore
    property MessagingStores.MessagingRootStore messagingRootStore

    QtObject {
        id: d

        readonly property var loadMoreNotificationsIfScrollBelowThreshold: Backpressure.oneInTimeQueued(root, 100, function() {
            if (listView.contentY >= listView.contentHeight - listView.height - 1) {
                root.activityCenterStore.fetchActivityCenterNotifications()
            }
        })

        readonly property bool isStatusNewsViaRSSEnabled: root.privacyStore.isStatusNewsViaRSSEnabled
        readonly property var notificationsSettings: root.notificationsStore.notificationsSettings

        // TODO: Review if it's really necessary to do this call later call or instead directly mark the notification as seen
        // Now temporarily kept as it was done when closing the previous popup
        function callLaterMarkAsSeen() {
            Qt.callLater(activityCenterStore.markAsSeenActivityCenterNotifications)
        }
    }

    leftPanel: ColumnLayout {

        objectName: "activityCenterLeftPanel"

        id: leftPanel
        anchors.fill: parent
        spacing: 0

        // TODO: Create Header Component
        RowLayout {
            id: row

            Layout.fillWidth: true
            Layout.leftMargin: Theme.bigPadding
            Layout.topMargin: Theme.padding

            StatusNavigationPanelHeadline {
                text: qsTr("Notifications")
            }

            // Filler
            Item {
                Layout.fillWidth: true
            }

            StatusBetaTag {
                tooltipText: qsTr("Under construction.<br>More notification types to be coming soon.")
                tooltipOrientation: StatusToolTip.Orientation.Bottom
            }

            StatusFlatRoundButton {
                id: markAllReadBtn
                objectName: "markAllReadButton"
                enabled: activityCenterStore.unreadNotificationsCount > 0
                icon.name: "double-checkmark"
                onClicked: activityCenterStore.markAllActivityCenterNotificationsRead()

                StatusToolTip {
                    visible: markAllReadBtn.hovered
                    text: qsTr("Mark all as Read")
                    orientation: StatusToolTip.Orientation.Bottom
                }
            }

            StatusFlatRoundButton {
                id: hideReadNotificationsBtn

                property bool hideReadNotifications: activityCenterStore.activityCenterReadType === ActivityCenterStore.ActivityCenterReadType.Unread

                objectName: "hideReadNotificationsButton"
                icon.name: hideReadNotifications ? "hide" : "show"
                onClicked: activityCenterStore.setActivityCenterReadType(!hideReadNotifications ?
                                                                             ActivityCenterStore.ActivityCenterReadType.Unread :
                                                                             ActivityCenterStore.ActivityCenterReadType.All)

                StatusToolTip {
                    visible: hideReadNotificationsBtn.hovered
                    text: hideReadNotificationsBtn.hideReadNotifications ? qsTr("Show read notifications") : qsTr("Hide read notifications")
                    orientation: StatusToolTip.Orientation.Bottom
                }
            }
        }

        ActivityCenterPopupTopBarPanel {
            id: activityCenterTopBar

            Layout.fillWidth: true
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
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.smallPadding
            spacing: 1

            model: root.activityCenterStore.activityCenterNotifications

            onContentYChanged: d.loadMoreNotificationsIfScrollBelowThreshold()

            delegate: Loader {
                width: listView.availableWidth

                property int filteredIndex: index
                property var notification: model

                sourceComponent: {
                    switch (model.notificationType) {
                    case ActivityCenterTypes.ActivityCenterNotificationType.Mention:
                        return mentionNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.Reply:
                        return replyNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.ContactRequest:
                        return contactRequestNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityInvitation:
                        return communityInvitationNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityMembershipRequest:
                        return membershipRequestNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityRequest:
                        return communityRequestNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityKicked:
                        return communityKickedNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.ContactRemoved:
                        return contactRemovedComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.NewKeypairAddedToPairedDevice:
                        return newKeypairFromPairedDeviceComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityTokenReceived:
                    case ActivityCenterTypes.ActivityCenterNotificationType.FirstCommunityTokenReceived:
                        return communityTokenReceivedComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.OwnerTokenReceived:
                    case ActivityCenterTypes.ActivityCenterNotificationType.OwnershipReceived:
                    case ActivityCenterTypes.ActivityCenterNotificationType.OwnershipLost:
                    case ActivityCenterTypes.ActivityCenterNotificationType.OwnershipFailed:
                    case ActivityCenterTypes.ActivityCenterNotificationType.OwnershipDeclined:
                        return ownerTokenReceivedNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.ShareAccounts:
                        return shareAccountsNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityBanned:
                        return communityBannedNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.CommunityUnbanned:
                        return communityUnbannedNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.NewPrivateGroupChat:
                        return groupChatInvitationNotificationComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.NewInstallationReceived:
                    case ActivityCenterTypes.ActivityCenterNotificationType.NewInstallationCreated:
                        return newDeviceDetectedComponent
                    case ActivityCenterTypes.ActivityCenterNotificationType.ActivityCenterNotificationTypeNews:
                        return newsMessageComponent
                    default:
                        return null
                    }
                }
            }
        }
    }

    centerPanel: null // TODO: It will be updated with new designs

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
            contactsModel: root.contactsStore.contactsModel
            community: notification ? root.store.getCommunityDetailsAsJson(notification.message.communityId) : null
            channel: notification ? root.store.getChatDetails(notification.chatId) : null

            onSetActiveCommunity: (communityId) => {
                                      root.store.setActiveCommunity(communityId) }
            onSwitchToRequested: (sectionId, chatId, messageId) => {
                                     root.activityCenterStore.switchTo(sectionId, chatId, messageId) }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }
    Component {
        id: replyNotificationComponent

        ActivityNotificationReply {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            contactsModel: root.contactsStore.contactsModel

            onSwitchToRequested: (sectionId, chatId, messageId) => {
                                     root.activityCenterStore.switchTo(sectionId, chatId, messageId) }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }
    Component {
        id: contactRequestNotificationComponent

        ActivityNotificationContactRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            contactsModel: root.contactsStore.contactsModel

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }
    Component {
        id: communityInvitationNotificationComponent

        ActivityNotificationCommunityInvitation {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            contactsModel: root.contactsStore.contactsModel

            onSwitchToRequested: (sectionId, chatId, messageId) => {
                               root.activityCenterStore.switchTo(sectionId, chatId, messageId) }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                         root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                           root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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
            contactsModel: root.contactsStore.contactsModel

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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
            community: notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            onSetActiveCommunity: (communityId) => { root.store.setActiveCommunity(communityId) }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }
    Component {
        id: communityKickedNotificationComponent

        ActivityNotificationCommunityKicked {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            community: notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            onSetActiveCommunity: (communityId) => { root.store.setActiveCommunity(communityId) }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }

    Component {
        id: communityBannedNotificationComponent

        ActivityNotificationCommunityBanUnban {
            banned: true
            filteredIndex: parent.filteredIndex
            notification: parent.notification

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }

    Component {
        id: communityUnbannedNotificationComponent

        ActivityNotificationCommunityBanUnban {
            banned: false
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            community: notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            onSetActiveCommunity: (communityId) => { root.store.setActiveCommunity(communityId) }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }

    Component {
        id: contactRemovedComponent

        ActivityNotificationContactRemoved {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            contactsModel: root.contactsStore.contactsModel

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }

    Component {
        id: newKeypairFromPairedDeviceComponent

        ActivityNotificationNewKeypairFromPairedDevice {
            filteredIndex: parent.filteredIndex
            notification: parent.notification

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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

            onReadMoreClicked: {
                d.callLaterMarkAsSeen()
                root.activityCenterStore.markActivityCenterNotificationRead(parent.notification.id)
                Global.openNewsMessagePopupRequested(parent.notification, parent.notification.id)
                // TODO figure out if we want the link
                Global.addCentralizedMetricIfEnabled("news-info-opened", {"news-link": parent.notification.link})

            }
            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
        }
    }

    Component {
        id: communityTokenReceivedComponent

        ActivityNotificationCommunityTokenReceived {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            communityId: notification.communityId
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""

            filteredIndex: parent.filteredIndex
            notification: parent.notification

            walletAccountName: !!root.store && !isFirstTokenReceived ? root.store.walletStore.getNameForWalletAddress(tokenData.walletAddress) : ""

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()

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
            contactsModel: root.contactsStore.contactsModel

            onAcceptActivityCenterNotificationRequested: (notificationId) => {
                                                             root.activityCenterStore.acceptActivityCenterNotification(notificationId) }
            onDismissActivityCenterNotificationRequested: (notificationId) => {
                                                              root.activityCenterStore.dismissActivityCenterNotification(notificationId) }

            onMarkActivityCenterNotificationReadRequested: (notificationId) => {
                                                               root.activityCenterStore.markActivityCenterNotificationRead(notificationId) }
            onMarkActivityCenterNotificationUnreadRequested: (notificationId) => {
                                                                 root.activityCenterStore.markActivityCenterNotificationUnread(notificationId) }
            onCloseActivityCenter: d.callLaterMarkAsSeen()
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
