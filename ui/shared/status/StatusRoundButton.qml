import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml 2.14

import utils 1.0
import "../../shared"
import "../../shared/panels"
import "./core"

RoundButton {
    property string type: "primary"
    property string size: "large"
    property int pressedIconRotation: 0
    property alias iconX: iconImg.x
    id: control

    font.pixelSize: 15
    font.weight: Font.Medium

    implicitWidth: {
        switch(size) {
            case "large":
                return 44
            case "medium":
                return 40
            case "small":
                return 32
            default:
                return 44
        }
    }
    implicitHeight: implicitWidth
    enabled: state === "default" || state === "pressed"
    rotation: 0
    state: "default"
    states: [
        State {
            name: "default"
            PropertyChanges {
                target: iconColorOverlay
                visible: true
                rotation: 0
            }
            PropertyChanges {
                target: loadingIndicator
                active: false
            }
        },
        State {
            name: "pressed"
            PropertyChanges {
                target: iconColorOverlay
                rotation: control.pressedIconRotation
                visible: true
            }
            PropertyChanges {
                target: loadingIndicator
                active: false
            }
        },
        State {
            name: "pending"
            PropertyChanges {
                target: loadingIndicator
                active: true
            }
            PropertyChanges {
                target: iconColorOverlay
                visible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "default"
            to: "pressed"

            RotationAnimation {
                duration: 150
                direction: RotationAnimation.Clockwise
                easing.type: Easing.InCubic
            }
        },

        Transition {
            from: "pressed"
            to: "default"
            RotationAnimation {
                duration: 150
                direction: RotationAnimation.Counterclockwise
                easing.type: Easing.OutCubic
            }
        }
    ]

    icon.height: {
        switch(size) {
            case "large":
                return 20
            case "medium":
                return 14
            case "small":
                return 12
            default:
                return 20
        }
    }
    icon.width: {
        switch(size) {
            case "large":
                return 20
            case "medium":
                return 14
            case "small":
                return 12
            default:
                return 20
        }
    }
    icon.color: type === "secondary" ?
        !enabled ?
          Style.current.roundedButtonSecondaryDisabledForegroundColor :
          Style.current.roundedButtonSecondaryForegroundColor
        :
        !enabled ?
          Style.current.roundedButtonDisabledForegroundColor :
          Style.current.roundedButtonForegroundColor

    onIconChanged: {
      icon.source = icon.name ? Style.svg(icon.name) : ""
    }

    background: Rectangle {
        anchors.fill: parent
        opacity: hovered && size === "large" && type !== "secondary" ? 0.2 : 1
        color: {
            if (size === "medium" || size === "small" || type === "secondary") {
                return !enabled ? Style.current.roundedButtonSecondaryDisabledBackgroundColor :
                  hovered ? (control.type === "warn" ? Style.current.red : Style.current.roundedButtonSecondaryHoveredBackgroundColor) :
                  (control.type === "warn" ? Style.current.lightRed : Style.current.roundedButtonSecondaryBackgroundColor)
            }
            return !enabled ?
              Style.current.roundedButtonDisabledBackgroundColor : 
              hovered ? (control.type === "warn" ? Style.current.red : Style.current.buttonHoveredBackgroundColor) :
                        (control.type === "warn" ? Style.current.lightRed : Style.current.roundedButtonBackgroundColor)
        }
        radius: parent.width / 2
    }

    contentItem: Item {
        anchors.fill: parent

        SVGImage {
            id: iconImg
            visible: false
            source: control.icon.source
            height: control.icon.height
            width: control.icon.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        Component {
            id: loadingComponent
            StatusLoadingIndicator {
                color: control.size === "medium" || control.size === "small" ?
                  Style.current.roundedButtonSecondaryDisabledForegroundColor :
                  Style.current.roundedButtonDisabledForegroundColor
            }
        }

        Loader {
            id: loadingIndicator
            sourceComponent: loadingComponent
            height: size === "small" ? 14 : 18
            width: loadingIndicator.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }


        ColorOverlay {
            id: iconColorOverlay
            anchors.fill: iconImg
            source: iconImg
            color: {
                if (type === "secondary") {
                    return !control.enabled ? 
                        Style.current.roundedButtonSecondaryDisabledForegroundColor : 
                        (control.type === "warn" ? Style.current.danger : Style.current.roundedButtonSecondaryForegroundColor)
                }
                return !control.enabled ?
                    Style.current.roundedButtonDisabledForegroundColor :
                   (control.type === "warn" ? Style.current.danger :  Style.current.roundedButtonForegroundColor)
            }
            antialiasing: true
        }
    }

    MouseArea {
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}
