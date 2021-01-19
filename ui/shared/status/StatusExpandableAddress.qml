import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

Item {
    id: root
    height: control.height
    width: control.width + copyToClipBoardBtn.width + Style.current.smallPadding
    property bool hovered: false
    property string address: ""
    property bool expanded: false
    property int addressWidth
    property int originalButtonWidth

    Button {
        id: control
        width: root.addressWidth
        leftPadding: 8
        rightPadding: 8
        contentItem: StyledText {
            id: addressText
            text: root.address
            font.pixelSize: 13
            font.family: Style.current.fontHexRegular.name
            color: Style.current.secondaryText
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle {
            color: root.hovered ? Style.current.backgroundHover : "transparent"
            radius: Style.current.radius
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.expanded) {
                    control.width = root.originalButtonWidth
                    this.width = control.width
                } else {
                    root.originalButtonWidth = root.addressWidth
                    control.width = control.maxWidth > 0 ?
                        Math.min(addressText.implicitWidth, control.maxWidth) :
                        addressText.implicitWidth + control.leftPadding + control.rightPadding
                }
                this.width = control.width
                root.expanded = !root.expanded
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        propagateComposedEvents: true
        onPressed: mouse.accepted = false
        onEntered: {
            if (!root.hovered) {
                root.hovered = true
            }
        }
        onExited: {
            if (root.hovered) {
                root.hovered = false
            }
        }
    }

    CopyToClipBoardButton {
        id: copyToClipBoardBtn
        visible: root.hovered
        anchors.left: control.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        textToCopy: root.address
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onPressed: mouse.accepted = false
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: {
                if (!root.hovered) {
                    root.hovered = true
                }
            }
            onExited: {
                if (root.hovered) {
                    root.hovered = false
                }
            }
        }
    }
}
