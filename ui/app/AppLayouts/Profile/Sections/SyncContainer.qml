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
            checked: name == profileModel.mailservers.activeMailserver
            onClicked: {
                if (checked) {
                    profileModel.mailservers.setMailserver(name);
                }
            }
        }
    }

    StatusSwitch {
        id: automaticSelectionSwitch
        checked: profileModel.mailservers.automaticSelection
        onCheckedChanged: profileModel.mailservers.enableAutomaticSelection(checked)
    }

    StyledText {
        text: profileModel.mailservers.activeMailserver || qsTr("...")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element4.top
        anchors.topMargin: 24
        visible: automaticSelectionSwitch.checked
    }

    ListView {
        id: mailServersListView
        anchors.topMargin: 48
        anchors.top: element4.bottom
        anchors.fill: parent
        model: profileModel.mailservers.list
        delegate: mailserversList
        visible: !automaticSelectionSwitch.checked
    }
}
