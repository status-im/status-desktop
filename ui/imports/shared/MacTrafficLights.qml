import QtQuick 2.13


import utils 1.0

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
            width: Style.dp(12)
            height: Style.dp(12)
            radius: width / 2
            antialiasing: true

            color: closeSensor.pressed ? "#B24F47" : (Global.applicationWindow.active || statusMacWindowButtons.containsMouse ? Qt.lighter("#E9685C", 1.07)
                                                                        : inactive )
            border.color:closeSensor.pressed ? "#943229" : (Global.applicationWindow.active ? "#D14C40"
                                                                              : inactiveBorder)
            border.width: Style.current.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                visible: statusMacWindowButtons.containsMouse
                source: Style.png("traffic_lights/" + (closeSensor.pressed ? "close_pressed" : "close"))
                scale: 0.25
            }


            MouseArea {
                id: closeSensor
                anchors.fill: parent

                onClicked: statusMacWindowButtons.close()
            }
        }

        Rectangle {
            width: Style.dp(12)
            height: Style.dp(12)
            radius: width / 2
            antialiasing: true

            color: miniSensor.pressed ? "#878E3B" :  (Global.applicationWindow.active || statusMacWindowButtons.containsMouse ? Qt.lighter("#EDB84C", 1.07)
                                                                       : inactive)
            border.color:miniSensor.pressed ? "#986E29" : (Global.applicationWindow.active ? "#D79F3D"
                                                                             : inactiveBorder)
            border.width: Style.current.name === Constants.lightThemeName ? 0.5 : 0

            Image {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -Style.dp(0.25)
                visible: statusMacWindowButtons.containsMouse
                source: Style.png("traffic_lights/" + (miniSensor.pressed ? "minimise_pressed" : "minimise"))
                scale: 0.27
            }

            MouseArea {
                id: miniSensor
                anchors.fill: parent

                onClicked: statusMacWindowButtons.minimised()
            }
        }

        Rectangle {
            width: Style.dp(12)
            height: Style.dp(12)
            radius: width / 2
            antialiasing: true

            color: maxiSensor.pressed ? "#48943f" : (Global.applicationWindow.active || statusMacWindowButtons.containsMouse ?  Qt.lighter("#62C454", 1.06)
                                                                       : inactive)
            border.color: maxiSensor.pressed ? "#357225" : (Global.applicationWindow.active ? "#53A73E"
                                                                              : inactiveBorder)
            border.width: Style.current.name === Constants.lightThemeName ? Style.dp(0.5) : 0

            Image {
                anchors.centerIn: parent
                visible: statusMacWindowButtons.containsMouse
                source: Style.png("traffic_lights/" + (maxiSensor.pressed ? "maximize_pressed" : "maximize"))
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
