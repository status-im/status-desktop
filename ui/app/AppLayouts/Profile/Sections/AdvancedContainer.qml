import QtQuick 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "../../../../imports"

Item {
    id: advancedContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    Text {
        id: element7
        text: qsTr("Advanced settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        id: browserTabSettings
        anchors.top: element7.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        Text {
            text: qsTr("Browser Tab")
        }
        Switch {
            checked: browserBtn.enabled
            onCheckedChanged: function(value) {
                browserBtn.enabled = this.checked
            }
        }
        Text {
            text: qsTr("experimental (web3 not supported yet)")
        }
    }

    RowLayout {
        anchors.top: browserTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        Text {
            text: qsTr("Node Management Tab")
        }
        Switch {
            checked: nodeBtn.enabled
            onCheckedChanged: function(value) {
                nodeBtn.enabled = this.checked
            }
        }
        Text {
            text: qsTr("under development")
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
