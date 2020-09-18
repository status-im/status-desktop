import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ScrollView {
    height: parent.height
    width: parent.width
    contentHeight: notificationsContainer.height
    clip: true

    Item {
        id: notificationsContainer
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
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
            text: qsTr("Notification preferences")
            anchors.top: parent.top
        }

        Column {
            id: column
            spacing: Style.current.padding
            anchors.top: sectionHeadlineNotifications.bottom
            anchors.topMargin: Style.current.smallPadding
            width: parent.width

            RowLayout {
                width: parent.width
                StyledText {
                    text: qsTr("All messages")
                    font.pixelSize: 15
                }

                StatusRadioButton {
                    checked: true
                    Layout.alignment: Qt.AlignRight
                    ButtonGroup.group: notificationSetting
                    rightPadding: 0
                }
            }

            RowLayout {
                width: parent.width
                StyledText {
                    text: qsTr("Just @mentions")
                    font.pixelSize: 15
                }
                StatusRadioButton {
                    Layout.alignment: Qt.AlignRight
                    ButtonGroup.group: notificationSetting
                    rightPadding: 0
                }
            }

            RowLayout {
                width: parent.width
                StyledText {
                    text: qsTr("Nothing")
                    font.pixelSize: 15
                }
                StatusRadioButton {
                    Layout.alignment: Qt.AlignRight
                    ButtonGroup.group: notificationSetting
                    rightPadding: 0
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
            text: qsTr("Sound & Appearance")
            anchors.top: separator.bottom
        }

        Column {
            id: column2
            spacing: Style.current.padding
            anchors.top: sectionHeadlineSound.bottom
            anchors.topMargin: Style.current.smallPadding
            width: parent.width

            RowLayout {
                width: parent.width
                StyledText {
                    text: qsTr("Play a sound when receiving a notification")
                    font.pixelSize: 15
                }

                StatusSwitch {
                    Layout.alignment: Qt.AlignRight
                    checked: true
                }
            }

            GridLayout {
                columns: 4
                width: parent.width

                StatusRadioButton {
                    checked: true
                    text: qsTr("Sound 1")
                    ButtonGroup.group: soundSetting
                }

                StatusRadioButton {
                    text: qsTr("Sound 2")
                    ButtonGroup.group: soundSetting
                }

                StatusRadioButton {
                    text: qsTr("Sound 3")
                    ButtonGroup.group: soundSetting
                }

                StatusRadioButton {
                    text: qsTr("Sound 4")
                    ButtonGroup.group: soundSetting
                }
            }
        }

        Column {
            id: column3
            spacing: Style.current.bigPadding
            anchors.top: column2.bottom
            anchors.topMargin: Style.current.padding*2
            width: parent.width

            StyledText {
                text: qsTr("Message preview")
                font.pixelSize: 15
            }

            StatusRadioButton {
                text: qsTr("Anonymous")
                ButtonGroup.group: messageSetting
            }

            StatusRadioButton {
                text: qsTr("Name only")
                ButtonGroup.group: messageSetting
            }

            StatusRadioButton {
                checked: true
                text: qsTr("Name & Message")
                ButtonGroup.group: messageSetting
            }

            StyledText {
                text: qsTr("No preview or Advanced? Go to Notification Center")
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
            text: qsTr("Contacts & Users")
            anchors.top: separator2.bottom
        }

        Column {
            id: column4
            spacing: Style.current.padding
            anchors.top: sectionHeadlineContacts.bottom
            anchors.topMargin: Style.current.smallPadding
            width: parent.width
            RowLayout {
                width: parent.width
                StyledText {
                    text: qsTr("Receive notifications from non-contacts")
                    font.pixelSize: 15
                }

                StatusSwitch {
                    Layout.alignment: Qt.AlignRight
                }
            }

            StatusSectionMenuItem {
                label: qsTr("Muted users")
                info: "2"
            }

            StatusSectionMenuItem {
                label: qsTr("Muted chats")
                description: qsTr("You can limit what gets shown in notifications")
                info: qsTr("None")
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
            width: parent.width

            Button {
                flat: true
                horizontalPadding: 0
                contentItem: Text {
                    text: qsTr("Reset notification settings")
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
                text: qsTr("Restore default notification settings and unmute all chats and users")
                font.pixelSize: 15
                color: Style.current.secondaryText
            }
        }
    }
}
