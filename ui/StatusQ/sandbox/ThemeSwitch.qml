import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1

Item {
    id: themeSwitchWrapper
    signal checkedChanged()

    width: themeSwitch.width
    height: themeSwitch.height

    MouseArea {
        id: sensor
        hoverEnabled: true
        anchors.fill: parent

        Row {
            id: themeSwitch
            spacing: 2

            Text {
                text: "🌤"
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            StatusSwitch {
                onCheckedChanged: themeSwitchWrapper.checkedChanged()

                StatusToolTip {
                    text: "Toggle Theme"
                    visible: sensor.containsMouse
                    orientation: StatusToolTip.Orientation.Bottom
                    y: themeSwitchWrapper.y + 16
                }
            }

            Text {
                text: "🌙"
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
