import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: soundsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element5
        //% "Sounds settings"
        text: qsTrId("sounds-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    StyledText {
        id: labelVolume
        anchors.top: element5.bottom
        anchors.topMargin: Style.current.bigPadding
        anchors.left: parent.left
        anchors.leftMargin: 24
        //% "Sound volume"
        text: qsTrId("sound-volume") + " " + volume.value
        font.pixelSize: 15
    }

    StatusSlider {
        id: volume
        anchors.top: labelVolume.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: 24
        minimumValue: 0.0
        maximumValue: 1.0
        value: appSettings.volume
        stepSize: 0.1
        onValueChanged: {
            appSettings.volume = volume.value
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
