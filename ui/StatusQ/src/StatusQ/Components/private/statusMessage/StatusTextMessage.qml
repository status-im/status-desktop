import QtQuick 2.13
import QtGraphicalEffects 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property alias textField: chatText
    property bool allowShowMore: true

    signal linkActivated(string link)

    implicitWidth: chatText.implicitWidth
    implicitHeight: chatText.effectiveHeight + d.showMoreHeight

    QtObject {
        id: d
        property bool readMore: false
        readonly property bool veryLongChatText: chatText.length > 1000
        readonly property int showMoreHeight: showMoreLoader.visible ? showMoreLoader.height : 0
    }

    TextEdit {
        id: chatText
        objectName: "StatusTextMessage_chatText"

        readonly property int effectiveHeight: d.veryLongChatText && !d.readMore ? Math.min(chatText.implicitHeight, 200)
                                                                                 : chatText.implicitHeight

        width: parent.width
        height: effectiveHeight + d.showMoreHeight / 2
        visible: !opMask.active
        clip: true
        selectedTextColor: Theme.palette.directColor1
        selectionColor: Theme.palette.primaryColor3
        color: Theme.palette.directColor1
        font.family: Theme.palette.baseFont.name
        font.pixelSize: 15
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        readOnly: true
        selectByMouse: true
        onLinkActivated: {
            root.linkActivated(link);
        }
        onLinkHovered: {
            // Strange thing. Without this empty stub the cursorShape
            // is not changed to pointingHandCursor.
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
        active: showMoreLoader.active && !d.readMore
        anchors.fill: chatText
        sourceComponent: OpacityMask {
            source: chatText
            maskSource: mask
        }
    }

    Loader {
        id: showMoreLoader
        active: root.allowShowMore && d.veryLongChatText
        visible: active
        anchors.verticalCenter: chatText.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: StatusRoundButton {
            implicitWidth: 24
            implicitHeight: 24
            type: StatusRoundButton.Type.Secondary
            icon.name: d.readMore ? "chevron-up":  "chevron-down"
            onClicked: {
                d.readMore = !d.readMore
            }
        }
    }
}
