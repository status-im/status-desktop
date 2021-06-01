import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

MouseArea {
    id: statusMacTrafficLights

    signal close()
    signal minimised()
    signal maximized()

    hoverEnabled: true

    width: layout.implicitWidth
    height: layout.implicitHeight

    visible: Qt.platform.os === "osx" && !rootWindow.isFullScreen

    readonly property color inactive: Theme.palette.name === "light" ? "#10000000"
                                                                                      : "#10FFFFFF"
    readonly property color inactiveBorder: Theme.palette.name === "light" ? "#10000000"
                                                                                            : "#10FFFFFF"

    Row {
        id: layout
        spacing: 8

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: closeSensor.pressed ? "#B24F47" : (rootWindow.active || statusMacTrafficLights.containsMouse ? Qt.lighter("#E9685C", 1.07)
                                                                        : inactive )
            border.color:closeSensor.pressed ? "#943229" : (rootWindow.active ? "#D14C40"
                                                                              : inactiveBorder)
            border.width: Theme.palette.name === "light" ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: statusMacTrafficLights.containsMouse
                source: closeSensor.pressed ? "../../assets/img/icons/traffic_lights/close_pressed.png"
                                            : "../../assets/img/icons/traffic_lights/close.png"
                scale: 0.25
            }


            MouseArea {
                id: closeSensor
                anchors.fill: parent

                onClicked: statusMacTrafficLights.close()
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: miniSensor.pressed ? "#878E3B" :  (rootWindow.active || statusMacTrafficLights.containsMouse ? Qt.lighter("#EDB84C", 1.07)
                                                                       : inactive)
            border.color:miniSensor.pressed ? "#986E29" : (rootWindow.active ? "#D79F3D"
                                                                             : inactiveBorder)
            border.width: Theme.palette.name === "light" ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -0.25
                visible: statusMacTrafficLights.containsMouse
                source: miniSensor.pressed ? "../../assets/img/icons/traffic_lights/minimise_pressed.png"
                                           : "../../assets/img/icons/traffic_lights/minimise.png"
                scale: 0.27
            }

            MouseArea {
                id: miniSensor
                anchors.fill: parent

                onClicked: statusMacTrafficLights.minimised()
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: maxiSensor.pressed ? "#48943f" : (rootWindow.active || statusMacTrafficLights.containsMouse ?  Qt.lighter("#62C454", 1.06)
                                                                       : inactive)
            border.color: maxiSensor.pressed ? "#357225" : (rootWindow.active ? "#53A73E"
                                                                              : inactiveBorder)
            border.width: Theme.palette.name === "light" ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: statusMacTrafficLights.containsMouse
                source:   maxiSensor.pressed ?"../../assets/img/icons/traffic_lights/maximize_pressed.png"
                                             :"../../assets/img/icons/traffic_lights/maximize.png"
                scale: 0.25
            }

            MouseArea {
                id: maxiSensor
                anchors.fill: parent

                onClicked: statusMacTrafficLights.maximized()
            }
        }
    }
}
