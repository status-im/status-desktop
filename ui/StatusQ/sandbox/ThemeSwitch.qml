import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

Item {
    id: themeSwitchWrapper
    signal checkedChanged()

    property alias lightThemeEnabled: switchControl.checked

    width: themeSwitch.width
    height: themeSwitch.height

    StatusMouseArea {
        id: sensor
        hoverEnabled: true
        anchors.fill: parent

        Row {
            id: themeSwitch
            spacing: 2

            Text {
                text: "🌤"
                font.pixelSize: Theme.primaryTextFontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            StatusSwitch {
                id: switchControl
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
                font.pixelSize: Theme.primaryTextFontSize
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
