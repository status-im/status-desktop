import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Button {
    id: root
    objectName: "chatInfoButton"

    property string title: text
    property string subTitle
    property bool muted
    property int pinnedMessagesCount

    property StatusAssetSettings asset: StatusAssetSettings {
        width: 36
        height: 36
        charactersLen: 2
    }
    property alias ringSettings: identicon.ringSettings

    property int type: StatusChatInfoButton.Type.PublicChat
    property alias tooltip: statusToolTip

    signal pinnedMessagesCountClicked(var mouse)
    signal unmute()
    signal linkActivated(string link)

    enum Type {
        Unknown0, // 0
        OneToOneChat, // 1
        PublicChat, // 2
        GroupChat, // 3
        Unknown1, // 4
        Unknown2, // 5
        CommunityChat // 6
    }

    horizontalPadding: 4
    verticalPadding: 2
    spacing: 4

    background: Rectangle {
        radius: 8
        color: root.enabled && root.hovered ? Theme.palette.baseColor2 : "transparent"

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: root.hovered ? Qt.PointingHandCursor : undefined
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing

        // identicon
        StatusSmartIdenticon {
            id: identicon
            asset: root.asset
            name: root.title
        }

        // text
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            // title
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeading | Qt.AlignBottom
                spacing: root.spacing

                StatusIcon {
                    visible: root.type !== StatusChatInfoButton.Type.OneToOneChat
                    Layout.preferredWidth: 14
                    Layout.preferredHeight: 14
                    color: root.muted ? Theme.palette.baseColor1 : Theme.palette.directColor1
                    icon: {
                        switch (root.type) {
                        case StatusChatInfoButton.Type.PublicCat:
                            return "tiny/public-chat"
                        case StatusChatInfoButton.Type.GroupChat:
                            return "tiny/group"
                        case StatusChatInfoButton.Type.CommunityChat:
                            return "tiny/channel"
                        default:
                            return "tiny/public-chat"
                        }
                    }
                }

                StatusBaseText {
                    objectName: "statusChatInfoButtonNameText"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.type === StatusChatInfoButton.Type.PublicChat && !root.title.startsWith("#") ?
                              "#" + root.title
                            : root.title
                    color: root.muted ? Theme.palette.directColor5 : Theme.palette.directColor1
                    font.weight: Font.Medium
                }

                StatusIcon {
                    objectName: "mutedIcon"
                    Layout.preferredWidth: 13
                    Layout.preferredHeight: 13
                    icon: "tiny/muted"
                    color: mutedIconSensor.containsMouse ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    visible: root.muted

                    MouseArea {
                        id: mutedIconSensor
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: root.unmute()
                    }

                    StatusToolTip {
                        id: statusToolTip
                        text: qsTr("Unmute")
                        visible: mutedIconSensor.containsMouse
                        orientation: StatusToolTip.Orientation.Bottom
                        y: parent.height + 12
                    }
                }
            }

            // subtitle
            RowLayout {
                id: subtitleRow
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeading | Qt.AlignTop
                Layout.rightMargin: 4
                spacing: 0

                StatusSelectableText {
                    Layout.fillWidth: implicitWidth + separator.width + pinIcon.width + pinText.width > subtitleRow.width
                    text: root.subTitle
                    visible: root.subTitle
                    color: Theme.palette.baseColor1
                    font.pixelSize: 12
                    onLinkActivated: root.linkActivated(link)
                }

                Rectangle {
                    id: separator
                    Layout.preferredHeight: 12
                    Layout.preferredWidth: 1
                    Layout.leftMargin: 4
                    Layout.rightMargin: 2
                    color: Theme.palette.directColor7
                    visible: root.subTitle && root.pinnedMessagesCount
                }

                StatusIcon {
                    id: pinIcon
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    visible: root.pinnedMessagesCount > 0
                    icon: "pin"
                    color: Theme.palette.baseColor1
                }

                StatusBaseText {
                    id: pinText
                    TextMetrics {
                         id: tm
                         font: pinText.font
                         elide: Text.ElideRight
                         elideWidth: pinText.width
                         text: qsTr("%Ln pinned message(s)", "", root.pinnedMessagesCount)
                     }

                    objectName: "StatusChatInfo_pinText"
                    Layout.fillWidth: true
                    text: tm.elidedText !== tm.text ? root.pinnedMessagesCount : tm.text
                    font.pixelSize: 12
                    font.underline: pinCountSensor.containsMouse
                    visible: root.pinnedMessagesCount
                    color: pinCountSensor.containsMouse ? Theme.palette.directColor1 : Theme.palette.baseColor1

                    MouseArea {
                        objectName: "pinMessagesCounterSensor"
                        id: pinCountSensor
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.pinnedMessagesCountClicked(mouse)
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
