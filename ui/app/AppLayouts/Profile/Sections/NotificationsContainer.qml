import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ScrollView {
    height: parent.height
    width: parent.width
    contentHeight: notificationsContainer.height
    clip: true

    Rectangle {
        id: notificationsContainer
        anchors.right: parent.right
        anchors.rightMargin: contentMargin - Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: contentMargin - Style.current.padding
        height: this.childrenRect.height + 100

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
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
        }

        Column {
            id: column
            spacing: Style.current.padding
            anchors.top: sectionHeadlineNotifications.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding

            RowLayout {
                width: parent.width
                StyledText {
                    //% "All messages"
                    text: qsTrId("all-messages")
                    font.pixelSize: 15
                }

                StatusRadioButton {
                    Layout.alignment: Qt.AlignRight
                    ButtonGroup.group: notificationSetting
                    rightPadding: 0
                    checked: appSettings.notificationSetting === 0
                    onCheckedChanged: {
                        appSettings.notificationSetting = 0
                    }
                }
            }

            RowLayout {
                width: parent.width
                StyledText {
                    //% "Just @mentions"
                    text: qsTrId("just--mentions")
                    font.pixelSize: 15
                }
                StatusRadioButton {
                    Layout.alignment: Qt.AlignRight
                    ButtonGroup.group: notificationSetting
                    rightPadding: 0
                    checked: appSettings.notificationSetting === 1
                    onCheckedChanged: {
                        appSettings.notificationSetting = 1
                    }
                }
            }

            RowLayout {
                width: parent.width
                StyledText {
                    //% "Nothing"
                    text: qsTrId("nothing")
                    font.pixelSize: 15
                }
                StatusRadioButton {
                    Layout.alignment: Qt.AlignRight
                    ButtonGroup.group: notificationSetting
                    rightPadding: 0
                    checked: appSettings.notificationSetting === 2
                    onCheckedChanged: {
                        appSettings.notificationSetting = 2
                    }
                }
            }
        }

        Separator {
            id: separator
            anchors.top: column.bottom
            anchors.topMargin: Style.current.bigPadding
        }

        StatusSectionHeadline {
            id: sectionHeadlineSound
            //% "Sound & Appearance"
            text: qsTrId("sound---appearance")
            anchors.top: separator.bottom
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
        }

        Column {
            id: column2
            spacing: Style.current.padding
            anchors.top: sectionHeadlineSound.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            width: parent.width

            RowLayout {
                width: parent.width
                StyledText {
                    //% "Play a sound when receiving a notification"
                    text: qsTrId("play-a-sound-when-receiving-a-notification")
                    font.pixelSize: 15
                }

                StatusSwitch {
                    Layout.alignment: Qt.AlignRight
                    checked: appSettings.notificationSoundsEnabled
                    onCheckedChanged: {
                        appSettings.notificationSoundsEnabled = this.checked
                    }
                }
            }

            /* GridLayout { */
            /*     columns: 4 */
            /*     width: parent.width */

            /*     StatusRadioButton { */
            /*         checked: true */
            /*         //% "Sound 1" */
            /*         text: qsTrId("sound-1") */
            /*         ButtonGroup.group: soundSetting */
            /*     } */

            /*     StatusRadioButton { */
            /*         //% "Sound 2" */
            /*         text: qsTrId("sound-2") */
            /*         ButtonGroup.group: soundSetting */
            /*     } */

            /*     StatusRadioButton { */
            /*         //% "Sound 3" */
            /*         text: qsTrId("sound-3") */
            /*         ButtonGroup.group: soundSetting */
            /*     } */

            /*     StatusRadioButton { */
            /*         //% "Sound 4" */
            /*         text: qsTrId("sound-4") */
            /*         ButtonGroup.group: soundSetting */
            /*     } */
            /* } */
        }

        Column {
            id: column3
            spacing: Style.current.bigPadding
            anchors.top: column2.bottom
            anchors.topMargin: Style.current.padding*2
            anchors.left: parent.left
            anchors.right: parent.right

            StyledText {
                //% "Message preview"
                text: qsTrId("message-preview")
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                Rectangle {
                    width: notificationAnonymous.width + Style.current.padding * 2
                    height: childrenRect.height + Style.current.padding + Style.current.halfPadding
                    color: labelAnonymous.checked ? Style.current.secondaryBackground : Style.current.transparent
                    radius: Style.current.radius

                    StatusRadioButton {
                        id: labelAnonymous
                        //% "Anonymous"
                        text: qsTrId("anonymous")
                        ButtonGroup.group: messageSetting
                        checked: appSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous
                        onCheckedChanged: {
                            appSettings.notificationMessagePreviewSetting = Constants.notificationPreviewAnonymous
                        }
                        anchors.top: parent.top
                        anchors.topMargin: Style.current.halfPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.padding
                    }

                    StatusNotification {
                        id: notificationAnonymous
                        anchors.top: labelAnonymous.bottom
                        anchors.topMargin: Style.current.halfPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.padding
                        width: 416
                        name: "Status"
                        chatType: Constants.chatTypePublic
                        message: qsTr("You have a new message")
                    }
                    DropShadow {
                        anchors.fill: notificationAnonymous
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 10
                        samples: 12
                        color: "#22000000"
                        source: notificationAnonymous
                    }
                }

                Rectangle {
                    width: notificationAnonymous.width + Style.current.padding * 2
                    height: childrenRect.height + Style.current.padding + Style.current.halfPadding
                    color: labelNameOnly.checked ? Style.current.secondaryBackground : Style.current.transparent
                    radius: Style.current.radius

                    StatusRadioButton {
                        id: labelNameOnly
                        //% "Name only"
                        text: qsTrId("name-only")
                        ButtonGroup.group: messageSetting
                        checked: appSettings.notificationMessagePreviewSetting === Constants.notificationPreviewNameOnly
                        onCheckedChanged: {
                            appSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameOnly
                        }
                        anchors.top: parent.top
                        anchors.topMargin: Style.current.halfPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.padding
                    }

                    StatusNotification {
                        id: notificationNameOnly
                        width: 416
                        name: "Vitalik Buterin"
                        chatType: 1
                        message: qsTr("You have a new message")
                        anchors.top: labelNameOnly.bottom
                        anchors.topMargin: Style.current.halfPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.padding
                    }
                    DropShadow {
                        anchors.fill: notificationNameOnly
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 10
                        samples: 12
                        color: "#22000000"
                        source: notificationNameOnly
                    }
                }

                Rectangle {
                    width: notificationAnonymous.width + Style.current.padding * 2
                    height: childrenRect.height + Style.current.padding + Style.current.halfPadding
                    color: labelNameAndMessage.checked ? Style.current.secondaryBackground : Style.current.transparent
                    radius: Style.current.radius

                    StatusRadioButton {
                        id: labelNameAndMessage
                        //% "Name & Message"
                        text: qsTrId("name---message")
                        ButtonGroup.group: messageSetting
                        checked: appSettings.notificationMessagePreviewSetting === Constants.notificationPreviewNameAndMessage
                        onCheckedChanged: {
                            appSettings.notificationMessagePreviewSetting = Constants.notificationPreviewNameAndMessage
                        }
                        anchors.top: parent.top
                        anchors.topMargin: Style.current.halfPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.padding
                    }

                    StatusNotification {
                        id: notificationNameAndMessage
                        name: "Vitalik Buterin"
                        width: 416
                        chatType: 1
                        message: qsTr("Hi there! Yes, no problem, let me know if I can help.")
                        anchors.top: labelNameAndMessage.bottom
                        anchors.topMargin: Style.current.halfPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.padding
                    }
                    DropShadow {
                        anchors.fill: notificationNameAndMessage
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 10
                        samples: 12
                        color: "#22000000"
                        source: notificationNameAndMessage
                    }
                }
            }

            StyledText {
                //% "No preview or Advanced? Go to Notification Center"
                text: qsTrId("no-preview-or-advanced--go-to-notification-center")
                font.pixelSize: 15
            }
        }

        Separator {
            id: separator2
            anchors.top: column3.bottom
            anchors.topMargin: Style.current.bigPadding
        }

        StatusSectionHeadline {
            id: sectionHeadlineContacts
            //% "Contacts & Users"
            text: qsTrId("contacts---users")
            anchors.top: separator2.bottom
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
        }

        Column {
            id: column4
            spacing: Style.current.padding
            anchors.top: sectionHeadlineContacts.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            width: parent.width
            RowLayout {
                width: parent.width
                StyledText {
                    //% "Receive notifications from non-contacts"
                    text: qsTrId("receive-notifications-from-non-contacts")
                    font.pixelSize: 15
                }

                StatusSwitch {
                    Layout.alignment: Qt.AlignRight
                    checked: appSettings.allowNotificationsFromNonContacts
                    onCheckedChanged: {
                        appSettings.allowNotificationsFromNonContacts = checked
                    }
                }
            }

            StatusSectionMenuItem {
                //% "Muted users"
                label: qsTrId("muted-users")
                info: "2"
            }

            StatusSectionMenuItem {
                //% "Muted chats"
                label: qsTrId("muted-chats")
                //% "You can limit what gets shown in notifications"
                description: qsTrId("you-can-limit-what-gets-shown-in-notifications")
                //% "None"
                info: qsTrId("none")
            }
        }

        Separator {
            id: separator3
            anchors.top: column4.bottom
            anchors.topMargin: Style.current.bigPadding
        }

        Column {
            id: column5
            spacing: Style.current.smallPadding
            anchors.top: separator3.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            width: parent.width

            Button {
                flat: true
                horizontalPadding: 0
                contentItem: Text {
                    //% "Reset notification settings"
                    text: qsTrId("reset-notification-settings")
                    font.pixelSize: 15
                    color: Style.current.red
                }
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onPressed: mouse.accepted = false
                }
            }

            StyledText {
                //% "Restore default notification settings and unmute all chats and users"
                text: qsTrId("restore-default-notification-settings-and-unmute-all-chats-and-users")
                font.pixelSize: 15
                color: Style.current.secondaryText
            }
        }
    }
}
