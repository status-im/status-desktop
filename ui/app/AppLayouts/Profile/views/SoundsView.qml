import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

BaseProfileView {
    id: soundsContainer

    property var store

    StatusBaseText {
        id: labelVolume
        //% "Sound volume"
        text: qsTrId("sound-volume") + " " + volume.value.toPrecision(1)
        font.pixelSize: 15
        color: Theme.palette.directColor1
        Layout.fillWidth: true
    }

    StatusSlider {
        id: volume
        from: 0.0
        to: 1.0
        stepSize: 0.1
        onValueChanged: {
            localAccountSensitiveSettings.volume = volume.value * 10;
        }
        Component.onCompleted: {
            value = localAccountSensitiveSettings.volume * 0.1;
        }
        Layout.fillWidth: true
    }
}
