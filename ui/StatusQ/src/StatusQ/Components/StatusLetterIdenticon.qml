import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: statusLetterIdenticon

    property alias identiconText: identiconText
    property string name
    property int letterSize: 21

    color: Theme.palette.miscColor5
    width: 40
    height: 40
    radius: width / 2

    StatusBaseText {
        id: identiconText
        text: ((statusLetterIdenticon.name.charAt(0) === "#")
              || (statusLetterIdenticon.name.charAt(0) === "@") ?
              statusLetterIdenticon.name.charAt(1) : statusLetterIdenticon.name.charAt(0)).toUpperCase()
        font.weight: Font.Bold
        font.pixelSize: statusLetterIdenticon.letterSize
        color: Qt.rgba(255, 255, 255, 0.7)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}


