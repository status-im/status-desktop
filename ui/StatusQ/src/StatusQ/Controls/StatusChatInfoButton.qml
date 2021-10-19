import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Rectangle {
    id: statusChatInfoButton

    implicitWidth: identicon.width +
                   Math.max(
                       statusChatInfoButtonTitle.anchors.leftMargin + statusChatInfoButtonTitle.implicitWidth,
                       statusChatInfoButtonTitle.anchors.leftMargin + statusChatInfoButtonSubTitle.implicitWidth
                       ) + 8
    implicitHeight: 48

    property string title: ""
    property string subTitle: ""
    property bool muted: false
    property int pinnedMessagesCount: 0
    property StatusImageSettings image: StatusImageSettings {}
    property StatusIconSettings icon: StatusIconSettings {}
    property int type: StatusChatInfoButton.Type.PublicChat
    property alias tooltip: statusToolTip
    property alias sensor: sensor

    signal clicked(var mouse)
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

    radius: 8
    color: sensor.enabled && sensor.containsMouse ? Theme.palette.baseColor2 : "transparent"

    MouseArea {
        id: sensor
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: statusChatInfoButton.clicked(mouse)

        Loader {
            id: identicon

            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter

            sourceComponent: !!statusChatInfoButton.image.source.toString() ?
                                 statusRoundImageComponent :
                                 statusLetterIdenticonComponent
        }

        Component {
            id: statusRoundImageComponent

            Item {
                width: 36
                height: 36
                StatusRoundedImage {
                    id: statusRoundImage
                    width: parent.width
                    height: parent.height
                    image.source: statusChatInfoButton.image.source
                    showLoadingIndicator: true
                    border.width: statusChatInfoButton.image.isIdenticon ? 1 : 0
                    border.color: Theme.palette.directColor7
                }
                Loader {
                    sourceComponent: statusLetterIdenticonComponent
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: statusRoundImage.image.status === Image.Error
                }
            }
        }

        Component {
            id: statusLetterIdenticonComponent

            StatusLetterIdenticon {
                width: 36
                height: 36
                name: statusChatInfoButton.title
                color: statusChatInfoButton.icon.color
            }
        }

        Item {
            id: statusChatInfoButtonTitle
            anchors.top: identicon.top
            anchors.topMargin: statusChatInfoButtonSubTitle.visible ? 0 : 8
            anchors.left: identicon.right
            anchors.leftMargin: 8

            width: Math.min(parent.width - anchors.leftMargin
                            - identicon.width - identicon.anchors.leftMargin,
                            implicitWidth)
            height: chatName.height

            implicitWidth: statusIcon.width + chatName.anchors.leftMargin + chatName.implicitWidth
                           + mutedDelta

            property real mutedDelta: mutedIcon.visible ? mutedIcon.width + 8 : 0

            StatusIcon {
                id: statusIcon
                anchors.top: parent.top
                anchors.topMargin: -2
                anchors.left: parent.left

                visible: statusChatInfoButton.type !== StatusChatInfoButton.Type.OneToOneChat
                width: visible ? 14 : 0
                color: statusChatInfoButton.muted ? Theme.palette.baseColor1 : Theme.palette.directColor1
                icon: {
                    switch (statusChatInfoButton.type) {
                    case StatusChatInfoButton.Type.PublicCat:
                        return "tiny/public-chat"
                        break;
                    case StatusChatInfoButton.Type.GroupChat:
                        return "tiny/group"
                        break;
                    case StatusChatInfoButton.Type.CommunityChat:
                        return "tiny/channel"
                        break;
                    default:
                        return "tiny/public-chat"
                    }
                }
            }

            StatusBaseText {
                id: chatName

                anchors.left: statusIcon.visible ? statusIcon.right : parent.left
                anchors.leftMargin: statusIcon.visible ? 1 : 0
                anchors.top: parent.top

                elide: Text.ElideRight
                width: Math.min(implicitWidth, parent.width
                                - statusIcon.width
                                - statusChatInfoButtonTitle.mutedDelta)

                text: statusChatInfoButton.type === StatusChatInfoButton.Type.PublicChat &&
                      !statusChatInfoButton.title.startsWith("#") ?
                          "#" + statusChatInfoButton.title :
                          statusChatInfoButton.title
                color: statusChatInfoButton.muted ? Theme.palette.directColor5 : Theme.palette.directColor1
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            StatusIcon {
                objectName: "mutedIcon"
                id: mutedIcon
                anchors.left: chatName.right
                anchors.leftMargin: 4
                anchors.top: chatName.top
                anchors.topMargin: -2
                width: 13
                icon: "tiny/muted"
                color: mutedIconSensor.containsMouse ? Theme.palette.directColor1 : Theme.palette.baseColor1
                visible: statusChatInfoButton.muted

                MouseArea {
                    id: mutedIconSensor
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: statusChatInfoButton.unmute()
                }

                StatusToolTip {
                    id: statusToolTip
                    text: "Unmute"
                    visible: mutedIconSensor.containsMouse
                    orientation: StatusToolTip.Orientation.Bottom
                    y: parent.height + 12
                }
            }
        }

        Item {
            id: statusChatInfoButtonSubTitle
            anchors.left: statusChatInfoButtonTitle.left
            anchors.top: statusChatInfoButtonTitle.bottom
            visible: !!statusChatInfoButton.subTitle || statusChatInfoButton.pinnedMessagesCount > 0
            height: visible ? chatType.height : 0
            width: Math.min(parent.width - statusChatInfoButtonTitle.anchors.leftMargin
                            - identicon.width - identicon.anchors.leftMargin - 8,
                            implicitWidth)

            implicitWidth: chatType.implicitWidth + pinIconDelta + 8


            property real pinIconDelta: pinIcon.visible ? pinIcon.width + pinIcon.anchors.leftMargin
                                                          + divider.width + divider.anchors.leftMargin
                                                        : 0

            StatusSelectableText {
                id: chatType
                text: statusChatInfoButton.subTitle
                color: Theme.palette.baseColor1
                font.pixelSize: 12
                width: Math.min(parent.width - (pinIcon.visible ? divider.width + divider.anchors.leftMargin + pinIcon.width + pinIcon.anchors.leftMargin : 0),
                                implicitWidth)
                onLinkActivated: statusChatInfoButton.linkActivated(link)
            }

            Rectangle {
                id: divider
                height: 12
                width: 1
                color: Theme.palette.directColor7
                anchors.left: chatType.right
                anchors.leftMargin: 4
                anchors.verticalCenter: chatType.verticalCenter
                visible: !!chatType.text && pinIcon.visible
            }

            StatusIcon {
                id: pinIcon

                anchors.left: divider.visible ? divider.right : parent.left
                anchors.leftMargin: -2
                anchors.verticalCenter: chatType.verticalCenter
                height: 14
                visible: statusChatInfoButton.pinnedMessagesCount > 0
                icon: "pin"
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                anchors.left: pinIcon.right
                anchors.leftMargin: -6
                anchors.verticalCenter: pinIcon.verticalCenter

                width: 14
                text: statusChatInfoButton.pinnedMessagesCount
                font.pixelSize: 12
                font.underline: pinCountSensor.containsMouse
                visible: pinIcon.visible
                color: pinCountSensor.containsMouse ? Theme.palette.directColor1 : Theme.palette.baseColor1

                MouseArea {
                    id: pinCountSensor
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: statusChatInfoButton.pinnedMessagesCountClicked(mouse)
                }
            }
        }
    }
}
