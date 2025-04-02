import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
    property bool requiresPermissions
    property bool locked
    property bool forceHideTypeIcon: false

    property StatusAssetSettings asset: StatusAssetSettings {
        width: 36
        height: 36
        charactersLen: 2
    }
    property alias ringSettings: identicon.ringSettings

    property int type: StatusChatInfoButton.Type.Unknown0
    property alias tooltip: statusToolTip

    signal pinnedMessagesCountClicked()
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

        HoverHandler {
            enabled: root.hoverEnabled
            cursorShape: enabled ? Qt.PointingHandCursor : undefined
        }
    }

    component TruncatedTextWithTooltip: StatusBaseText {
        readonly property alias hovered: truncatedHandler.hovered
        property alias cursorShape: truncatedHandler.cursorShape

        elide: Text.ElideRight

        StatusToolTip {
            text: parent.text
            visible: truncatedHandler.hovered && parent.truncated
            orientation: StatusToolTip.Orientation.Bottom
            delay: 500
            y: parent.height + 12
        }

        HoverHandler {
            id: truncatedHandler
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : undefined
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
                spacing: 1

                StatusIcon {
                    visible: root.type !== StatusChatInfoButton.Type.OneToOneChat && !forceHideTypeIcon && icon
                    Layout.preferredWidth: 14
                    Layout.preferredHeight: 14
                    color: root.muted ? Theme.palette.baseColor1 : Theme.palette.directColor1
                    icon: {
                        switch (root.type) {
                        case StatusChatInfoButton.Type.PublicChat:
                            return "tiny/public-chat"
                        case StatusChatInfoButton.Type.GroupChat:
                            return "tiny/group"
                        case StatusChatInfoButton.Type.CommunityChat: {
                            var iconName = "tiny/channel"
                            if (root.requiresPermissions)
                                iconName = root.locked ? "tiny/channel-locked" : "tiny/channel-unlocked"
                            return Theme.palette.name === "light" ? iconName : iconName+"-white"
                        }
                        default:
                            return ""
                        }
                    }
                }

                TruncatedTextWithTooltip {
                    Layout.fillWidth: true
                    Layout.maximumWidth: Math.ceil(implicitWidth)
                    Layout.alignment: Qt.AlignVCenter
                    objectName: "statusChatInfoButtonNameText"
                    text: root.title
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

                    StatusMouseArea {
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
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeading | Qt.AlignTop
                visible: root.subTitle || root.pinnedMessagesCount
                spacing: 0

                TruncatedTextWithTooltip {
                    Layout.fillWidth: true
                    Layout.maximumWidth: Math.ceil(implicitWidth)
                    text: root.subTitle
                    visible: text
                    color: Theme.palette.baseColor1
                    font.pixelSize: 12
                    onLinkActivated: root.linkActivated(link)
                }

                Rectangle {
                    Layout.preferredHeight: 12
                    Layout.preferredWidth: 1
                    Layout.leftMargin: 4
                    Layout.rightMargin: 2
                    color: Theme.palette.directColor7
                    visible: root.subTitle && root.pinnedMessagesCount
                }

                StatusIcon {
                    Layout.preferredHeight: 14
                    Layout.preferredWidth: 14
                    visible: root.pinnedMessagesCount
                    icon: "pin"
                    color: pinText.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                }

                TruncatedTextWithTooltip {
                    id: pinText
                    objectName: "StatusChatInfo_pinText"
                    Layout.fillWidth: true
                    Layout.maximumWidth: Math.ceil(implicitWidth)
                    text: qsTr("%Ln pinned message(s)", "", root.pinnedMessagesCount)
                    font.pixelSize: 12
                    font.underline: hovered
                    visible: root.pinnedMessagesCount
                    color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    cursorShape: Qt.PointingHandCursor
                    TapHandler {
                        onSingleTapped: root.pinnedMessagesCountClicked()
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }
    }
}
