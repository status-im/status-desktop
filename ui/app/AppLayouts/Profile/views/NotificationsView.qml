import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.panels 1.0

import "../popups"
import "../panels"
import "./"

ScrollView {
    id: root
    height: parent.height
    width: parent.width
    contentHeight: notificationsContainer.height
    clip: true

    property var store

    Item {
        id: notificationsContainer
        width: profileContainer.profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        height: this.childrenRect.height + 100

        property Component mutedChatsModalComponent: MutedChatsModal {}


        ButtonGroup {
            id: notificationSetting
        }

        ButtonGroup {
            id: soundSetting
        }

        ButtonGroup {
            id: messageSetting
        }

        StatusSectionHeadline {
            id: sectionHeadlineNotifications
            //% "Notification preferences"
            text: qsTrId("notifications-preferences")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Column {
            id: column
            anchors.top: sectionHeadlineNotifications.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right

            RadioButtonSelector {
                //% "All messages"
                title: qsTrId("all-messages")
                buttonGroup: notificationSetting
                checked: localAccountSensitiveSettings.notificationSetting === Constants.notifyAllMessages
                onCheckedChanged: {
                    if (checked) {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyAllMessages
                    }
                }
            }

            RadioButtonSelector {
                //% "Just @mentions"
                title: qsTrId("just--mentions")
                buttonGroup: notificationSetting
                checked:  localAccountSensitiveSettings.notificationSetting === Constants.notifyJustMentions
                onCheckedChanged: {
                    if (checked) {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyJustMentions
                    }
                }
            }

            RadioButtonSelector {
                //% "Nothing"
                title: qsTrId("nothing")
                buttonGroup: notificationSetting
                checked:  localAccountSensitiveSettings.notificationSetting === Constants.notifyNone
                onCheckedChanged: {
                    if (checked) {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyNone
                    }
                }
            }
        }

        Separator {
            id: separator
            anchors.top: column.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        StatusSectionHeadline {
            id: sectionHeadlineSound
            //% "Appearance"
            text: qsTrId("appearance")
            anchors.top: separator.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Column {
            id: column2
            anchors.top: sectionHeadlineSound.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
                //% "Play a sound when receiving a notification"
                title: qsTrId("play-a-sound-when-receiving-a-notification")

                onClicked: notifSoundsEnabledSwitch.checked = !notifSoundsEnabledSwitch.checked
                components: [
                    StatusSwitch {
                        id: notifSoundsEnabledSwitch
                        checked: localAccountSensitiveSettings.notificationSoundsEnabled
                        onClicked: {
                            localAccountSensitiveSettings.notificationSoundsEnabled = checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
                //% "Use your operating system's notifications"
                title: qsTrId("use-your-operating-system-s-notifications")

                onClicked: osNotifsSwitch.checked = !osNotifsSwitch.checked
                components: [
                    StatusSwitch {
                        id: osNotifsSwitch
                        checked: localAccountSensitiveSettings.useOSNotifications
                        onClicked: {
                            localAccountSensitiveSettings.useOSNotifications = checked
                        }
                    }
                ]
            }
            StatusBaseText {
                id: detailText
                //% "Setting this to false will instead use Status' notification style as seen below"
                text: qsTrId("setting-this-to-false-will-instead-use-status--notification-style-as-seen-below")
                color: Theme.palette.baseColor1
                width: parent.width
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                anchors.left: parent.left
            }
        }

        Column {
            id: column3
            spacing: Style.current.bigPadding
            anchors.top: column2.bottom
            anchors.topMargin: Style.current.padding*2
            anchors.left: parent.left
            anchors.right: parent.right

            StatusBaseText {
                //% "Message preview"
                text: qsTrId("message-preview")
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.right: parent.right
                color: Theme.palette.directColor1
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                spacing: 10

                NotificationAppearancePreviewPanel {
                    //% "Anonymous"
                    name: qsTrId("anonymous")
                    notificationTitle: "Status"
                    //% "You have a new message"
                    notificationMessage: qsTrId("you-have-a-new-message")
                    buttonGroup: messageSetting
                    checked: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous
                    onRadioCheckedChanged: {
                        if (checked) {
                            localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewAnonymous
                        }
                    }
                }

                NotificationAppearancePreviewPanel {
                    //% "Name only"
                    name: qsTrId("name-only")
                    notificationTitle: "Vitalik Buterin"
                    //% "You have a new message"
                    notificationMessage: qsTrId("you-have-a-new-message")
                    buttonGroup: messageSetting
                    checked: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewNameOnly
                    onRadioCheckedChanged: {
                        if (checked) {
                            localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameOnly
                        }
                    }
                }

                NotificationAppearancePreviewPanel {
                    //% "Name & Message"
                    name: qsTrId("name---message")
                    notificationTitle: "Vitalik Buterin"
                    //% "Hi there! Yes, no problem, let me know if I can help."
                    notificationMessage: qsTrId("hi-there--yes--no-problem--let-me-know-if-i-can-help-")
                    buttonGroup: messageSetting
                    checked: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewNameAndMessage
                    onRadioCheckedChanged: {
                        if (checked) {
                            localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameAndMessage
                        }
                    }
                }
            }

            StatusBaseText {
                //% "No preview or Advanced? Go to Notification Center"
                text: qsTrId("no-preview-or-advanced--go-to-notification-center")
                font.pixelSize: 15
                anchors.left: parent.left
                color: Theme.palette.directColor1
            }
        }

        Separator {
            id: separator2
            anchors.top: column3.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        StatusSectionHeadline {
            id: sectionHeadlineContacts
            //% "Contacts & Users"
            text: qsTrId("contacts---users")
            anchors.top: separator2.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Column {
            id: column4
            anchors.top: sectionHeadlineContacts.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                //% "Notify on new requests"
                title: qsTrId("notify-on-new-requests")

                onClicked: notifyOnRequestsSwitch.checked = !notifyOnRequestsSwitch.checked
                components: [
                    StatusSwitch {
                        id: notifyOnRequestsSwitch
                        checked: localAccountSensitiveSettings.notifyOnNewRequests
                        onClicked: {
                            localAccountSensitiveSettings.notifyOnNewRequests = !checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                //% "Muted users"
                title: qsTrId("muted-users")
                label: root.store.mutedChatsContacts.rowCount() > 0 ? root.store.mutedChatsContacts.rowCount() : qsTrId("none")
                onClicked: {
                    const mutedChatsModal = notificationsContainer.mutedChatsModalComponent.createObject(notificationsContainer, {
                        showMutedContacts: true
                    })
                    //% "Muted contacts"
                    mutedChatsModal.title = qsTrId("muted-contacts");
                    //% "Muted contacts will appear here"
                    mutedChatsModal.noContentText = qsTrId("muted-contacts-will-appear-here");
                    mutedChatsModal.open();
                }
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                //% "Muted chats"
                title: qsTrId("muted-chats")
                label: root.store.mutedChats.rowCount() > 0 ? root.store.mutedChats.rowCount() : qsTr("None")
                onClicked: {
                    const mutedChatsModal = notificationsContainer.mutedChatsModalComponent.createObject(notificationsContainer, {
                        showMutedContacts: false
                    })
                    //% "Muted chats"
                    mutedChatsModal.title = qsTrId("muted-chats");
                    //% "Muted chats will appear here"
                    mutedChatsModal.noContentText = qsTrId("muted-chats-will-appear-here");
                    mutedChatsModal.open();
                }
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }
            StatusBaseText {
                //% "You can limit what gets shown in notifications"
                text: qsTrId("you-can-limit-what-gets-shown-in-notifications")
                color: Theme.palette.baseColor1
                width: parent.width
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                anchors.left: parent.left
            }
        }

        Separator {
            id: separator3
            anchors.top: column4.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        Column {
            id: column5
            spacing: Style.current.smallPadding
            anchors.top: separator3.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            StatusBaseText {
                //% "Reset notification settings"
                text: qsTrId("reset-notification-settings")
                font.pixelSize: 15
                color: Theme.palette.dangerColor1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        localAccountSensitiveSettings.notificationSetting = Constants.notifyAllMessages
                        localAccountSensitiveSettings.notificationSoundsEnabled = true
                        localAccountSensitiveSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameAndMessage
                        localAccountSensitiveSettings.allowNotificationsFromNonContacts = false
                    }
                }
            }

            StatusBaseText {
                //% "Restore default notification settings and unmute all chats and users"
                text: qsTrId("restore-default-notification-settings-and-unmute-all-chats-and-users")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }
    }
}
