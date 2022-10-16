import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0

import "./notifications"

import "../stores"
import "../controls"
import "../panels"
import "../popups"

SettingsContentBase {
    id: root
    property bool hasMultipleDevices: true
    property NotificationsStore notificationsStore
    property DevicesStore devicesStore
    property var exemptionsModel

    ColumnLayout {
        id: contentColumn
        spacing: Constants.settingsSection.itemSpacing

        ButtonGroup {
            id: messageSetting
        }

        Rectangle {
            Layout.preferredWidth: root.contentWidth
            implicitHeight: col1.height + 2 * Style.current.padding
            visible: Qt.platform.os == "osx"
            radius: Constants.settingsSection.radius
            color: Theme.palette.primaryColor3

            ColumnLayout {
                id: col1
                anchors.margins: Style.current.padding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Constants.settingsSection.infoSpacing

                StatusBaseText {
                    Layout.preferredWidth: parent.width
                    text: qsTr("Enable Notifications in macOS Settings")
                    font.pixelSize: Constants.settingsSection.infoFontSize
                    lineHeight: Constants.settingsSection.infoLineHeight
                    lineHeightMode: Text.FixedHeight
                    color: Theme.palette.primaryColor1
                }

                StatusBaseText {
                    Layout.preferredWidth: parent.width
                    text: qsTr("To receive Status notifications, make sure you've enabled them in your computer's settings under <b>System Preferences > Notifications</b>")
                    font.pixelSize: Constants.settingsSection.infoFontSize
                    lineHeight: Constants.settingsSection.infoLineHeight
                    lineHeightMode: Text.FixedHeight
                    color: Theme.palette.baseColor1
                    wrapMode: Text.WordWrap
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: root.contentWidth
            implicitHeight: row1.height + 2 * Style.current.padding
            radius: Constants.settingsSection.radius
            color: Theme.palette.pinColor2

            RowLayout {
                id: row1
                anchors.margins: Style.current.padding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: hasMultipleDevices

                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("Sync your devices to share notifications preferences")
                    font.pixelSize: Constants.settingsSection.infoFontSize
                    lineHeight: Constants.settingsSection.infoLineHeight
                    lineHeightMode: Text.FixedHeight
                    color: Theme.palette.pinColor1
                }

                StatusBaseText {
                    text: qsTr("Syncing >")
                    font.pixelSize: Constants.settingsSection.infoFontSize
                    lineHeight: Constants.settingsSection.infoLineHeight
                    lineHeightMode: Text.FixedHeight
                    color: Theme.palette.pinColor1
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.devicesStore.syncAll()
                        }
                    }
                }
            }
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Allow Notifications")
            components: [
                StatusSwitch {
                    id: allowNotifSwitch
                    checked: notificationsStore.notifSettingAllowNotifications
                    onClicked: {
                        notificationsStore.setNotifSettingAllowNotifications(!notificationsStore.notifSettingAllowNotifications)
                    }
                }
 
            ]
            onClicked: {
                allowNotifSwitch.clicked()
            }
        }

        StatusBaseText {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            text: qsTr("Messages")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.baseColor1
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("1:1 Chats")
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingOneToOneChats
                    onSendAlertsClicked: notificationsStore.setNotifSettingOneToOneChats(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingOneToOneChats(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingOneToOneChats(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Group Chats")
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingGroupChats
                    onSendAlertsClicked: notificationsStore.setNotifSettingGroupChats(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingGroupChats(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingGroupChats(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Personal @ Mentions")
            tertiaryTitle: qsTr("Messages containing @%1").arg(userProfile.name)
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingPersonalMentions
                    onSendAlertsClicked: notificationsStore.setNotifSettingPersonalMentions(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingPersonalMentions(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingPersonalMentions(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Global @ Mentions")
            tertiaryTitle: qsTr("Messages containing @here and @channel")
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingGlobalMentions
                    onSendAlertsClicked: notificationsStore.setNotifSettingGlobalMentions(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingGlobalMentions(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingGlobalMentions(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("All Messages")
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingAllMessages
                    onSendAlertsClicked: notificationsStore.setNotifSettingAllMessages(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingAllMessages(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingAllMessages(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        StatusBaseText {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            text: qsTr("Others")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.baseColor1
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Contact Requests")
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingContactRequests
                    onSendAlertsClicked: notificationsStore.setNotifSettingContactRequests(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingContactRequests(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingContactRequests(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Identity Verification Requests")
            components: [
                NotificationSelect {
                    selected: notificationsStore.notifSettingIdentityVerificationRequests
                    onSendAlertsClicked: notificationsStore.setNotifSettingIdentityVerificationRequests(Constants.settingsSection.notifications.sendAlertsValue)
                    onDeliverQuietlyClicked: notificationsStore.setNotifSettingIdentityVerificationRequests(Constants.settingsSection.notifications.deliverQuietlyValue)
                    onTurnOffClicked: notificationsStore.setNotifSettingIdentityVerificationRequests(Constants.settingsSection.notifications.turnOffValue)
                }
            ]
        }

        Separator {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: Style.current.bigPadding
        }

        StatusBaseText {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            text: qsTr("Notification Content")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.directColor1
        }

        NotificationAppearancePreviewPanel {
            id: notifNameAndMsg
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            name: qsTr("Show Name and Message")
            notificationTitle: "Vitalik Buterin"
            notificationMessage: qsTr("Hi there! So EIP-1559 will defini...")
            buttonGroup: messageSetting
            checked: notificationsStore.notificationMessagePreview === Constants.settingsSection.notificationsBubble.previewNameAndMessage
            onRadioCheckedChanged: {
                if (checked) {
                    notificationsStore.setNotificationMessagePreview(Constants.settingsSection.notificationsBubble.previewNameAndMessage)
                }
            }
        }

        NotificationAppearancePreviewPanel {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            name: qsTr("Name Only")
            notificationTitle: "Vitalik Buterin"
            notificationMessage: qsTr("You have a new message")
            buttonGroup: messageSetting
            checked: notificationsStore.notificationMessagePreview === Constants.settingsSection.notificationsBubble.previewNameOnly
            onRadioCheckedChanged: {
                if (checked) {
                    notificationsStore.setNotificationMessagePreview(Constants.settingsSection.notificationsBubble.previewNameOnly)
                }
            }
        }

        NotificationAppearancePreviewPanel {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            name: qsTr("Anonymous")
            notificationTitle: "Status"
            notificationMessage: qsTr("You have a new message")
            buttonGroup: messageSetting
            checked: notificationsStore.notificationMessagePreview === Constants.settingsSection.notificationsBubble.previewAnonymous
            onRadioCheckedChanged: {
                if (checked) {
                    notificationsStore.setNotificationMessagePreview(Constants.settingsSection.notificationsBubble.previewAnonymous)
                }
            }
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Play a Sound When Receiving a Notification")
            components: [
                StatusSwitch {
                    id: soundSwitch
                    checked: notificationsStore.notificationSoundsEnabled
                    onClicked: {
                        notificationsStore.setNotificationSoundsEnabled(!notificationsStore.notificationSoundsEnabled)
                    }
                }
            ]
            onClicked: {
                soundSwitch.clicked()
            }
        }

        StatusBaseText {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            text: qsTr("Volume")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.directColor1
        }

        Item {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: Constants.settingsSection.itemHeight + Style.current.padding

            StatusSlider {
                id: volumeSlider
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: Style.current.bigPadding
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                from: 0
                to: 100
                stepSize: 1

                onValueChanged: {
                    notificationsStore.setVolume(value)
                }

                Component.onCompleted: {
                    value = notificationsStore.volume
                }
            }

            RowLayout {
                anchors.top: volumeSlider.bottom
                anchors.left: volumeSlider.left
                anchors.topMargin: Style.current.halfPadding
                width: volumeSlider.width

                StatusBaseText {
                    font.pixelSize: 15
                    text: volumeSlider.from
                    Layout.preferredWidth: volumeSlider.width/2
                    color: Theme.palette.baseColor1
                }

                StatusBaseText {
                    font.pixelSize: 15
                    text: volumeSlider.to
                    Layout.alignment: Qt.AlignRight
                    color: Theme.palette.baseColor1
                }
            }
        }

        StatusButton {
            Layout.leftMargin: Style.current.padding
            text: qsTr("Send a Test Notification")
            onClicked: {
                root.notificationsStore.sendTestNotification(notifNameAndMsg.notificationTitle,
                                                                notifNameAndMsg.notificationMessage)
            }
        }

        Separator {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: Style.current.bigPadding
        }

        ExemptionView {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 400
            contentWidth: root.contentWidth
            exemptionsModel: root.exemptionsModel
            notificationsStore: root.notificationsStore
        }

    }
}
