import QtQuick 2.13
import QtGraphicalEffects 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: textMessage

    property int contentType: 0
    property alias textField: chatText

    signal linkActivated(url link)

    implicitHeight: showMoreLoader.active ? childrenRect.height : chatText.height

    QtObject {
        id: _internal
        property bool readMore: false
        property bool veryLongChatText: chatText.length > 1000
    }

    TextEdit {
        id: chatText
        visible: !showMoreLoader.active || _internal.readMore
        selectedTextColor: Theme.palette.directColor1
        selectionColor: Theme.palette.primaryColor3
        color: Theme.palette.directColor1
        font.family: Theme.palette.baseFont.name
        font.pixelSize: 15
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        readOnly: true
        selectByMouse: true
        height: _internal.veryLongChatText && !_internal.readMore ? Math.min(implicitHeight, 200) : implicitHeight
        width: parent.width
        clip: height < implicitHeight
        onLinkActivated: textMessage.linkActivated(link)
        onLinkHovered: {
            cursorShape: Qt.PointingHandCursor
        }
    }

    Loader {
        id: mask
        anchors.fill: chatText
        active: showMoreLoader.active
        visible: false
        sourceComponent: LinearGradient {
            start: Qt.point(0, 0)
            end: Qt.point(0, chatText.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.85; color: "white" }
                GradientStop { position: 1; color: "transparent" }
            }
        }
    }

    Loader {
        id: opMask
        active: showMoreLoader.active && !_internal.readMore
        anchors.fill: chatText
        sourceComponent: OpacityMask {
            source: chatText
            maskSource: mask
        }
    }

    Loader {
        id: showMoreLoader
        active: _internal.veryLongChatText
        anchors.top: chatText.bottom
        anchors.topMargin: -10
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: StatusRoundButton {
            implicitWidth: 24
            implicitHeight: 24
            type: StatusRoundButton.Type.Secondary
            icon.name: _internal.readMore ? "chevron-up":  "chevron-down"
            onClicked: {
                _internal.readMore = !_internal.readMore
            }
        }
    }
}
