import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ColumnLayout {
    id: root
    anchors.fill: parent
    anchors.margins: 24

    StyledText {
        id: labelVolume
        //% "Sound volume"
        text: qsTrId("sound-volume") + " " + (volume.value > 0 ? volume.value.toFixed(1) : 0)
        font.pixelSize: 15
    }

    StatusSlider {
        id: volume
        anchors {
            right: undefined
            left: undefined
        }
        Layout.preferredWidth: root.width
        minimumValue: 0.0
        maximumValue: 1.0
        value: appSettings.volume
        stepSize: 0.1
        onValueChanged: {
            appSettings.volume = value
        }
    }

    Item {
        Layout.preferredHeight: Style.current.smallPadding
    }

    StyledText {
        id: labelMic
        text: qsTr("Microphone level") + " " + (micLevel.value > 0 ? micLevel.value.toFixed(1) : 0)
        font.pixelSize: 15
    }

    StatusSlider {
        id: micLevel
        anchors {
            right: undefined
            left: undefined
        }
        Layout.preferredWidth: root.width
        minimumValue: 0.0
        maximumValue: 1.0
        value: appSettings.micLevel
        stepSize: 0.1
        onValueChanged: {
            appSettings.micLevel = value
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
