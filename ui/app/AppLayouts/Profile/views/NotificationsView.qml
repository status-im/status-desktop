import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import SortFilterProxyModel 0.2

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
    property NotificationsStore notificationsStore
    property DevicesStore devicesStore

    function getColorForUser(model) {
        return (model.type === Constants.settingsSection.exemptions.oneToOneChat? Utils.colorForPubkey(model.itemId) : model.color)
    }

    function getRingForUser(model) {
        return (model.type === Constants.settingsSection.exemptions.oneToOneChat? Utils.getColorHashAsJson(model.itemId) : undefined)
    }

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
                visible: root.devicesStore.devicesModel.count > 0

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
                    checked: appSettings.notifSettingAllowNotifications
                    onClicked: {
                        appSettings.notifSettingAllowNotifications = !appSettings.notifSettingAllowNotifications
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
                    selected: appSettings.notifSettingOneToOneChats
                    onSendAlertsClicked: appSettings.notifSettingOneToOneChats = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingOneToOneChats = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingOneToOneChats = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Group Chats")
            components: [
                NotificationSelect {
                    selected: appSettings.notifSettingGroupChats
                    onSendAlertsClicked: appSettings.notifSettingGroupChats = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingGroupChats = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingGroupChats = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Personal @ Mentions")
            tertiaryTitle: qsTr("Messages containing @%1").arg(userProfile.name)
            components: [
                NotificationSelect {
                    selected: appSettings.notifSettingPersonalMentions
                    onSendAlertsClicked: appSettings.notifSettingPersonalMentions = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingPersonalMentions = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingPersonalMentions = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Global @ Mentions")
            tertiaryTitle: qsTr("Messages containing @here and @channel")
            components: [
                NotificationSelect {
                    selected: appSettings.notifSettingGlobalMentions
                    onSendAlertsClicked: appSettings.notifSettingGlobalMentions = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingGlobalMentions = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingGlobalMentions = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("All Messages")
            components: [
                NotificationSelect {
                    selected: appSettings.notifSettingAllMessages
                    onSendAlertsClicked: appSettings.notifSettingAllMessages = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingAllMessages = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingAllMessages = Constants.settingsSection.notifications.turnOffValue
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
                    selected: appSettings.notifSettingContactRequests
                    onSendAlertsClicked: appSettings.notifSettingContactRequests = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingContactRequests = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingContactRequests = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Identity Verification Requests")
            components: [
                NotificationSelect {
                    selected: appSettings.notifSettingIdentityVerificationRequests
                    onSendAlertsClicked: appSettings.notifSettingIdentityVerificationRequests = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: appSettings.notifSettingIdentityVerificationRequests = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: appSettings.notifSettingIdentityVerificationRequests = Constants.settingsSection.notifications.turnOffValue
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
            checked: appSettings.notificationMessagePreview === Constants.settingsSection.notificationsBubble.previewNameAndMessage
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.notificationMessagePreview = Constants.settingsSection.notificationsBubble.previewNameAndMessage
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
            checked: appSettings.notificationMessagePreview === Constants.settingsSection.notificationsBubble.previewNameOnly
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.notificationMessagePreview = Constants.settingsSection.notificationsBubble.previewNameOnly
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
            checked: appSettings.notificationMessagePreview === Constants.settingsSection.notificationsBubble.previewAnonymous
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.notificationMessagePreview = Constants.settingsSection.notificationsBubble.previewAnonymous
                }
            }
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Play a Sound When Receiving a Notification")
            components: [
                StatusSwitch {
                    id: soundSwitch
                    checked: appSettings.notificationSoundsEnabled
                    onClicked: {
                        appSettings.notificationSoundsEnabled = !appSettings.notificationSoundsEnabled
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
                    appSettings.volume = value
                }

                Component.onCompleted: {
                    value = appSettings.volume
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

        // note: this sanitizes the data expected by the Exemption component
        // this will be moved to a layer above later as the qml is refactored
        // it uses helpers defined as local functions due to an issue accessing imports
        SortFilterProxyModel {
            id: fixedExemptionsModel
            sourceModel: root.notificationsStore.exemptionsModel
            proxyRoles: [
                ExpressionRole {
                    name: "color"
                    expression: root.getColorForUser(model)
                },
                ExpressionRole {
                    name: "ring"
                    expression: root.getRingForUser(model)
                }
            ]
        }

        ExemptionView {
            Layout.preferredWidth: root.contentWidth
            Layout.preferredHeight: 400
            contentWidth: root.contentWidth
            exemptionsModel: fixedExemptionsModel
            notificationsStore: root.notificationsStore
        }
    }
}
