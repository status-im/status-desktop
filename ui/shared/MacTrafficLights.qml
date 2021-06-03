import QtQuick 2.13

import "../imports"

MouseArea {
    id: statusMacWindowButtons

    signal close()
    signal minimised()
    signal maximized()

    hoverEnabled: true

    width: layout.implicitWidth
    height: layout.implicitHeight

    readonly property color inactive: Style.current.name === Constants.lightThemeName ? "#10000000"
                                                                                      : "#10FFFFFF"
    readonly property color inactiveBorder: Style.current.name === Constants.lightThemeName ? "#10000000"
                                                                                            : "#10FFFFFF"

    Row {
        id: layout
        spacing: 8

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: closeSensor.pressed ? "#B24F47" : (applicationWindow.active || statusMacWindowButtons.containsMouse ? Qt.lighter("#E9685C", 1.07)
                                                                        : inactive )
            border.color:closeSensor.pressed ? "#943229" : (applicationWindow.active ? "#D14C40"
                                                                              : inactiveBorder)
            border.width: Style.current.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: statusMacWindowButtons.containsMouse
                source: closeSensor.pressed ? "../app/img/traffic_lights/close_pressed.png"
                                            : "../app/img/traffic_lights/close.png"
                scale: 0.25
            }


            MouseArea {
                id: closeSensor
                anchors.fill: parent

                onClicked: statusMacWindowButtons.close()
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: miniSensor.pressed ? "#878E3B" :  (applicationWindow.active || statusMacWindowButtons.containsMouse ? Qt.lighter("#EDB84C", 1.07)
                                                                       : inactive)
            border.color:miniSensor.pressed ? "#986E29" : (applicationWindow.active ? "#D79F3D"
                                                                             : inactiveBorder)
            border.width: Style.current.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -0.25
                visible: statusMacWindowButtons.containsMouse
                source: miniSensor.pressed ? "../app/img/traffic_lights/minimise_pressed.png"
                                           : "../app/img/traffic_lights/minimise.png"
                scale: 0.27
            }

            MouseArea {
                id: miniSensor
                anchors.fill: parent

                onClicked: statusMacWindowButtons.minimised()
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            antialiasing: true

            color: maxiSensor.pressed ? "#48943f" : (applicationWindow.active || statusMacWindowButtons.containsMouse ?  Qt.lighter("#62C454", 1.06)
                                                                       : inactive)
            border.color: maxiSensor.pressed ? "#357225" : (applicationWindow.active ? "#53A73E"
                                                                              : inactiveBorder)
            border.width: Style.current.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: statusMacWindowButtons.containsMouse
                source:   maxiSensor.pressed ?"../app/img/traffic_lights/maximize_pressed.png"
                                             :"../app/img/traffic_lights/maximize.png"
                scale: 0.25
            }

            MouseArea {
                id: maxiSensor
                anchors.fill: parent

                onClicked: statusMacWindowButtons.maximized()
            }
        }
    }
}
