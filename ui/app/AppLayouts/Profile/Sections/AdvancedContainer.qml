import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: advancedContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
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
        StyledText {
            text: qsTr("Browser Tab")
        }
        Switch {
            checked: browserBtn.enabled
            onCheckedChanged: function(value) {
                browserBtn.enabled = this.checked
            }
        }
        StyledText {
            text: qsTr("experimental (web3 not supported yet)")
        }
    }

    RowLayout {
        anchors.top: browserTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            text: qsTr("Node Management Tab")
        }
        Switch {
            checked: nodeBtn.enabled
            onCheckedChanged: function(value) {
                nodeBtn.enabled = this.checked
            }
        }
        StyledText {
            text: qsTr("under development")
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
