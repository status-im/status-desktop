import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: soundsContainer

    property var store
    property int profileContentWidth

    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    Item {
        width: profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        StatusBaseText {
            id: labelVolume
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 24
            //% "Sound volume"
            text: qsTrId("sound-volume") + " " + volume.value.toPrecision(1)
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        StatusSlider {
            id: volume
            anchors.top: labelVolume.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: 24
            from: 0.0
            to: 1.0
            value: localAccountSensitiveSettings.volume
            stepSize: 0.1
            onValueChanged: {
                localAccountSensitiveSettings.volume = volume.value
            }
        }
    }
}
