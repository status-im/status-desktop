import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1

Row {
    id: themeSwitch
    signal checkedChanged()

    spacing: 2

    Text {
        text: "🌤"
        font.pixelSize: 15
        anchors.verticalCenter: parent.verticalCenter
    }

    StatusSwitch {
        onCheckedChanged: themeSwitch.checkedChanged()
    }

    Text {
        text: "🌙"
        font.pixelSize: 15
        anchors.verticalCenter: parent.verticalCenter
    }
}

