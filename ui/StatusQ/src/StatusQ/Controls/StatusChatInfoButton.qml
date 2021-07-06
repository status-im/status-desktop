import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Rectangle {
    id: statusChatInfoButton

    implicitWidth: identicon.width + 
        Math.max(
          statusChatInfoButtonTitle.anchors.leftMargin + statusChatInfoButtonTitle.width,
          statusChatInfoButtonTitle.anchors.leftMargin + statusChatInfoButtonSubTitle.width
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

            width: statusIcon.width + chatName.anchors.leftMargin + chatName.width + (mutedIcon.visible ? mutedIcon.width + mutedIcon.anchors.leftMargin : 0)
            height: chatName.height

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

                text: statusChatInfoButton.title
                color: statusChatInfoButton.muted ? Theme.palette.directColor5 : Theme.palette.directColor1
                font.pixelSize: 15
                font.weight: Font.Medium
            }

            StatusIcon {
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
            visible: !!statusChatInfoButton.subTitle
            height: visible ? chatType.height : 0
            width: childrenRect.width

            StatusBaseText {
                id: chatType
                text: statusChatInfoButton.subTitle
                color: Theme.palette.baseColor1
                font.pixelSize: 12
            }

            Rectangle {
                id: divider
                height: 12
                width: 1
                color: Theme.palette.directColor7
                anchors.left: chatType.right
                anchors.leftMargin: 4
                anchors.verticalCenter: chatType.verticalCenter
                visible: pinIcon.visible
            }

            StatusIcon {
                id: pinIcon

                anchors.left: divider.right
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
