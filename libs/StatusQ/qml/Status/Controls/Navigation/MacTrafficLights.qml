import QtQuick
import QtQuick.Controls

import Status.Core.Theme
import Status.Assets

Item {
    id: root

    property color inactiveColor: Style.isLightTheme ? "#10000000" : "#10FFFFFF"
    property color inactiveBorderColor: inactiveColor
    property bool showActive: true

    width: layout.implicitWidth
    height: layout.implicitHeight

    Row {
        id: layout
        spacing: 8
        anchors.top: parent.top
        anchors.left: parent.left

        TrafficLightButton {
            colors: ButtonColors{
                pressed: "#B24F47"
                active: Qt.lighter("#E9685C", 1.07)
                inactive: root.inactiveColor
            }
            borderColors: ButtonColors {
                pressed: "#943229"
                active: "#D14C40"
                inactive: root.inactiveBorderColor
            }
            imagePrefix: "close"

            onClicked: Window.window.close()
        }
        TrafficLightButton {
            colors: ButtonColors{
                pressed: "#878E3B"
                active: Qt.lighter("#EDB84C", 1.07)
                inactive: root.inactiveColor
            }
            borderColors: ButtonColors {
                pressed: "#986E29"
                active: "#D79F3D"
                inactive: root.inactiveBorderColor
            }
            imagePrefix: "minimise"
            imageScale: 0.64
            imageVCenterOffset: 0.5

            onClicked: Window.window.showMinimized()
        }
        TrafficLightButton {
            colors: ButtonColors{
                pressed: "#48943f"
                active: Qt.lighter("#62C454", 1.06)
                inactive: root.inactiveColor
            }
            borderColors: ButtonColors {
                pressed: "#357225"
                active: "#53A73E"
                inactive: root.inactiveBorderColor
            }
            imagePrefix: "maximize"

            onClicked: Window.visibility === Window.FullScreen ? Window.window.showNormal() : Window.window.showFullScreen()
        }
    }


    component ButtonColors: QtObject {
        required property color pressed
        required property color active
        required property color inactive
    }

    component TrafficLightButton: AbstractButton {
        id: button

        required property ButtonColors colors
        required property ButtonColors borderColors
        required property string imagePrefix
        property real imageScale: 0.52
        property real imageVCenterOffset: 0

        implicitWidth: 12
        implicitHeight: 12
        hoverEnabled: true
        padding: 0

        contentItem: Image {
            anchors.centerIn: parent
            visible: allMouseArea.containsMouse
            source: Resources.png(`traffic_lights/${imagePrefix}${button.pressed ? "_pressed" : ""}`)
            anchors.verticalCenterOffset: button.imageVCenterOffset
            scale: button.imageScale
            fillMode: Image.PreserveAspectFit
            antialiasing: true
        }

        background: Rectangle {
            radius: width / 2
            opacity: enabled ? 1 : 0.3

            color: button.down ? colors.pressed
                                      : Window.active ? colors.active
                                                      : colors.inactive
            border.color: button.down ? borderColors.pressed
                                      : Window.active ? borderColors.active
                                          : borderColors.inactive
            border.width: Style.isLightTheme ? 0.5 : 0
        }

        z: allMouseArea.z + 1
    }

    MouseArea {
        id: allMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
