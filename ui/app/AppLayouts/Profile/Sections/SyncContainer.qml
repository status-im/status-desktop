import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: syncContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element4
        text: qsTr("Sync settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Component {
        id: mailserversList

        RadioButton {
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
