import QtQuick 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "../../../../imports"

Item {
    id: languageContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    Text {
        id: element5
        text: qsTr("Language settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }
}
