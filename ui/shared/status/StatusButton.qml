import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.14
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Button {
    property string type: "primary"
    property string size: "large"
    property string state: "default"
    property color color: type === "warn" ? Style.current.danger : Style.current.buttonForegroundColor
    property color bgColor: Style.current.buttonBackgroundColor
    property color borderColor: color
    property color bgHoverColor: Qt.darker(control.bgColor, 1.1)
    property bool disableColorOverlay: false
    property bool showBorder: false
    property int iconRotation: 0

    id: control
    font.pixelSize: size === "small" ? 13 : 15
    font.weight: Font.Medium
    implicitHeight: flat ? 32 : (size === "small" ? 38 : 44)
    implicitWidth: buttonLabel.implicitWidth + (flat ? 3* Style.current.halfPadding : 2 * Style.current.padding) +
                   (iconLoader.active ? iconLoader.width : 0)
    enabled: state === "default"

    contentItem: Item {
        id: content
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter

        Loader {
            id: iconLoader
            active: !!control.icon && !!control.icon.source.toString()
            anchors.left: parent.left
            anchors.leftMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter

            sourceComponent: SVGImage {
                id: iconImg
                source: control.icon.source
                height: control.icon.height
                width: control.icon.width
                fillMode: Image.PreserveAspectFit
                rotation: control.iconRotation

                ColorOverlay {
                    enabled: !control.disableColorOverlay
                    anchors.fill: iconImg
                    source: iconImg
                    color: control.disableColorOverlay ? "transparent" : buttonLabel.color
                    antialiasing: true
                    smooth: true
                    rotation: control.iconRotation
                }
            }
        }

        Text {
            id: buttonLabel
            text: control.text
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: iconLoader.active ? undefined : parent.right
            anchors.left: iconLoader.active ? iconLoader.right : parent.left
            anchors.leftMargin: iconLoader.active ? Style.current.smallPadding : 0
            color: !enabled ? Style.current.buttonDisabledForegroundColor : 
              (type !== "warn" && (hovered || highlighted)) ? Style.current.blue : control.color
            visible: !loadingIndicator.active
        }


        Component {
            id: loadingComponent
            LoadingImage {}
        }

        Loader {
            id: loadingIndicator
            active: control.state === "pending"
            sourceComponent: loadingComponent
            height: loadingIndicator.visible ? 
                                    control.size === "large" ?
                                    23 : 17 
                                    : 0
            width: loadingIndicator.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    background: Rectangle {
        radius: Style.current.radius
        anchors.fill: parent
        border.width: flat || showBorder ? 1 : 0
        border.color: hovered || showBorder ? control.borderColor : Style.current.transparent
        color: {
            if (flat) {
                return "transparent"
            }
            if (type === "secondary") {
                return hovered ? control.bgColor : "transparent"
            }
            return !enabled ? Style.current.buttonDisabledBackgroundColor :
                      hovered ?
                        type === "warn" ? Qt.darker(Style.current.buttonWarnBackgroundColor, 1.1) :
                            control.bgHoverColor :
                                type === "warn" ? Style.current.buttonWarnBackgroundColor :
                                    control.bgColor
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}

