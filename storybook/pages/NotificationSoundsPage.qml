import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import "./ExemptionsComponent"

import utils 1.0

SplitView {
    Logs { id: logs }

    property var exemptionsData: ExemptionsComponentData {}

    property var model: QtObject {
        property bool notifSettingAllowNotifications: false
        property string notifSettingOneToOneChats: "Send Alerts"
        property string notifSettingGroupChats: "TurnOff"
        property string notifSettingPersonalMentions: "Deliver Quietly"
        property string notifSettingGlobalMentions: ""
        property string notifSettingAllMessages: ""
        property string notifSettingContactRequests: ""
        property string notifSettingIdentityVerificationRequests: ""
        property int notificationMessagePreview: 0
        property bool notificationSoundsEnabled: true
        property int volume: 50
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        NotificationsView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            hasMultipleDevices: true

            exemptionsModel: exemptionsData

            notificationsStore: NotificationsStore {
                exemptionsModel: exemptionsData

                property bool notifSettingAllowNotifications: model.notifSettingAllowNotifications
                function setNotifSettingAllowNotifications(value) {
                    model.notifSettingAllowNotifications = value
                    logs.logEvent("notificationsStore::setNotifySettingsAllowNotifications", ["value"], arguments)
                }
                property string notifSettingOneToOneChats: model.notifSettingOneToOneChats
                function setNotifSettingOneToOneChats(value) {
                    model.notifSettingOneToOneChats = value
                    logs.logEvent("notificationsStore::setNotifSettingOneToOneChats", ["value"], arguments)
                }
                property string notifSettingGroupChats: model.notifSettingGroupChats
                function setNotifSettingGroupChats(value) {
                    model.notifSettingGroupChats = value
                    logs.logEvent("notificationsStore::setNotifSettingGroupChats", ["value"], arguments)
                }
                property string notifSettingPersonalMentions: model.notifSettingPersonalMentions
                function setNotifSettingPersonalMentions(value) {
                    model.notifSettingPersonalMentions = value
                    logs.logEvent("notificationsStore::setNotifSettingPersonalMentions", ["value"], arguments)
                }
                property string notifSettingGlobalMentions: model.notifSettingGlobalMentions
                function setNotifSettingGlobalMentions(value) {
                    model.notifSettingGlobalMentions = value
                    logs.logEvent("notificationsStore::setNotifSettingGlobalMentions", ["value"], arguments)
                }
                property string notifSettingAllMessages: model.notifSettingAllMessages
                function setNotifSettingAllMessages(value) {
                    model.notifSettingAllMessages = value
                    logs.logEvent("notificationsStore::setNotifSettingAllMessages", ["value"], arguments)
                }
                property string notifSettingContactRequests: model.notifSettingContactRequests
                function setNotifSettingContactRequests(value) {
                    model.notifSettingContactRequests = value
                    logs.logEvent("notificationsStore::setNotifSettingContactRequests", ["value"], arguments)
                }
                property string notifSettingIdentityVerificationRequests: model.notifSettingIdentityVerificationRequests
                function setNotifSettingIdentityVerificationRequests(value) {
                    model.notifSettingIdentityVerificationRequests = value
                    logs.logEvent("notificationsStore::setNotifSettingIdentityVerificationRequests", ["value"], arguments)
                }
                property int notificationMessagePreview: model.notificationMessagePreview
                function setNotificationMessagePreview(value) {
                    model.notificationMessagePreview = value
                    logs.logEvent("notificationsStore::setNotificationMessagePreview", ["value"], arguments)
                }
                property bool notificationSoundsEnabled: model.notificationSoundsEnabled
                function setNotificationSoundsEnabled(value) {
                    model.notificationSoundsEnabled = value
                    logs.logEvent("notificationsStore::setNotificationSoundsEnabled", ["value"], arguments)
                }
                property int volume: model.volume
                function setVolume(value) {
                    model.volume = value
                    logs.logEvent("notificationsStore::setVolume", ["value"], arguments)
                }

                function sendTestNotification(title, message) {
                    logs.logEvent("notificationsStore::sendTestNotification", ["title, message"], arguments)
                }

                function saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages) {
                    logs.logEvent("notificationsModule::sendTestNotification", ["itemId", "muteAllMessages", "personalMentions", "globalMentions", "allMessages"], arguments)
                }
            }

            devicesStore: DevicesStore {
                function syncAll() {
                    logs.logEvent("devicesStore::syncAll")
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        ColumnLayout {
            anchors.fill: parent
            width: parent.width
            spacing: 2

            ListView {
                width: parent.width
                Label {
                    text: "notifSettingOneToOneChats"
                    font.weight: Font.Bold
                }

                TextField {
                    Layout.fillWidth: true
                    text: model.notifSettingOneToOneChats
                    onTextChanged: model.notifSettingOneToOneChats = text
                }
            }

            ExemptionsComponentControls {
                model: exemptionsData
            }

        }

    }
}
