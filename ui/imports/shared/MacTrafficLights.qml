import QtQuick
import QtQuick.Window

import StatusQ.Core
import StatusQ.Core.Theme

import utils

StatusMouseArea {
    id: root

    signal close()
    signal minimised()
    signal maximized()

    hoverEnabled: true

    width: layout.implicitWidth
    height: layout.implicitHeight

    readonly property color inactive: Theme.palette.name === Constants.lightThemeName ? "#10000000"
                                                                                      : "#10FFFFFF"
    readonly property color inactiveBorder: Theme.palette.name === Constants.lightThemeName ? "#10000000"
                                                                                            : "#10FFFFFF"

    QtObject {
        id: d

        readonly property bool windowActive: root.Window.window.active
    }

    Row {
        id: layout
        spacing: 8

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: closeSensor.pressed ? "#B24F47" : (d.windowActive || root.containsMouse ? Qt.lighter("#E9685C", 1.07) : inactive)
            border.color:closeSensor.pressed ? "#943229" : (d.windowActive ? "#D14C40" : inactiveBorder)
            border.width: Theme.palette.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: root.containsMouse
                source: Theme.png("traffic_lights/" + (closeSensor.pressed ? "close_pressed" : "close"))
                scale: 0.25
            }


            StatusMouseArea {
                id: closeSensor
                anchors.fill: parent

                onClicked: root.close()
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: miniSensor.pressed ? "#878E3B" : (d.windowActive || root.containsMouse ? Qt.lighter("#EDB84C", 1.07) : inactive)
            border.color:miniSensor.pressed ? "#986E29" : (d.windowActive ? "#D79F3D" : inactiveBorder)
            border.width: Theme.palette.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -0.25
                visible: root.containsMouse
                source: Theme.png("traffic_lights/" + (miniSensor.pressed ? "minimise_pressed" : "minimise"))
                scale: 0.27
            }

            StatusMouseArea {
                id: miniSensor
                anchors.fill: parent

                onClicked: root.minimised()
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: maxiSensor.pressed ? "#48943f" : (d.windowActive || root.containsMouse ?  Qt.lighter("#62C454", 1.06) : inactive)
            border.color: maxiSensor.pressed ? "#357225" : (d.windowActive ? "#53A73E" : inactiveBorder)
            border.width: Theme.palette.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: root.containsMouse
                source: Theme.png("traffic_lights/" + (maxiSensor.pressed ? "maximize_pressed" : "maximize"))
                scale: 0.25
            }

            StatusMouseArea {
                id: maxiSensor
                anchors.fill: parent

                onClicked: root.maximized()
            }
        }
    }
}
