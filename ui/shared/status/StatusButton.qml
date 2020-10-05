import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.14
import "../../imports"
import "../../shared"

Button {
    property string type: "primary"
    property string size: "large"
    property string state: "default"

    id: control
    font.pixelSize: size === "small" ? Style.current.secondaryTextFontSize : Style.current.primaryTextFontSize
    font.weight: Font.Medium
    implicitHeight: size === "small" ? 38 : 44
    implicitWidth: buttonLabel.implicitWidth + 2 * Style.current.padding
    enabled: state === "default"

    contentItem: Item {
        anchors.fill: parent
        Text {
            id: buttonLabel
            text: control.text
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            color: !enabled ? Style.current.buttonDisabledForegroundColor : Style.current.buttonForegroundColor
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
        color: {
            if (type === "secondary") {
                return hovered ? Style.current.buttonBackgroundColor : "transparent"
            }
            return !enabled ? Style.current.buttonDisabledBackgroundColor :
                      hovered ? Qt.darker(Style.current.buttonBackgroundColor, 1.1) :
                      Style.current.buttonBackgroundColor 
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}

