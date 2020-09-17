import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: syncContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element4
        //% "Sync settings"
        text: qsTrId("sync-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Component {
        id: mailserversList
        
        StatusRadioButton {
            text: name
            checked: index == 0 ? true: false
        }
    }

    ListView {
        id: mailServersListView
        anchors.topMargin: 48
        anchors.top: element4.bottom
        anchors.fill: parent
        model: profileModel.mailserversList
        delegate: mailserversList
    }
}
