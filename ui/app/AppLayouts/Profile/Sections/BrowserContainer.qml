import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: titl
        text: qsTr("Browser Settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    // TODO add browser settings here
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
